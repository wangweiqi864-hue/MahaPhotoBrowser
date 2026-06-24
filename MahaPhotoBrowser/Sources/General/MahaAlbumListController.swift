//
//  MahaAlbumListController.swift
//  MahaPhotoBrowser
//
//  Created by long on 2020/8/18.
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

class MahaAlbumListController: UIViewController {
    private enum Layout {
        static let navigationBarHeight: CGFloat = 44
    }

    private lazy var navView = MahaExternalAlbumListNavView(title: localLanguageTextValue(.photo))

    private var navBlurView: UIVisualEffectView?

    private lazy var tableView: UITableView = {
        let view = UITableView(frame: .zero, style: .plain)
        view.backgroundColor = .maha.albumListBgColor
        view.tableFooterView = UIView()
        view.rowHeight = 65
        view.separatorInset = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 0)
        view.separatorColor = .maha.separatorLineColor
        view.delegate = self
        view.dataSource = self

        if #available(iOS 11.0, *) {
            view.contentInsetAdjustmentBehavior = .always
        }

        MahaAlbumListCell.maha.register(view)
        return view
    }()

    private var albumListModels: [MahaAlbumListModel] = []

    private var needsAlbumReload = true

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return MahaPhotoUIConfiguration.default().statusBarStyle
    }

    deinit {
        mahaDebugPrint("MahaAlbumListController deinit")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        PHPhotoLibrary.shared().register(self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true

        reloadAlbumListIfNeeded()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        var insets = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        var tableContentInsetTop: CGFloat = 20
        if #available(iOS 11.0, *) {
            insets = view.safeAreaInsets
            tableContentInsetTop = Layout.navigationBarHeight
        } else {
            tableContentInsetTop += Layout.navigationBarHeight
        }

        navView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: insets.top + Layout.navigationBarHeight)

        tableView.frame = CGRect(x: insets.left, y: 0, width: view.frame.width - insets.left - insets.right, height: view.frame.height)
        tableView.contentInset = UIEdgeInsets(top: tableContentInsetTop, left: 0, bottom: 0, right: 0)
        tableView.scrollIndicatorInsets = UIEdgeInsets(top: Layout.navigationBarHeight, left: 0, bottom: 0, right: 0)
    }

    private func setupUI() {
        view.backgroundColor = .maha.albumListBgColor

        view.addSubview(tableView)

        navView.backBtn.isHidden = true
        navView.cancelBlock = { [weak self] in
            let nav = self?.navigationController as? MahaImageNavController
            nav?.cancelHandler?()
            nav?.dismiss(animated: true, completion: nil)
        }
        view.addSubview(navView)
    }

    private func reloadAlbumListIfNeeded() {
        guard needsAlbumReload else {
            return
        }

        fetchAlbumList()
    }

    private func fetchAlbumList() {
        DispatchQueue.global().async {
            MahaPhotoManager.getPhotoAlbumList(
                ascending: MahaPhotoUIConfiguration.default().sortAscending,
                allowSelectImage: MahaPhotoConfiguration.default().allowSelectImage,
                allowSelectVideo: MahaPhotoConfiguration.default().allowSelectVideo
            ) { [weak self] albumList in
                self?.albumListModels = albumList
                self?.needsAlbumReload = false
                MahaMainAsync {
                    self?.tableView.reloadData()
                }
            }
        }
    }
}

extension MahaAlbumListController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return albumListModels.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MahaAlbumListCell.maha.identifier, for: indexPath) as! MahaAlbumListCell

        cell.configureCell(model: albumListModels[indexPath.row], style: .externalAlbumList)

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = MahaThumbnailViewController(albumList: albumListModels[indexPath.row])
        show(vc, sender: nil)
    }
}

extension MahaAlbumListController: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        needsAlbumReload = true
    }
}
