//
//  MahaPhotoPicker.swift
//  MahaPhotoBrowser
//
//  Created by long on 2025/3/12.
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

public class MahaPhotoPicker: NSObject {
    private var selectedModels: [MahaPhotoModel] = []

    private weak var presentingViewController: UIViewController?

    private weak var activePreviewSheet: MahaPhotoPreviewSheet?

    private var isOriginalSelectionEnabled = false

    private lazy var imageFetchQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 3
        return queue
    }()

    /// Success callback
    /// block params
    ///  - params1: result models
    ///  - params2: is full image
    @objc public var selectImageBlock: (([MahaResultModel], Bool) -> Void)?

    /// Callback for photos that failed to parse
    /// block params
    ///  - params1: failed assets.
    ///  - params2: index for asset
    @objc public var selectImageRequestErrorBlock: (([PHAsset], [Int]) -> Void)?

    @objc public var cancelBlock: (() -> Void)?

    deinit {
        zlLoggerInDebug("MahaPhotoPicker deinit")
    }

    @objc override public init() {
        let config = MahaPhotoConfiguration.default()
        if !config.allowSelectImage, !config.allowSelectVideo {
            assertionFailure("MahaPhotoBrowser: error configuration. The values of allowSelectImage and allowSelectVideo are both false")
            config.allowSelectImage = true
        }
    }

    /// - Parameter selectedAssets: preselected assets
    @objc public convenience init(selectedAssets: [PHAsset]? = nil) {
        self.init()

        let config = MahaPhotoConfiguration.default()
        selectedAssets?.maha.removeDuplicate().forEach { asset in
            if !config.allowMixSelect, asset.mediaType == .video {
                return
            }

            let model = MahaPhotoModel(asset: asset)
            model.isSelected = true
            self.selectedModels.append(model)
        }
    }

    /// Using this init method, you can continue editing the selected photo.
    /// - Note:
    ///     If you want to continue the last edit, you need to satisfy the value of `saveNewImageAfterEdit` is `false` at the time of the last selection.
    /// - Parameters:
    ///    - results : preselected results
    @objc public convenience init(results: [MahaResultModel]? = nil) {
        self.init()

        let config = MahaPhotoConfiguration.default()
        results?.maha.removeDuplicate().forEach { result in
            if !config.allowMixSelect, result.asset.mediaType == .video {
                return
            }

            let model = MahaPhotoModel(asset: result.asset)
            if result.isEdited {
                model.editImage = result.image
                model.editImageModel = result.editModel
            }
            model.isSelected = true
            self.selectedModels.append(model)
        }
    }

    /// - Warning: When calling this method in OC language, make sure that the `sender` is not zero
    @discardableResult
    @objc public func showPreview(animate: Bool = true, sender: UIViewController) -> MahaPhotoPreviewSheet {
        presentingViewController = sender

        let previewSheet = MahaPhotoPreviewSheet(models: selectedModels)
        previewSheet.selectPhotosBlock = { models, isOriginal in
            self.requestSelectedPhotos(models: models, isOriginalSelected: isOriginal)
        }

        previewSheet.showLibraryBlock = { models, isOriginal in
            self.replaceSelectedModels(with: models)
            self.isOriginalSelectionEnabled = isOriginal
            self.showPhotoLibrary(sender: sender)
        }

        previewSheet.cancelBlock = {
            self.cancel()
        }

        previewSheet.showPreview(sender: sender)
        activePreviewSheet = previewSheet

        return previewSheet
    }

    /// - Warning: When calling this method in OC language, make sure that the `sender` is not zero
    @discardableResult
    @objc public func showPhotoLibrary(sender: UIViewController) -> MahaImageNavController {
        presentingViewController = sender

        let navigationController = makePhotoLibraryNavigationController()

        sender.present(navigationController, animated: true) {
            self.activePreviewSheet?.hide()
        }

        return navigationController
    }

    /// 传入已选择的assets，并预览
    @objc public func previewAssets(
        sender: UIViewController,
        assets: [PHAsset],
        index: Int,
        isOriginal: Bool,
        showBottomViewAndSelectBtn: Bool = true
    ) {
        assert(!assets.isEmpty, "Assets cannot be empty")

        let models = makeSelectedModels(from: assets)

        guard !models.isEmpty else {
            return
        }

        replaceSelectedModels(with: models)
        presentingViewController = sender

        isOriginalSelectionEnabled = isOriginal

        let previewController = MahaPhotoPreviewController(photos: models, index: index, showBottomViewAndSelectBtn: showBottomViewAndSelectBtn)
        previewController.autoSelectCurrentIfNotSelectAnyone = false
        let navigationController = makeImageNavigationController(rootViewController: previewController)
        previewController.backBlock = {
            self.cancel()
        }

        sender.showDetailViewController(navigationController, sender: nil)
    }

    private func makeSelectedModels(from assets: [PHAsset]) -> [MahaPhotoModel] {
        assets.maha.removeDuplicate().map { asset in
            let model = MahaPhotoModel(asset: asset)
            model.isSelected = true
            return model
        }
    }

    private func replaceSelectedModels(with models: [MahaPhotoModel]) {
        selectedModels = models
    }

    private func makePhotoLibraryNavigationController() -> MahaImageNavController {
        let navigationController: MahaImageNavController
        if MahaPhotoUIConfiguration.default().style == .embedAlbumList {
            let thumbnailController = MahaThumbnailViewController(albumList: nil)
            navigationController = makeImageNavigationController(rootViewController: thumbnailController)
        } else {
            navigationController = makeImageNavigationController(rootViewController: MahaAlbumListController())
            let thumbnailController = MahaThumbnailViewController(albumList: nil)
            navigationController.pushViewController(thumbnailController, animated: true)
        }

        return navigationController
    }

    private func makeImageNavigationController(rootViewController: UIViewController) -> MahaImageNavController {
        let navigationController = MahaImageNavController(rootViewController: rootViewController)
        navigationController.modalPresentationStyle = .fullScreen
        navigationController.selectPhotosHandler = { [weak navigationController] in
            self.requestSelectedPhotos(
                models: navigationController?.selectedPhotoModels ?? [],
                isOriginalSelected: navigationController?.isOriginalSelectionEnabled ?? false,
                dismissing: navigationController
            )
        }

        navigationController.cancelHandler = {
            self.cancel()
        }
        navigationController.isOriginalSelectionEnabled = isOriginalSelectionEnabled
        navigationController.selectedPhotoModels = selectedModels

        return navigationController
    }

    private func cancel() {
        cancelBlock?()
    }

    /// 解析选择的图片
    private func requestSelectedPhotos(
        models: [MahaPhotoModel],
        isOriginalSelected: Bool,
        dismissing viewController: UIViewController? = nil
    ) {
        replaceSelectedModels(with: models)

        guard !selectedModels.isEmpty else {
            selectImageBlock?([], isOriginalSelected)
            activePreviewSheet?.hide()
            viewController?.dismiss(animated: true, completion: nil)
            return
        }

        let config = MahaPhotoConfiguration.default()

        if config.allowMixSelect {
            let videoCount = selectedModels.filter { $0.type == .video }.count

            if videoCount > config.maxVideoSelectCount {
                showAlertView(String(format: localLanguageTextValue(.exceededMaxVideoSelectCount), MahaPhotoConfiguration.default().maxVideoSelectCount), viewController)
                return
            } else if videoCount < config.minVideoSelectCount {
                showAlertView(String(format: localLanguageTextValue(.lessThanMinVideoSelectCount), MahaPhotoConfiguration.default().minVideoSelectCount), viewController)
                return
            }
        }

        let hud = MahaProgressHUD.show(toast: .processing, timeout: MahaPhotoUIConfiguration.default().timeout)

        var didTimeout = false
        hud.timeoutBlock = { [weak self] in
            didTimeout = true
            showAlertView(localLanguageTextValue(.timeout), viewController ?? self?.presentingViewController)
            self?.imageFetchQueue.cancelAllOperations()
        }

        let shouldRequestOriginal = config.allowSelectOriginal ? isOriginalSelected : config.alwaysRequestOriginal

        let completion = { [weak self] (successModels: [MahaResultModel], failedAssets: [PHAsset], failedIndexes: [Int]) in
            hud.hide()

            func notifySelectionResult() {
                self?.selectImageBlock?(successModels, shouldRequestOriginal)
                if !failedAssets.isEmpty {
                    self?.selectImageRequestErrorBlock?(failedAssets, failedIndexes)
                }
            }

            if let vc = viewController {
                vc.dismiss(animated: true) {
                    notifySelectionResult()
                }
            } else {
                self?.activePreviewSheet?.hide {
                    notifySelectionResult()
                }
            }

            self?.selectedModels.removeAll()
        }

        var resultsByIndex: [MahaResultModel?] = Array(repeating: nil, count: selectedModels.count)
        var failedAssets: [PHAsset] = []
        var failedIndexes: [Int] = []

        var completedCount = 0
        let totalCount = selectedModels.count

        for (index, model) in selectedModels.enumerated() {
            let operation = MahaFetchImageOperation(model: model, isOriginal: shouldRequestOriginal) { image, asset in
                guard !didTimeout else { return }

                completedCount += 1

                if let image = image {
                    let isEdited = model.editImage != nil && !config.saveNewImageAfterEdit
                    let resultModel = MahaResultModel(
                        asset: asset ?? model.asset,
                        image: image,
                        isEdited: isEdited,
                        editModel: isEdited ? model.editImageModel : nil,
                        index: index
                    )
                    resultsByIndex[index] = resultModel
                    mahaDebugPrint("MahaPhotoBrowser: suc request \(index)")
                } else {
                    failedAssets.append(model.asset)
                    failedIndexes.append(index)
                    mahaDebugPrint("MahaPhotoBrowser: failed request \(index)")
                }

                guard completedCount >= totalCount else { return }

                completion(
                    resultsByIndex.compactMap { $0 },
                    failedAssets,
                    failedIndexes
                )
            }
            imageFetchQueue.addOperation(operation)
        }
    }
}

// MARK: Methods for SwiftUI

public extension MahaPhotoPicker {
    @available(iOS, introduced: 13.0, message: "Only available for SwiftUI")
    func showPhotoLibraryForSwiftUI() -> MahaImageNavController {
        makePhotoLibraryNavigationController()
    }

    /// 传入已选择的assets，并预览
    @objc func previewAssetsForSwiftUI(
        assets: [PHAsset],
        index: Int,
        isOriginal: Bool,
        showBottomViewAndSelectBtn: Bool = true
    ) -> MahaImageNavController {
        assert(!assets.isEmpty, "Assets cannot be empty")

        let models = makeSelectedModels(from: assets)

        replaceSelectedModels(with: models)

        isOriginalSelectionEnabled = isOriginal

        let previewController = MahaPhotoPreviewController(photos: models, index: index, showBottomViewAndSelectBtn: showBottomViewAndSelectBtn)
        previewController.autoSelectCurrentIfNotSelectAnyone = false
        let navigationController = makeImageNavigationController(rootViewController: previewController)
        previewController.backBlock = {
            self.cancel()
        }

        return navigationController
    }
}
