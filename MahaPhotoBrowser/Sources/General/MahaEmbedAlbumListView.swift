//
//  MahaEmbedAlbumListView.swift
//  MahaPhotoBrowser
//
//  Created by long on 2020/9/7.
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

class MahaEmbedAlbumListView: UIView {
    static let rowHeight: CGFloat = 60

    private var selectedAlbum: MahaAlbumListModel?

    private lazy var tableContainerView = UIView()

    private lazy var tableView: UITableView = {
        let view = UITableView(frame: .zero, style: .plain)
        view.backgroundColor = .maha.albumListBgColor
        view.tableFooterView = UIView()
        view.rowHeight = MahaEmbedAlbumListView.rowHeight
        view.separatorInset = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 0)
        view.separatorColor = .maha.separatorLineColor
        view.delegate = self
        view.dataSource = self
        MahaAlbumListCell.maha.register(view)
        return view
    }()

    private var albumListModels: [MahaAlbumListModel] = []

    var selectAlbumBlock: ((MahaAlbumListModel) -> Void)?

    var hideBlock: (() -> Void)?

    private var currentOrientation: UIInterfaceOrientation = UIApplication.shared.statusBarOrientation

    init(selectedAlbum: MahaAlbumListModel?) {
        self.selectedAlbum = selectedAlbum
        super.init(frame: .zero)
        setupUI()
        loadAlbumList()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let interfaceOrientation = UIApplication.shared.statusBarOrientation

        guard interfaceOrientation != currentOrientation else {
            return
        }
        currentOrientation = interfaceOrientation

        guard !isHidden else {
            return
        }

        updateTableContainerLayout(for: calculateTableContainerFrame())
    }

    private func setupUI() {
        clipsToBounds = true

        backgroundColor = .maha.embedAlbumListTranslucentColor

        addSubview(tableContainerView)
        tableContainerView.addSubview(tableView)

        let tap = UITapGestureRecognizer(target: self, action: #selector(tapAction(_:)))
        tap.delegate = self
        addGestureRecognizer(tap)
    }

    private func loadAlbumList(completion: (() -> Void)? = nil) {
        DispatchQueue.global().async {
            MahaPhotoManager.getPhotoAlbumList(
                ascending: MahaPhotoUIConfiguration.default().sortAscending,
                allowSelectImage: MahaPhotoConfiguration.default().allowSelectImage,
                allowSelectVideo: MahaPhotoConfiguration.default().allowSelectVideo
            ) { [weak self] albumList in
                self?.albumListModels = albumList

                MahaMainAsync {
                    completion?()
                    self?.tableView.reloadData()
                }
            }
        }
    }

    private func calculateTableContainerFrame() -> CGRect {
        let contentHeight = CGFloat(albumListModels.count) * MahaEmbedAlbumListView.rowHeight

        let maxHeight: CGFloat
        if UIApplication.shared.statusBarOrientation.isPortrait {
            maxHeight = min(frame.height * 0.7, contentHeight)
        } else {
            maxHeight = min(frame.height * 0.8, contentHeight)
        }

        return CGRect(x: 0, y: 0, width: frame.width, height: maxHeight)
    }

    private func updateTableContainerLayout(for frame: CGRect) {
        let roundedPath = UIBezierPath(
            roundedRect: CGRect(x: 0, y: 0, width: frame.width, height: frame.height),
            byRoundingCorners: [.bottomLeft, .bottomRight],
            cornerRadii: CGSize(width: 8, height: 8)
        )
        let maskLayer = CAShapeLayer()
        maskLayer.path = roundedPath.cgPath
        tableContainerView.layer.mask = maskLayer
        tableContainerView.frame = frame
        tableView.frame = tableContainerView.bounds
    }

    @objc private func tapAction(_ tap: UITapGestureRecognizer) {
        hide()
        hideBlock?()
    }

    /// 这里不采用监听相册发生变化的方式，是因为每次变化，系统都会回调多次，造成重复获取相册列表
    func show(reloadAlbumList: Bool) {
        guard reloadAlbumList else {
            animateShow()
            return
        }

        if #available(iOS 14.0, *), PHPhotoLibrary.maha.authStatus(for: .readWrite) == .limited {
            loadAlbumList { [weak self] in
                self?.animateShow()
            }
        } else {
            loadAlbumList()
            animateShow()
        }
    }

    func hide() {
        var hiddenFrame = tableContainerView.frame
        hiddenFrame.origin.y = -hiddenFrame.height

        UIView.animate(withDuration: 0.25, animations: {
            self.alpha = 0
            self.tableContainerView.frame = hiddenFrame
        }) { _ in
            self.isHidden = true
            self.alpha = 1
        }
    }

    private func animateShow() {
        let visibleFrame = calculateTableContainerFrame()

        isHidden = false
        alpha = 0
        var hiddenFrame = visibleFrame
        hiddenFrame.origin.y -= hiddenFrame.height

        updateTableContainerLayout(for: hiddenFrame)
        UIView.animate(withDuration: 0.25) {
            self.alpha = 1
            self.tableContainerView.frame = visibleFrame
        }
    }
}

extension MahaEmbedAlbumListView: UIGestureRecognizerDelegate {
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let point = gestureRecognizer.location(in: self)
        return !tableContainerView.frame.contains(point)
    }
}

extension MahaEmbedAlbumListView: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return albumListModels.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MahaAlbumListCell.maha.identifier, for: indexPath) as! MahaAlbumListCell

        let albumModel = albumListModels[indexPath.row]

        cell.configureCell(model: albumModel, style: .embedAlbumList)

        cell.selectBtn.isSelected = albumModel == selectedAlbum

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let albumModel = albumListModels[indexPath.row]
        selectedAlbum = albumModel
        selectAlbumBlock?(albumModel)
        hide()
        if let indexPaths = tableView.indexPathsForVisibleRows {
            tableView.reloadRows(at: indexPaths, with: .none)
        }
    }
}
