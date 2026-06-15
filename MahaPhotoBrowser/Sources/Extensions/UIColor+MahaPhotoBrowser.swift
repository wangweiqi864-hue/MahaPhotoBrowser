//
//  UIColor+MahaPhotoBrowser.swift
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

extension MahaPhotoBrowserWrapper where Base: UIColor {
    static var navBarColor: UIColor {
        MahaPhotoUIConfiguration.default().navBarColor
    }
    
    static var navBarColorOfPreviewVC: UIColor {
        MahaPhotoUIConfiguration.default().navBarColorOfPreviewVC
    }
    
    /// 相册列表界面导航标题颜色
    static var navTitleColor: UIColor {
        MahaPhotoUIConfiguration.default().navTitleColor
    }
    
    /// 预览大图界面导航标题颜色
    static var navTitleColorOfPreviewVC: UIColor {
        MahaPhotoUIConfiguration.default().navTitleColorOfPreviewVC
    }
    
    /// 框架样式为 embedAlbumList 时，title view 背景色
    static var navEmbedTitleViewBgColor: UIColor {
        MahaPhotoUIConfiguration.default().navEmbedTitleViewBgColor
    }
    
    /// 预览选择模式下 上方透明背景色
    static var previewBgColor: UIColor {
        MahaPhotoUIConfiguration.default().sheetTranslucentColor
    }
    
    /// 预览选择模式下 拍照/相册/取消 的背景颜色
    static var previewBtnBgColor: UIColor {
        MahaPhotoUIConfiguration.default().sheetBtnBgColor
    }
    
    /// 预览选择模式下 拍照/相册/取消 的字体颜色
    static var previewBtnTitleColor: UIColor {
        MahaPhotoUIConfiguration.default().sheetBtnTitleColor
    }
    
    /// 预览选择模式下 选择照片大于0时，取消按钮title颜色
    static var previewBtnHighlightTitleColor: UIColor {
        MahaPhotoUIConfiguration.default().sheetBtnTitleTintColor
    }
    
    /// 相册列表界面背景色
    static var albumListBgColor: UIColor {
        MahaPhotoUIConfiguration.default().albumListBgColor
    }
    
    /// 嵌入式相册列表下方透明区域颜色
    static var embedAlbumListTranslucentColor: UIColor {
        MahaPhotoUIConfiguration.default().embedAlbumListTranslucentColor
    }
    
    /// 相册列表界面 相册title颜色
    static var albumListTitleColor: UIColor {
        MahaPhotoUIConfiguration.default().albumListTitleColor
    }
    
    /// 相册列表界面 数量label颜色
    static var albumListCountColor: UIColor {
        MahaPhotoUIConfiguration.default().albumListCountColor
    }
    
    /// 分割线颜色
    static var separatorLineColor: UIColor {
        MahaPhotoUIConfiguration.default().separatorColor
    }
    
    /// 小图界面背景色
    static var thumbnailBgColor: UIColor {
        MahaPhotoUIConfiguration.default().thumbnailBgColor
    }
    
    /// 预览大图界面背景色
    static var previewVCBgColor: UIColor {
        MahaPhotoUIConfiguration.default().previewVCBgColor
    }
    
    /// 无相册访问权限时，提示标题和描述的文本颜色
    static var noLibraryAuthTitleAndDescColor: UIColor {
        MahaPhotoUIConfiguration.default().noLibraryAuthTitleAndDescColor
    }
    
    /// 无相册访问权限时，前往系统设置按钮标题颜色
    static var noLibraryAuthGotoSettingBtnTitleColor: UIColor {
        MahaPhotoUIConfiguration.default().noLibraryAuthGotoSettingBtnTitleColor
    }
    
    /// 相册列表界面底部工具条底色
    static var bottomToolViewBgColor: UIColor {
        MahaPhotoUIConfiguration.default().bottomToolViewBgColor
    }
    
    /// 预览大图界面底部工具条底色
    static var bottomToolViewBgColorOfPreviewVC: UIColor {
        MahaPhotoUIConfiguration.default().bottomToolViewBgColorOfPreviewVC
    }
    
    /// 小图界面原图大小label字体颜色
    static var originalSizeLabelTextColor: UIColor {
        MahaPhotoUIConfiguration.default().originalSizeLabelTextColor
    }
    
    /// 预览大图界面原图大小label字体颜色
    static var originalSizeLabelTextColorOfPreviewVC: UIColor {
        MahaPhotoUIConfiguration.default().originalSizeLabelTextColorOfPreviewVC
    }
    
    /// 相册列表界面底部工具栏按钮 可交互 状态标题颜色
    static var bottomToolViewBtnNormalTitleColor: UIColor {
        MahaPhotoUIConfiguration.default().bottomToolViewBtnNormalTitleColor
    }
    
    /// 相册列表界面底部工具栏 `完成` 按钮 可交互 状态标题颜色
    static var bottomToolViewDoneBtnNormalTitleColor: UIColor {
        MahaPhotoUIConfiguration.default().bottomToolViewDoneBtnNormalTitleColor
    }
    
    /// 预览大图界面底部工具栏按钮 可交互 状态标题颜色
    static var bottomToolViewBtnNormalTitleColorOfPreviewVC: UIColor {
        MahaPhotoUIConfiguration.default().bottomToolViewBtnNormalTitleColorOfPreviewVC
    }
    
    /// 预览大图界面底部工具栏 `完成` 按钮 可交互 状态标题颜色
    static var bottomToolViewDoneBtnNormalTitleColorOfPreviewVC: UIColor {
        MahaPhotoUIConfiguration.default().bottomToolViewDoneBtnNormalTitleColorOfPreviewVC
    }
    
    /// 相册列表界面底部工具栏按钮 不可交互 状态标题颜色
    static var bottomToolViewBtnDisableTitleColor: UIColor {
        MahaPhotoUIConfiguration.default().bottomToolViewBtnDisableTitleColor
    }
    
    /// 相册列表界面底部工具栏 `完成` 按钮 不可交互 状态标题颜色
    static var bottomToolViewDoneBtnDisableTitleColor: UIColor {
        MahaPhotoUIConfiguration.default().bottomToolViewDoneBtnDisableTitleColor
    }
    
    /// 预览大图界面底部工具栏按钮 不可交互 状态标题颜色
    static var bottomToolViewBtnDisableTitleColorOfPreviewVC: UIColor {
        MahaPhotoUIConfiguration.default().bottomToolViewBtnDisableTitleColorOfPreviewVC
    }
    
    /// 预览大图界面底部工具栏 `完成` 按钮 不可交互 状态标题颜色
    static var bottomToolViewDoneBtnDisableTitleColorOfPreviewVC: UIColor {
        MahaPhotoUIConfiguration.default().bottomToolViewDoneBtnDisableTitleColorOfPreviewVC
    }
    
    /// 相册列表界面底部工具栏按钮 可交互 状态背景颜色
    static var bottomToolViewBtnNormalBgColor: UIColor {
        MahaPhotoUIConfiguration.default().bottomToolViewBtnNormalBgColor
    }
    
    /// 预览大图界面底部工具栏按钮 可交互 状态背景颜色
    static var bottomToolViewBtnNormalBgColorOfPreviewVC: UIColor {
        MahaPhotoUIConfiguration.default().bottomToolViewBtnNormalBgColorOfPreviewVC
    }
    
    /// 相册列表界面底部工具栏按钮 不可交互 状态背景颜色
    static var bottomToolViewBtnDisableBgColor: UIColor {
        MahaPhotoUIConfiguration.default().bottomToolViewBtnDisableBgColor
    }
    
    /// 预览大图界面底部工具栏按钮 不可交互 状态背景颜色
    static var bottomToolViewBtnDisableBgColorOfPreviewVC: UIColor {
        MahaPhotoUIConfiguration.default().bottomToolViewBtnDisableBgColorOfPreviewVC
    }
    
    /// iOS14 limited 权限时候，小图界面下方显示 选择更多图片 标题颜色
    static var limitedAuthorityTipsColor: UIColor {
        return MahaPhotoUIConfiguration.default().limitedAuthorityTipsColor
    }
    
    /// 自定义相机录制视频时，进度条颜色
    static var cameraRecodeProgressColor: UIColor {
        MahaPhotoUIConfiguration.default().cameraRecodeProgressColor
    }
    
    /// 已选cell遮罩层颜色
    static var selectedMaskColor: UIColor {
        MahaPhotoUIConfiguration.default().selectedMaskColor
    }
    
    /// 已选cell border颜色
    static var selectedBorderColor: UIColor {
        MahaPhotoUIConfiguration.default().selectedBorderColor
    }
    
    /// 不能选择的cell上方遮罩层颜色
    static var invalidMaskColor: UIColor {
        MahaPhotoUIConfiguration.default().invalidMaskColor
    }
    
    /// 选中图片右上角index text color
    static var indexLabelTextColor: UIColor {
        MahaPhotoUIConfiguration.default().indexLabelTextColor
    }
    
    /// 选中图片右上角index background color
    static var indexLabelBgColor: UIColor {
        MahaPhotoUIConfiguration.default().indexLabelBgColor
    }
    
    /// 拍照cell 背景颜色
    static var cameraCellBgColor: UIColor {
        MahaPhotoUIConfiguration.default().cameraCellBgColor
    }
    
    /// 调整图片slider默认色
    static var adjustSliderNormalColor: UIColor {
        MahaPhotoUIConfiguration.default().adjustSliderNormalColor
    }
    
    /// 调整图片slider高亮色
    static var adjustSliderTintColor: UIColor {
        MahaPhotoUIConfiguration.default().adjustSliderTintColor
    }
    
    /// 图片编辑器中各种工具下方标题普通状态下的颜色
    static var imageEditorToolTitleNormalColor: UIColor {
        MahaPhotoUIConfiguration.default().imageEditorToolTitleNormalColor
    }
    
    /// 图片编辑器中各种工具下方标题高亮状态下的颜色
    static var imageEditorToolTitleTintColor: UIColor {
        MahaPhotoUIConfiguration.default().imageEditorToolTitleTintColor
    }
    
    /// 图片编辑器中各种工具图标高亮状态下的颜色
    static var imageEditorToolIconTintColor: UIColor? {
        MahaPhotoUIConfiguration.default().imageEditorToolIconTintColor
    }
    
    /// 编辑器中垃圾箱普通状态下的颜色
    static var trashCanBackgroundNormalColor: UIColor {
        MahaPhotoUIConfiguration.default().trashCanBackgroundNormalColor
    }
    
    /// 编辑器中垃圾箱高亮状态下的颜色
    static var trashCanBackgroundTintColor: UIColor {
        MahaPhotoUIConfiguration.default().trashCanBackgroundTintColor
    }
}

extension UIColor {
    typealias MahaARGB = (alpha: CGFloat, red: CGFloat, green: CGFloat, blue: CGFloat)
}

extension MahaPhotoBrowserWrapper where Base: UIColor {
    /// - Parameters:
    ///   - r: 0~255
    ///   - g: 0~255
    ///   - b: 0~255
    ///   - a: 0~1
    static func rgba(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat, _ a: CGFloat = 1) -> UIColor {
        return UIColor(red: r / 255, green: g / 255, blue: b / 255, alpha: a)
    }
    
    func argbTuple() -> UIColor.MahaARGB {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        base.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return (alpha, red, green, blue)
    }
}
