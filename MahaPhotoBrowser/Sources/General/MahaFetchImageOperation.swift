//
//  MahaFetchImageOperation.swift
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

class MahaFetchImageOperation: Operation, @unchecked Sendable {
    private let model: MahaPhotoModel
    
    private let isOriginal: Bool
    
    private let progress: ((CGFloat, Error?, UnsafeMutablePointer<ObjCBool>, [AnyHashable: Any]?) -> Void)?
    
    private let completion: (UIImage?, PHAsset?) -> Void
    
    private var isOperationExecuting = false {
        willSet {
            self.willChangeValue(forKey: "isExecuting")
        }
        didSet {
            self.didChangeValue(forKey: "isExecuting")
        }
    }
    
    override var isExecuting: Bool {
        return isOperationExecuting
    }
    
    private var isOperationFinished = false {
        willSet {
            self.willChangeValue(forKey: "isFinished")
        }
        didSet {
            self.didChangeValue(forKey: "isFinished")
        }
    }
    
    override var isFinished: Bool {
        return isOperationFinished
    }
    
    private var isOperationCancelled = false {
        willSet {
            willChangeValue(forKey: "isCancelled")
        }
        didSet {
            didChangeValue(forKey: "isCancelled")
        }
    }
    
    private var imageRequestID = PHInvalidImageRequestID
    
    override var isCancelled: Bool {
        return isOperationCancelled
    }
    
    init(
        model: MahaPhotoModel,
        isOriginal: Bool,
        progress: ((CGFloat, Error?, UnsafeMutablePointer<ObjCBool>, [AnyHashable: Any]?) -> Void)? = nil,
        completion: @escaping ((UIImage?, PHAsset?) -> Void)
    ) {
        self.model = model
        self.isOriginal = isOriginal
        self.progress = progress
        self.completion = completion
        super.init()
    }
    
    override func start() {
        if isCancelled {
            finishFetching()
            return
        }
        mahaDebugPrint("---- start fetch")
        isOperationExecuting = true
        
        // 存在编辑的图片
        if let editImage = model.editImage {
            if MahaPhotoConfiguration.default().saveNewImageAfterEdit {
                MahaPhotoManager.saveImageToAlbum(image: editImage) { [weak self] _, asset in
                    self?.completion(editImage, asset)
                    self?.finishFetching()
                }
            } else {
                MahaMainAsync {
                    self.completion(editImage, nil)
                    self.finishFetching()
                }
            }
            return
        }
        
        if MahaPhotoConfiguration.default().allowSelectGif, model.type == .gif {
            imageRequestID = MahaPhotoManager.fetchOriginalImageData(for: model.asset) { [weak self] data, _, isDegraded in
                if !isDegraded {
                    let image = UIImage.maha.animateGifImage(data: data)
                    self?.completion(image, nil)
                    self?.finishFetching()
                }
            }
            return
        }
        
        if isOriginal {
            imageRequestID = MahaPhotoManager.fetchOriginalImage(for: model.asset, progress: progress) { [weak self] image, isDegraded in
                if !isDegraded {
                    mahaDebugPrint("---- 原图加载完成 \(String(describing: self?.isCancelled))")
                    self?.completion(image?.maha.fixOrientation(), nil)
                    self?.finishFetching()
                }
            }
        } else {
            imageRequestID = MahaPhotoManager.fetchImage(for: model.asset, size: model.previewSize, progress: progress) { [weak self] image, isDegraded in
                if !isDegraded {
                    mahaDebugPrint("---- 加载完成 isCancelled: \(String(describing: self?.isCancelled))")
                    self?.completion(self?.makeCompressedImageIfNeeded(from: image?.maha.fixOrientation()), nil)
                    self?.finishFetching()
                }
            }
        }
    }
    
    override func cancel() {
        super.cancel()
        mahaDebugPrint("---- cancel \(isExecuting) \(imageRequestID)")
        PHImageManager.default().cancelImageRequest(imageRequestID)
        isOperationCancelled = true
        if isExecuting {
            finishFetching()
        }
    }
    
    private func makeCompressedImageIfNeeded(from image: UIImage?) -> UIImage? {
        guard let image else {
            return nil
        }
        guard let originalData = image.jpegData(compressionQuality: 1) else {
            return image
        }
        let megaByteUnit: CGFloat = 1024 * 1024
        
        if originalData.count < Int(0.2 * megaByteUnit) {
            return image
        }
        let compressionQuality: CGFloat = originalData.count > Int(megaByteUnit) ? 0.6 : 0.8
        
        guard let compressedData = image.jpegData(compressionQuality: compressionQuality) else {
            return image
        }
        return UIImage(data: compressedData)
    }
    
    private func finishFetching() {
        isOperationExecuting = false
        isOperationFinished = true
    }
}
