//
//  MahaThumbnailPhotoCell.swift
//  MahaPhotoBrowser
//
//  Created by long on 2020/8/12.
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

class MahaThumbnailPhotoCell: UICollectionViewCell {
    private enum Layout {
        static let selectButtonSize: CGFloat = 24
        static let selectButtonRightInset: CGFloat = 32
        static let selectButtonTopInset: CGFloat = 8
        static let indexLabelLeftInset: CGFloat = 8
        static let indexLabelTopInset: CGFloat = 5
        static let bottomShadowHeight: CGFloat = 25
        static let progressViewSize: CGFloat = 20
    }
    
    private lazy var containerView = UIView()
    
    private lazy var bottomShadowView = UIImageView(image: .maha.getImage("zl_shadow"))
    
    private lazy var videoTag = UIImageView(image: .maha.getImage("zl_video"))
    
    private lazy var livePhotoTag = UIImageView(image: .maha.getImage("zl_livePhoto"))
    
    private lazy var editImageTag = UIImageView(image: .maha.getImage("zl_editImage_tag"))
    
    private lazy var descLabel: UILabel = {
        let label = UILabel()
        label.font = .maha.font(ofSize: 13)
        label.textAlignment = .right
        label.textColor = .white
        return label
    }()
    
    private lazy var progressView: MahaProgressView = {
        let view = MahaProgressView()
        view.isHidden = true
        return view
    }()
    
    private var displayedImageIdentifier = ""
    
    private var thumbnailImageRequestID: PHImageRequestID = PHInvalidImageRequestID
    
    private var originalImageRequestID: PHImageRequestID = PHInvalidImageRequestID
    
    lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        return view
    }()
    
    lazy var btnSelect: MahaEnlargeButton = {
        let btn = MahaEnlargeButton(type: .custom)
        btn.setBackgroundImage(.maha.getImage("zl_btn_unselected"), for: .normal)
        btn.setBackgroundImage(.maha.getImage("zl_btn_selected"), for: .selected)
        btn.addTarget(self, action: #selector(handleSelectButtonTap), for: .touchUpInside)
        btn.enlargeInsets = UIEdgeInsets(top: 5, left: 10, bottom: 10, right: 5)
        return btn
    }()
    
    lazy var coverView: UIView = {
        let view = UIView()
        view.isUserInteractionEnabled = false
        view.isHidden = true
        return view
    }()
    
    lazy var indexLabel: UILabel = {
        let label = UILabel()
        label.textColor = .maha.indexLabelTextColor
        label.backgroundColor = .maha.indexLabelBgColor
        if MahaPhotoUIConfiguration.default().showIndexOnSelectBtn {
            label.font = .maha.font(ofSize: 14)
            label.textAlignment = .center
            label.layer.cornerRadius = Layout.selectButtonSize / 2
            label.layer.masksToBounds = true
        } else {
            label.font = .maha.font(ofSize: 14, bold: true)
            label.textAlignment = .left
        }
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        return label
    }()
    
    var enableSelect = true {
        didSet {
            containerView.alpha = enableSelect ? 1 : 0.2
        }
    }
    
    var selectedBlock: ((@escaping (Bool) -> Void) -> Void)?
    
    var model: MahaPhotoModel! {
        didSet {
            refreshCellContent()
        }
    }
    
    var index = 0 {
        didSet {
            indexLabel.text = String(index)
        }
    }
    
    deinit {
        mahaDebugPrint("MahaThumbnailPhotoCell deinit")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        contentView.addSubview(imageView)
        contentView.addSubview(coverView)
        contentView.addSubview(containerView)
        containerView.addSubview(btnSelect)
        containerView.addSubview(indexLabel)
        containerView.addSubview(bottomShadowView)
        bottomShadowView.addSubview(videoTag)
        bottomShadowView.addSubview(livePhotoTag)
        bottomShadowView.addSubview(editImageTag)
        bottomShadowView.addSubview(descLabel)
        containerView.addSubview(progressView)
        
        if MahaPhotoUIConfiguration.default().showSelectedBorder {
            layer.borderColor = UIColor.maha.selectedBorderColor.cgColor
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        imageView.frame = bounds
        
        containerView.frame = bounds
        coverView.frame = bounds
        btnSelect.frame = CGRect(
            x: bounds.width - Layout.selectButtonRightInset,
            y: Layout.selectButtonTopInset,
            width: Layout.selectButtonSize,
            height: Layout.selectButtonSize
        )
        if MahaPhotoUIConfiguration.default().showIndexOnSelectBtn {
            indexLabel.frame = btnSelect.frame
        } else {
            indexLabel.frame = CGRect(
                x: Layout.indexLabelLeftInset,
                y: Layout.indexLabelTopInset,
                width: 50,
                height: Layout.selectButtonSize
            )
        }
        
        bottomShadowView.frame = CGRect(x: 0, y: bounds.height - Layout.bottomShadowHeight, width: bounds.width, height: Layout.bottomShadowHeight)
        videoTag.frame = CGRect(x: 5, y: 1, width: 20, height: 15)
        livePhotoTag.frame = CGRect(x: 5, y: -1, width: 20, height: 20)
        editImageTag.frame = CGRect(x: 5, y: -1, width: 20, height: 20)
        descLabel.frame = CGRect(x: 30, y: 1, width: bounds.width - 35, height: 17)
        progressView.frame = CGRect(
            x: (bounds.width - Layout.progressViewSize) / 2,
            y: (bounds.height - Layout.progressViewSize) / 2,
            width: Layout.progressViewSize,
            height: Layout.progressViewSize
        )
    }
    
    @objc func handleSelectButtonTap() {
        selectedBlock?({ [weak self] isSelected in
            self?.btnSelect.isSelected = isSelected
            self?.btnSelect.layer.removeAllAnimations()
            
            if isSelected,
               MahaPhotoUIConfiguration.default().animateSelectBtnWhenSelectInThumbVC {
                self?.btnSelect.layer.add(MahaAnimationUtils.springAnimation(), forKey: nil)
            }
            
            if isSelected {
                self?.requestOriginalImage()
            } else {
                self?.progressView.isHidden = true
                self?.cancelOriginalImageRequest()
            }
        })
    }
    
    private func refreshCellContent() {
        let config = MahaPhotoConfiguration.default()
        let uiConfig = MahaPhotoUIConfiguration.default()
        
        if uiConfig.cellCornerRadio > 0 {
            layer.cornerRadius = MahaPhotoUIConfiguration.default().cellCornerRadio
            layer.masksToBounds = true
        }
        
        if model.type == .video {
            bottomShadowView.isHidden = false
            videoTag.isHidden = false
            livePhotoTag.isHidden = true
            editImageTag.isHidden = true
            descLabel.text = model.duration
        } else if model.type == .gif {
            bottomShadowView.isHidden = !config.allowSelectGif
            videoTag.isHidden = true
            livePhotoTag.isHidden = true
            editImageTag.isHidden = true
            descLabel.text = "GIF"
        } else if model.type == .livePhoto {
            bottomShadowView.isHidden = !config.allowSelectLivePhoto
            videoTag.isHidden = true
            livePhotoTag.isHidden = false
            editImageTag.isHidden = true
            descLabel.text = "Live"
        } else {
            if let _ = model.editImage {
                bottomShadowView.isHidden = false
                videoTag.isHidden = true
                livePhotoTag.isHidden = true
                editImageTag.isHidden = false
                descLabel.text = ""
            } else {
                bottomShadowView.isHidden = true
            }
        }
        
        let showSelBtn: Bool
        if config.maxSelectCount > 1 {
            if !config.allowMixSelect {
                showSelBtn = model.type.rawValue < MahaPhotoModel.MediaType.video.rawValue
            } else {
                showSelBtn = true
            }
        } else {
            showSelBtn = config.showSelectBtnWhenSingleSelect
        }
        
        btnSelect.isHidden = !showSelBtn
        btnSelect.isUserInteractionEnabled = showSelBtn
        btnSelect.isSelected = model.isSelected
        
        if model.isSelected {
            requestOriginalImage()
        } else {
            cancelOriginalImageRequest()
        }
        
        if let editImage = model.editImage {
            imageView.image = editImage
        } else {
            requestThumbnailImage()
        }
    }
    
    private func requestThumbnailImage() {
        let size: CGSize
        let maxSideLength = bounds.width * 2
        if model.whRatio > 1 {
            let w = maxSideLength * model.whRatio
            size = CGSize(width: w, height: maxSideLength)
        } else {
            let h = maxSideLength / model.whRatio
            size = CGSize(width: maxSideLength, height: h)
        }
        
        if thumbnailImageRequestID > PHInvalidImageRequestID {
            PHImageManager.default().cancelImageRequest(thumbnailImageRequestID)
        }
        
        displayedImageIdentifier = model.ident
        imageView.image = nil
        thumbnailImageRequestID = MahaPhotoManager.fetchImage(for: model.asset, size: size, completion: { [weak self] image, isDegraded in
            if self?.displayedImageIdentifier == self?.model.ident {
                self?.imageView.image = image
            }
            if !isDegraded {
                self?.thumbnailImageRequestID = PHInvalidImageRequestID
            }
        })
    }
    
    private func requestOriginalImage() {
        cancelOriginalImageRequest()
        
        originalImageRequestID = MahaPhotoManager.fetchOriginalImageData(for: model.asset, progress: { [weak self] progress, _, _, _ in
            if self?.model.isSelected == true {
                self?.progressView.isHidden = false
                self?.progressView.progress = max(0.1, progress)
                self?.imageView.alpha = 0.5
                if progress >= 1 {
                    self?.resetOriginalImageProgress()
                }
            } else {
                self?.cancelOriginalImageRequest()
            }
        }, completion: { [weak self] _, _, _ in
            self?.resetOriginalImageProgress()
        })
    }
    
    private func cancelOriginalImageRequest() {
        if originalImageRequestID > PHInvalidImageRequestID {
            PHImageManager.default().cancelImageRequest(originalImageRequestID)
        }
        resetOriginalImageProgress()
    }
    
    private func resetOriginalImageProgress() {
        progressView.isHidden = true
        imageView.alpha = 1
    }
}
