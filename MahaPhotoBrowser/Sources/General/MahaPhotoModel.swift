//
//  MahaPhotoModel.swift
//  MahaPhotoBrowser
//
//  Created by long on 2020/8/11.
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

public extension MahaPhotoModel {
    enum MediaType: Int {
        case unknown = 0
        case image
        case gif
        case livePhoto
        case video
    }
}

public class MahaPhotoModel: NSObject {
    public let ident: String
    
    public let asset: PHAsset

    public var type: MahaPhotoModel.MediaType = .unknown
    
    public var duration = ""
    
    public var isSelected = false
    
    private var cachedDataSize: MahaPhotoConfiguration.KBUnit?
    
    public var dataSize: MahaPhotoConfiguration.KBUnit? {
        if let cachedDataSize = cachedDataSize {
            return cachedDataSize
        }
        
        let size = MahaPhotoManager.fetchAssetSize(for: asset)
        cachedDataSize = size
        
        return size
    }
    
    private var editedImage: UIImage?
    
    public var editImage: UIImage? {
        set {
            editedImage = newValue
        }
        get {
            guard editImageModel != nil else {
                return nil
            }
            return editedImage
        }
    }
    
    public var second: MahaPhotoConfiguration.Second {
        guard type == .video else {
            return 0
        }
        return Int(round(asset.duration))
    }
    
    public var whRatio: CGFloat {
        return CGFloat(asset.pixelWidth) / CGFloat(asset.pixelHeight)
    }
    
    public var previewSize: CGSize {
        let scale: CGFloat = UIScreen.main.scale
        if whRatio > 1 {
            let previewHeight = min(UIScreen.main.bounds.height, MahaMaxImageWidth) * scale
            let previewWidth = previewHeight * whRatio
            return CGSize(width: previewWidth, height: previewHeight)
        } else {
            let previewWidth = min(UIScreen.main.bounds.width, MahaMaxImageWidth) * scale
            let previewHeight = previewWidth / whRatio
            return CGSize(width: previewWidth, height: previewHeight)
        }
    }
    
    // Content of the last edit.
    public var editImageModel: MahaEditImageModel?
    
    public init(asset: PHAsset) {
        ident = asset.localIdentifier
        self.asset = asset
        super.init()
        
        type = transformAssetType(for: asset)
        if type == .video {
            duration = transformDuration(for: asset)
        }
    }
    
    public func transformAssetType(for asset: PHAsset) -> MahaPhotoModel.MediaType {
        switch asset.mediaType {
        case .video:
            return .video
        case .image:
            if asset.maha.isGif {
                return .gif
            }
            if asset.mediaSubtypes.contains(.photoLive) {
                return .livePhoto
            }
            return .image
        default:
            return .unknown
        }
    }
    
    public func transformDuration(for asset: PHAsset) -> String {
        let durationInSeconds = Int(round(asset.duration))
        
        switch durationInSeconds {
        case 0..<60:
            return String(format: "00:%02d", durationInSeconds)
        case 60..<3600:
            let minutes = durationInSeconds / 60
            let seconds = durationInSeconds % 60
            return String(format: "%02d:%02d", minutes, seconds)
        case 3600...:
            let hours = durationInSeconds / 3600
            let minutes = (durationInSeconds % 3600) / 60
            let seconds = durationInSeconds % 60
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        default:
            return ""
        }
    }
}

public extension MahaPhotoModel {
    static func == (lhs: MahaPhotoModel, rhs: MahaPhotoModel) -> Bool {
        return lhs.ident == rhs.ident
    }
}
