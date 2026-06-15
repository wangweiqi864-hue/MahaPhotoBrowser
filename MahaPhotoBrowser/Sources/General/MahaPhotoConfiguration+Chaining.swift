//
//  MahaPhotoConfiguration+Chaining.swift
//  MahaPhotoBrowser
//
//  Created by long on 2021/11/1.
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

public extension MahaPhotoConfiguration {
    @discardableResult
    func maxSelectCount(_ count: Int) -> MahaPhotoConfiguration {
        maxSelectCount = count
        return self
    }
    
    @discardableResult
    func maxVideoSelectCount(_ count: Int) -> MahaPhotoConfiguration {
        maxVideoSelectCount = count
        return self
    }
    
    @discardableResult
    func minVideoSelectCount(_ count: Int) -> MahaPhotoConfiguration {
        minVideoSelectCount = count
        return self
    }
    
    @discardableResult
    func allowMixSelect(_ value: Bool) -> MahaPhotoConfiguration {
        allowMixSelect = value
        return self
    }
    
    @discardableResult
    func maxPreviewCount(_ count: Int) -> MahaPhotoConfiguration {
        maxPreviewCount = count
        return self
    }
    
    @discardableResult
    func initialIndex(_ index: Int) -> MahaPhotoConfiguration {
        initialIndex = index
        return self
    }
    
    @discardableResult
    func allowSelectImage(_ value: Bool) -> MahaPhotoConfiguration {
        allowSelectImage = value
        return self
    }
    
    @discardableResult
    @objc func allowSelectVideo(_ value: Bool) -> MahaPhotoConfiguration {
        allowSelectVideo = value
        return self
    }
    
    @discardableResult
    @objc func downloadVideoBeforeSelecting(_ value: Bool) -> MahaPhotoConfiguration {
        downloadVideoBeforeSelecting = value
        return self
    }
    
    @discardableResult
    func allowSelectGif(_ value: Bool) -> MahaPhotoConfiguration {
        allowSelectGif = value
        return self
    }
    
    @discardableResult
    func allowSelectLivePhoto(_ value: Bool) -> MahaPhotoConfiguration {
        allowSelectLivePhoto = value
        return self
    }
    
    @discardableResult
    func allowTakePhotoInLibrary(_ value: Bool) -> MahaPhotoConfiguration {
        allowTakePhotoInLibrary = value
        return self
    }
    
    @discardableResult
    func callbackDirectlyAfterTakingPhoto(_ value: Bool) -> MahaPhotoConfiguration {
        callbackDirectlyAfterTakingPhoto = value
        return self
    }
    
    @discardableResult
    func allowEditImage(_ value: Bool) -> MahaPhotoConfiguration {
        allowEditImage = value
        return self
    }
    
    @discardableResult
    func allowEditVideo(_ value: Bool) -> MahaPhotoConfiguration {
        allowEditVideo = value
        return self
    }
    
    @discardableResult
    func editAfterSelectThumbnailImage(_ value: Bool) -> MahaPhotoConfiguration {
        editAfterSelectThumbnailImage = value
        return self
    }
    
    @discardableResult
    func cropVideoAfterSelectThumbnail(_ value: Bool) -> MahaPhotoConfiguration {
        cropVideoAfterSelectThumbnail = value
        return self
    }
    
    @discardableResult
    func saveNewImageAfterEdit(_ value: Bool) -> MahaPhotoConfiguration {
        saveNewImageAfterEdit = value
        return self
    }
    
    @discardableResult
    func allowSlideSelect(_ value: Bool) -> MahaPhotoConfiguration {
        allowSlideSelect = value
        return self
    }
    
    @discardableResult
    func autoScrollWhenSlideSelectIsActive(_ value: Bool) -> MahaPhotoConfiguration {
        autoScrollWhenSlideSelectIsActive = value
        return self
    }
    
    @discardableResult
    func autoScrollMaxSpeed(_ speed: CGFloat) -> MahaPhotoConfiguration {
        autoScrollMaxSpeed = speed
        return self
    }
    
    @discardableResult
    func allowDragSelect(_ value: Bool) -> MahaPhotoConfiguration {
        allowDragSelect = value
        return self
    }
    
    @discardableResult
    func allowSelectOriginal(_ value: Bool) -> MahaPhotoConfiguration {
        allowSelectOriginal = value
        return self
    }
    
    @discardableResult
    func alwaysRequestOriginal(_ value: Bool) -> MahaPhotoConfiguration {
        alwaysRequestOriginal = value
        return self
    }
    
    @discardableResult
    func allowPreviewPhotos(_ value: Bool) -> MahaPhotoConfiguration {
        allowPreviewPhotos = value
        return self
    }
    
    @discardableResult
    func showPreviewButtonInAlbum(_ value: Bool) -> MahaPhotoConfiguration {
        showPreviewButtonInAlbum = value
        return self
    }
    
    @discardableResult
    func showSelectCountOnDoneBtn(_ value: Bool) -> MahaPhotoConfiguration {
        showSelectCountOnDoneBtn = value
        return self
    }
    
    @discardableResult
    func showSelectBtnWhenSingleSelect(_ value: Bool) -> MahaPhotoConfiguration {
        showSelectBtnWhenSingleSelect = value
        return self
    }
    
    @discardableResult
    func showSelectedIndex(_ value: Bool) -> MahaPhotoConfiguration {
        showSelectedIndex = value
        return self
    }
    
    @discardableResult
    func maxEditVideoTime(_ second: Second) -> MahaPhotoConfiguration {
        maxEditVideoTime = second
        return self
    }
    
    @discardableResult
    func maxSelectVideoDuration(_ duration: Second) -> MahaPhotoConfiguration {
        maxSelectVideoDuration = duration
        return self
    }
    
    @discardableResult
    func minSelectVideoDuration(_ duration: Second) -> MahaPhotoConfiguration {
        minSelectVideoDuration = duration
        return self
    }
    
    @discardableResult
    func maxSelectVideoDataSize(_ size: MahaPhotoConfiguration.KBUnit) -> MahaPhotoConfiguration {
        maxSelectVideoDataSize = size
        return self
    }
    
    @discardableResult
    func minSelectVideoDataSize(_ size: MahaPhotoConfiguration.KBUnit) -> MahaPhotoConfiguration {
        minSelectVideoDataSize = size
        return self
    }
    
    @discardableResult
    func editImageConfiguration(_ configuration: MahaEditImageConfiguration) -> MahaPhotoConfiguration {
        editImageConfiguration = configuration
        return self
    }
    
    @discardableResult
    func useCustomCamera(_ value: Bool) -> MahaPhotoConfiguration {
        useCustomCamera = value
        return self
    }
    
    @discardableResult
    func cameraConfiguration(_ configuration: MahaCameraConfiguration) -> MahaPhotoConfiguration {
        cameraConfiguration = configuration
        return self
    }
    
    @discardableResult
    func canSelectAsset(_ block: ((PHAsset) -> Bool)?) -> MahaPhotoConfiguration {
        canSelectAsset = block
        return self
    }
    
    @discardableResult
    func didSelectAsset(_ block: ((PHAsset) -> Void)?) -> MahaPhotoConfiguration {
        didSelectAsset = block
        return self
    }
    
    @discardableResult
    func didDeselectAsset(_ block: ((PHAsset) -> Void)?) -> MahaPhotoConfiguration {
        didDeselectAsset = block
        return self
    }
    
    @discardableResult
    func canEnterCamera(_ block: (() -> Bool)?) -> MahaPhotoConfiguration {
        canEnterCamera = block
        return self
    }
    
    @discardableResult
    func maxFrameCountForGIF(_ frameCount: Int) -> MahaPhotoConfiguration {
        maxFrameCountForGIF = frameCount
        return self
    }
    
    @discardableResult
    func gifPlayBlock(_ block: ((UIImageView, Data, [AnyHashable: Any]?) -> Void)?) -> MahaPhotoConfiguration {
        gifPlayBlock = block
        return self
    }
    
    @discardableResult
    func pauseGIFBlock(_ block: ((UIImageView) -> Void)?) -> MahaPhotoConfiguration {
        pauseGIFBlock = block
        return self
    }
    
    @discardableResult
    func resumeGIFBlock(_ block: ((UIImageView) -> Void)?) -> MahaPhotoConfiguration {
        resumeGIFBlock = block
        return self
    }
    
    @discardableResult
    func noAuthorityCallback(_ callback: ((MahaNoAuthorityType) -> Void)?) -> MahaPhotoConfiguration {
        noAuthorityCallback = callback
        return self
    }
    
    @discardableResult
    func customAlertWhenNoAuthority(_ callback: ((MahaNoAuthorityType) -> Void)?) -> MahaPhotoConfiguration {
        customAlertWhenNoAuthority = callback
        return self
    }
    
    @discardableResult
    func operateBeforeDoneAction(_ block: ((UIViewController, @escaping () -> Void) -> Void)?) -> MahaPhotoConfiguration {
        operateBeforeDoneAction = block
        return self
    }
}
