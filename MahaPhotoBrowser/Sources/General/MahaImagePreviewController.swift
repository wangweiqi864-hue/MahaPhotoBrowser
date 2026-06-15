//
//  MahaImagePreviewController.swift
//  MahaPhotoBrowser
//
//  Created by long on 2020/10/22.
//
//  Copyright (c) 2020 Long Zhang <495181165@qq.com>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import UIKit
import Photos

@objc public enum MahaURLType: Int {
    case image
    case video
}

public typealias MahaImageLoaderBlock = (_ url: URL, _ imageView: UIImageView, _ progress: @escaping (CGFloat) -> Void, _ complete: @escaping () -> Void) -> Void

@objc public protocol MahaImagePreviewControllerDelegate: AnyObject {
    @objc optional func imagePreviewController(_ controller: MahaImagePreviewController, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath)
    
    @objc optional func imagePreviewController(_ controller: MahaImagePreviewController, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath)
    
    @objc optional func imagePreviewController(_ controller: MahaImagePreviewController, didScroll collectionView: UICollectionView)
}

public class MahaImagePreviewController: UIViewController {
    static let colItemSpacing: CGFloat = 40
    
    static let selPhotoPreviewH: CGFloat = 100
    
    private let datas: [Any]
    
    private var selectStatus: [Bool]
    
    private let urlType: ((URL) -> MahaURLType)?
    
    private let urlImageLoader: MahaImageLoaderBlock?
    
    private let showSelectBtn: Bool
    
    private let showBottomView: Bool

    public private(set) var currentIndex: Int
    
    private var indexBeforOrientationChanged: Int
    
    lazy var collectionView: UICollectionView = {
        let layout = MahaCollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.backgroundColor = .clear
        view.dataSource = self
        view.delegate = self
        view.isPagingEnabled = true
        view.showsHorizontalScrollIndicator = false
        
        MahaPhotoPreviewCell.maha.register(view)
        MahaGifPreviewCell.maha.register(view)
        MahaLivePhotoPreviewCell.maha.register(view)
        MahaVideoPreviewCell.maha.register(view)
        MahaLocalImagePreviewCell.maha.register(view)
        MahaNetImagePreviewCell.maha.register(view)
        MahaNetVideoPreviewCell.maha.register(view)
        
        return view
    }()
    
    private let navViewAlpha = 0.95
    
    private lazy var navView: UIView = {
        let view = UIView()
        view.backgroundColor = .maha.navBarColorOfPreviewVC
        view.alpha = navViewAlpha
        return view
    }()
    
    private var navBlurView: UIVisualEffectView?
    
    private lazy var backBtn: UIButton = {
        let btn = UIButton(type: .custom)
        var image = UIImage.maha.getImage("zl_navBack")
        if isRTL() {
            image = image?.imageFlippedForRightToLeftLayoutDirection()
            btn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -10)
        } else {
            btn.imageEdgeInsets = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 0)
        }
        btn.setImage(image, for: .normal)
        btn.addTarget(self, action: #selector(backBtnClick), for: .touchUpInside)
        return btn
    }()
    
    private lazy var indexLabel: UILabel = {
        let label = UILabel()
        label.textColor = .maha.indexLabelTextColor
        label.font = MahaLayout.navTitleFont
        label.textAlignment = .center
        return label
    }()
    
    private lazy var selectBtn: MahaEnlargeButton = {
        let btn = MahaEnlargeButton(type: .custom)
        btn.setImage(.maha.getImage("zl_btn_unselected_with_check"), for: .normal)
        btn.setImage(.maha.getImage("zl_btn_selected"), for: .selected)
        btn.enlargeInset = 10
        btn.addTarget(self, action: #selector(selectBtnClick), for: .touchUpInside)
        return btn
    }()
    
    private lazy var bottomView: UIView = {
        let view = UIView()
        view.backgroundColor = .maha.bottomToolViewBgColorOfPreviewVC
        return view
    }()
    
    private var bottomBlurView: UIVisualEffectView?
    
    private lazy var doneBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.titleLabel?.font = MahaLayout.bottomToolTitleFont
        btn.setTitle(title, for: .normal)
        btn.setTitleColor(.maha.bottomToolViewDoneBtnNormalTitleColorOfPreviewVC, for: .normal)
        btn.setTitleColor(.maha.bottomToolViewDoneBtnDisableTitleColorOfPreviewVC, for: .disabled)
        btn.addTarget(self, action: #selector(doneBtnClick), for: .touchUpInside)
        btn.backgroundColor = .maha.bottomToolViewBtnNormalBgColorOfPreviewVC
        btn.layer.masksToBounds = true
        btn.layer.cornerRadius = MahaLayout.bottomToolBtnCornerRadius
        return btn
    }()
    
    private var isFirstAppear = true
    
    private var hideNavView = false
    
    private var dismissInteractiveTransition: MahaImagePreviewDismissInteractiveTransition?
    
    private var orientation: UIInterfaceOrientation = .unknown
    
    @objc public var delegate: MahaImagePreviewControllerDelegate?
    
    @objc public var longPressBlock: ((MahaImagePreviewController?, UIImage?, Int) -> Void)?
    
    @objc public var doneBlock: (([Any]) -> Void)?
    
    @objc public var videoHttpHeader: [String: Any]?
    
    /// 下拉返回时，需要外界提供一个动画结束时的rect
    public var dismissTransitionFrame: ((Int) -> CGRect?)?
    
    override public var prefersStatusBarHidden: Bool {
        !MahaPhotoUIConfiguration.default().showStatusBarInPreviewInterface
    }
    
    override public var prefersHomeIndicatorAutoHidden: Bool { true }
    
    override public var preferredStatusBarStyle: UIStatusBarStyle {
        MahaPhotoUIConfiguration.default().statusBarStyle
    }
    
    deinit {
        mahaDebugPrint("MahaImagePreviewController deinit")
    }
    
    /// - Parameters:
    ///   - datas: Must be one of PHAsset, UIImage and URL, will filter others in init function.
    ///   - showBottomView: If showSelectBtn is true, showBottomView is always true.
    ///   - index: Index for first display.
    ///   - urlType: Tell me the url is image or video.
    ///   - urlImageLoader: Called when cell will display, cell will layout after callback when image load finish. The first block is progress callback, second is load finish callback.
    @objc public init(
        datas: [Any],
        index: Int = 0,
        showSelectBtn: Bool = true,
        showBottomView: Bool = true,
        urlType: ((URL) -> MahaURLType)? = nil,
        urlImageLoader: MahaImageLoaderBlock? = nil
    ) {
        let filterDatas = datas.filter { $0 is PHAsset || $0 is UIImage || $0 is URL }
        self.datas = filterDatas
        selectStatus = Array(repeating: true, count: filterDatas.count)
        currentIndex = min(index, filterDatas.count - 1)
        indexBeforOrientationChanged = currentIndex
        self.showSelectBtn = showSelectBtn
        self.showBottomView = showSelectBtn ? true : showBottomView
        self.urlType = urlType
        self.urlImageLoader = urlImageLoader
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        addDismissInteractiveTransition()
        resetSubViewStatus()
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        transitioningDelegate = self
        
        guard isFirstAppear else { return }
        isFirstAppear = false
        
        reloadCurrentCell()
    }
    
    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        var insets = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        if #available(iOS 11.0, *) {
            insets = view.safeAreaInsets
        }
        insets.top = max(20, insets.top)
        
        collectionView.frame = CGRect(
            x: -MahaPhotoPreviewController.colItemSpacing / 2,
            y: 0,
            width: view.maha.width + MahaPhotoPreviewController.colItemSpacing,
            height: view.maha.height
        )
        
        let navH = insets.top + 44
        navView.frame = CGRect(x: 0, y: 0, width: view.maha.width, height: navH)
        navBlurView?.frame = navView.bounds
        
        indexLabel.frame = CGRect(x: (view.maha.width - 80) / 2, y: insets.top, width: 80, height: 44)
        
        if isRTL() {
            backBtn.frame = CGRect(x: view.maha.width - insets.right - 60, y: insets.top, width: 60, height: 44)
            selectBtn.frame = CGRect(x: insets.left + 15, y: insets.top + (44 - 25) / 2, width: 25, height: 25)
        } else {
            backBtn.frame = CGRect(x: insets.left, y: insets.top, width: 60, height: 44)
            selectBtn.frame = CGRect(x: view.maha.width - 40 - insets.right, y: insets.top + (44 - 25) / 2, width: 25, height: 25)
        }
        
        let bottomViewH = MahaLayout.bottomToolViewH
        
        bottomView.frame = CGRect(x: 0, y: view.maha.height - insets.bottom - bottomViewH, width: view.maha.width, height: bottomViewH + insets.bottom)
        bottomBlurView?.frame = bottomView.bounds
        
        resetBottomViewFrame()
        
        let ori = UIApplication.shared.statusBarOrientation
        if ori != orientation {
            orientation = ori
            collectionView.setContentOffset(
                CGPoint(
                    x: (view.maha.width + MahaPhotoPreviewController.colItemSpacing) * CGFloat(indexBeforOrientationChanged),
                    y: 0
                ),
                animated: false
            )
        }
    }
    
    override public func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    private func reloadCurrentCell() {
        guard let cell = collectionView.cellForItem(at: IndexPath(row: currentIndex, section: 0)) else {
            return
        }
        
        if let cell = cell as? MahaGifPreviewCell {
            cell.loadGifWhenCellDisplaying()
        } else if let cell = cell as? MahaLivePhotoPreviewCell {
            cell.loadLivePhotoData()
        }
    }
    
    private func setupUI() {
        view.backgroundColor = .maha.previewVCBgColor
        automaticallyAdjustsScrollViewInsets = false
        
        view.addSubview(navView)
        
        if let effect = MahaPhotoUIConfiguration.default().navViewBlurEffectOfPreview {
            navBlurView = UIVisualEffectView(effect: effect)
            navView.addSubview(navBlurView!)
        }
        
        navView.addSubview(backBtn)
        navView.addSubview(indexLabel)
        navView.addSubview(selectBtn)
        view.addSubview(collectionView)
        view.addSubview(bottomView)
        
        if let effect = MahaPhotoUIConfiguration.default().bottomViewBlurEffectOfPreview {
            bottomBlurView = UIVisualEffectView(effect: effect)
            bottomView.addSubview(bottomBlurView!)
        }
        
        bottomView.addSubview(doneBtn)
        view.bringSubviewToFront(navView)
    }
    
    private func addDismissInteractiveTransition() {
        dismissInteractiveTransition = MahaImagePreviewDismissInteractiveTransition(viewController: self)
        dismissInteractiveTransition?.shouldStartTransition = { [weak self] point -> Bool in
            guard let `self` = self else { return false }
            
            if !self.hideNavView, self.navView.frame.contains(point) ||
                self.bottomView.frame.contains(point) {
                return false
            }
            
            guard self.collectionView.cellForItem(at: IndexPath(row: self.currentIndex, section: 0)) != nil else {
                return false
            }
            
            return true
        }
        dismissInteractiveTransition?.startTransition = { [weak self] in
            guard let `self` = self else { return }
            
            UIView.animate(withDuration: 0.25) {
                self.navView.alpha = 0
                self.bottomView.alpha = 0
            }
            
            guard let cell = self.collectionView.cellForItem(at: IndexPath(row: self.currentIndex, section: 0)) else {
                return
            }
            
            if let cell = cell as? MahaLivePhotoPreviewCell {
                cell.livePhotoView.stopPlayback()
            } else if let cell = cell as? MahaGifPreviewCell {
                cell.pauseGif()
            }
        }
        dismissInteractiveTransition?.cancelTransition = { [weak self] in
            guard let `self` = self else { return }
            
            let cell = self.collectionView.cellForItem(at: IndexPath(row: self.currentIndex, section: 0))
            
            if let cell = cell as? MahaNetVideoPreviewCell {
                self.hideNavView = cell.isPlaying
            } else {
                self.hideNavView = false
            }
            
            self.navView.isHidden = self.hideNavView
            self.bottomView.isHidden = self.hideNavView
            
            UIView.animate(withDuration: 0.5) {
                self.navView.alpha = self.navViewAlpha
                self.bottomView.alpha = 1
            }
            
            if let cell = cell as? MahaGifPreviewCell {
                cell.resumeGif()
            }
        }
    }
    
    private func resetSubViewStatus() {
        indexLabel.text = String(currentIndex + 1) + " / " + String(datas.count)
        
        if showSelectBtn {
            selectBtn.isSelected = selectStatus[currentIndex]
        } else {
            selectBtn.isHidden = true
        }
        
        resetBottomViewFrame()
    }
    
    private func resetBottomViewFrame() {
        guard showBottomView else {
            bottomView.isHidden = true
            return
        }
        
        let btnY = MahaLayout.bottomToolBtnY
        
        var doneTitle = localLanguageTextValue(.done)
        let selCount = selectStatus.filter { $0 }.count
        if showSelectBtn,
           MahaPhotoConfiguration.default().showSelectCountOnDoneBtn,
           selCount > 0 {
            doneTitle += "(" + String(selCount) + ")"
        }
        let doneBtnW = doneTitle.maha.boundingRect(font: MahaLayout.bottomToolTitleFont, limitSize: CGSize(width: CGFloat.greatestFiniteMagnitude, height: 30)).width + 20
        doneBtn.frame = CGRect(x: bottomView.bounds.width - doneBtnW - 15, y: btnY, width: doneBtnW, height: MahaLayout.bottomToolBtnH)
        doneBtn.setTitle(doneTitle, for: .normal)
    }
    
    private func dismiss() {
        if let nav = navigationController {
            let vc = nav.popViewController(animated: true)
            if vc == nil {
                nav.dismiss(animated: true, completion: nil)
            }
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    // MARK: btn actions
    
    @objc private func backBtnClick() {
        dismiss()
    }
    
    @objc private func selectBtnClick() {
        var isSelected = selectStatus[currentIndex]
        selectBtn.layer.removeAllAnimations()
        if isSelected {
            isSelected = false
        } else {
            if MahaPhotoUIConfiguration.default().animateSelectBtnWhenSelectInPreviewVC {
                selectBtn.layer.add(MahaAnimationUtils.springAnimation(), forKey: nil)
            }
            isSelected = true
        }
        
        selectStatus[currentIndex] = isSelected
        resetSubViewStatus()
    }
    
    @objc private func doneBtnClick() {
        if showSelectBtn {
            let res = datas.enumerated()
                .filter { self.selectStatus[$0.offset] }
                .map { $0.element }
            
            doneBlock?(res)
        } else {
            doneBlock?(datas)
        }
        
        dismiss()
    }
    
    private func tapPreviewCell() {
        hideNavView.toggle()
        
        let cell = collectionView.cellForItem(at: IndexPath(row: currentIndex, section: 0))
        if let cell = cell as? MahaVideoPreviewCell, cell.isPlaying {
            hideNavView = true
        } else if let cell = cell as? MahaNetVideoPreviewCell, cell.isPlaying {
            hideNavView = true
        }
        navView.isHidden = hideNavView
        if showBottomView {
            bottomView.isHidden = hideNavView
        }
    }
}

extension MahaImagePreviewController: UIViewControllerTransitioningDelegate {
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return dismissInteractiveTransition?.interactive == true ? MahaPhotoPreviewAnimatedTransition() : nil
    }
    
    public func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return dismissInteractiveTransition?.interactive == true ? dismissInteractiveTransition : nil
    }
}

// MARK: scroll view delegate

public extension MahaImagePreviewController {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView == collectionView else {
            return
        }
        
        delegate?.imagePreviewController?(self, didScroll: collectionView)
        
        NotificationCenter.default.post(name: MahaPhotoPreviewController.previewVCScrollNotification, object: nil)
        let offset = scrollView.contentOffset
        var page = Int(round(offset.x / (view.bounds.width + MahaPhotoPreviewController.colItemSpacing)))
        page = max(0, min(page, datas.count - 1))
        if page == currentIndex {
            return
        }
        
        currentIndex = page
        resetSubViewStatus()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        indexBeforOrientationChanged = currentIndex
        let cell = collectionView.cellForItem(at: IndexPath(row: currentIndex, section: 0))
        if let cell = cell as? MahaGifPreviewCell {
            cell.loadGifWhenCellDisplaying()
        } else if let cell = cell as? MahaLivePhotoPreviewCell {
            cell.loadLivePhotoData()
        }
    }
}

extension MahaImagePreviewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return MahaImagePreviewController.colItemSpacing
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return MahaImagePreviewController.colItemSpacing
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: MahaImagePreviewController.colItemSpacing / 2, bottom: 0, right: MahaImagePreviewController.colItemSpacing / 2)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.maha.width, height: view.maha.height)
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return datas.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let config = MahaPhotoConfiguration.default()
        let obj = datas[indexPath.row]
        
        let baseCell: MahaPreviewBaseCell
        
        if let asset = obj as? PHAsset {
            let model = MahaPhotoModel(asset: asset)
            
            if config.allowSelectGif, model.type == .gif {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MahaGifPreviewCell.maha.identifier, for: indexPath) as! MahaGifPreviewCell
                
                cell.singleTapBlock = { [weak self] in
                    self?.tapPreviewCell()
                }
                
                cell.model = model
                baseCell = cell
            } else if config.allowSelectLivePhoto, model.type == .livePhoto {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MahaLivePhotoPreviewCell.maha.identifier, for: indexPath) as! MahaLivePhotoPreviewCell
                
                cell.model = model
                
                baseCell = cell
            } else if config.allowSelectVideo, model.type == .video {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MahaVideoPreviewCell.maha.identifier, for: indexPath) as! MahaVideoPreviewCell
                
                cell.model = model
                
                baseCell = cell
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MahaPhotoPreviewCell.maha.identifier, for: indexPath) as! MahaPhotoPreviewCell

                cell.singleTapBlock = { [weak self] in
                    self?.tapPreviewCell()
                }

                cell.model = model

                baseCell = cell
            }
            
            return baseCell
        } else if let image = obj as? UIImage {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MahaLocalImagePreviewCell.maha.identifier, for: indexPath) as! MahaLocalImagePreviewCell
            
            cell.image = image
            
            baseCell = cell
        } else if let url = obj as? URL {
            let type: MahaURLType = urlType?(url) ?? .image
            if type == .image {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MahaNetImagePreviewCell.maha.identifier, for: indexPath) as! MahaNetImagePreviewCell
                cell.image = nil
                
                urlImageLoader?(url, cell.preview.imageView, { [weak cell] progress in
                    MahaMainAsync {
                        cell?.progress = progress
                    }
                }, { [weak cell] in
                    MahaMainAsync {
                        cell?.preview.resetSubViewSize()
                    }
                })
                
                baseCell = cell
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MahaNetVideoPreviewCell.maha.identifier, for: indexPath) as! MahaNetVideoPreviewCell
                
                cell.configureCell(videoUrl: url, httpHeader: videoHttpHeader)
                
                baseCell = cell
            }
        } else {
            #if DEBUG
                fatalError("Preview obj must one of PHAsset, UIImage, URL")
            #else
                return UICollectionViewCell()
            #endif
        }
        
        baseCell.singleTapBlock = { [weak self] in
            self?.tapPreviewCell()
        }
        
        (baseCell as? MahaLocalImagePreviewCell)?.longPressBlock = { [weak self, weak baseCell] in
            if let callback = self?.longPressBlock {
                callback(self, baseCell?.currentImage, indexPath.row)
            } else {
                self?.showSaveImageAlert()
            }
        }
        
        return baseCell
    }
    
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        delegate?.imagePreviewController?(self, willDisplay: cell, forItemAt: indexPath)
        (cell as? MahaPreviewBaseCell)?.willDisplay()
    }
    
    public func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        delegate?.imagePreviewController?(self, didEndDisplaying: cell, forItemAt: indexPath)
        (cell as? MahaPreviewBaseCell)?.didEndDisplaying()
    }
    
    private func showSaveImageAlert() {
        func saveImage() {
            guard let cell = collectionView.cellForItem(at: IndexPath(row: currentIndex, section: 0)) as? MahaLocalImagePreviewCell, let image = cell.currentImage else {
                return
            }
            
            let hud = MahaProgressHUD.show(toast: .processing)
            MahaPhotoManager.saveImageToAlbum(image: image) { [weak self] error, _ in
                hud.hide()
                if error != nil {
                    showAlertView(localLanguageTextValue(.saveImageError), self)
                }
            }
        }
        
        let saveAction = MahaCustomAlertAction(title: localLanguageTextValue(.save), style: .default) { _ in
            saveImage()
        }
        let cancelAction = MahaCustomAlertAction(title: localLanguageTextValue(.cancel), style: .cancel, handler: nil)
        showAlertController(title: nil, message: nil, style: .actionSheet, actions: [saveAction, cancelAction], sender: self)
    }
}
