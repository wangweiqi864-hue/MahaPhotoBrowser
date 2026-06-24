//
//  MahaPhotoUIConfiguration+Chaining.swift
//  MahaPhotoBrowser
//
//  Created by long on 2022/4/19.
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

// MARK: chaining

public extension MahaPhotoUIConfiguration {
    @discardableResult
    func sortAscending(_ isAscending: Bool) -> MahaPhotoUIConfiguration {
        sortAscending = isAscending
        return self
    }
    
    @discardableResult
    func style(_ browserStyle: MahaPhotoBrowserStyle) -> MahaPhotoUIConfiguration {
        style = browserStyle
        return self
    }
    
    @discardableResult
    func statusBarStyle(_ preferredStyle: UIStatusBarStyle) -> MahaPhotoUIConfiguration {
        statusBarStyle = preferredStyle
        return self
    }
    
    @discardableResult
    func navCancelButtonStyle(_ cancelButtonStyle: MahaPhotoUIConfiguration.CancelButtonStyle) -> MahaPhotoUIConfiguration {
        navCancelButtonStyle = cancelButtonStyle
        return self
    }
    
    @discardableResult
    func showStatusBarInPreviewInterface(_ isVisible: Bool) -> MahaPhotoUIConfiguration {
        showStatusBarInPreviewInterface = isVisible
        return self
    }
    
    @discardableResult
    func hudStyle(_ style: MahaProgressHUD.Style) -> MahaPhotoUIConfiguration {
        hudStyle = style
        return self
    }
    
    @discardableResult
    func adjustSliderType(_ type: MahaAdjustSliderType) -> MahaPhotoUIConfiguration {
        adjustSliderType = type
        return self
    }
    
    @discardableResult
    func cellCornerRadio(_ cornerRadio: CGFloat) -> MahaPhotoUIConfiguration {
        cellCornerRadio = cornerRadio
        return self
    }
    
    @discardableResult
    func customAlertClass(_ alertClass: MahaCustomAlertProtocol.Type?) -> MahaPhotoUIConfiguration {
        customAlertClass = alertClass
        return self
    }
    
    /// - Note: This property is ignored when using columnCountBlock.
    @discardableResult
    func columnCount(_ count: Int) -> MahaPhotoUIConfiguration {
        columnCount = count
        return self
    }
    
    @discardableResult
    func columnCountBlock(_ block: ((_ collectionViewWidth: CGFloat) -> Int)?) -> MahaPhotoUIConfiguration {
        columnCountBlock = block
        return self
    }
    
    @discardableResult
    func minimumInteritemSpacing(_ value: CGFloat) -> MahaPhotoUIConfiguration {
        minimumInteritemSpacing = value
        return self
    }
    
    @discardableResult
    func minimumLineSpacing(_ value: CGFloat) -> MahaPhotoUIConfiguration {
        minimumLineSpacing = value
        return self
    }
    
    @discardableResult
    func animateSelectBtnWhenSelectInThumbVC(_ animate: Bool) -> MahaPhotoUIConfiguration {
        animateSelectBtnWhenSelectInThumbVC = animate
        return self
    }
    
    @discardableResult
    func animateSelectBtnWhenSelectInPreviewVC(_ animate: Bool) -> MahaPhotoUIConfiguration {
        animateSelectBtnWhenSelectInPreviewVC = animate
        return self
    }
    
    @discardableResult
    func selectBtnAnimationDuration(_ duration: CFTimeInterval) -> MahaPhotoUIConfiguration {
        selectBtnAnimationDuration = duration
        return self
    }
    
    @discardableResult
    func showIndexOnSelectBtn(_ value: Bool) -> MahaPhotoUIConfiguration {
        showIndexOnSelectBtn = value
        return self
    }
    
    @discardableResult
    func showScrollToBottomBtn(_ value: Bool) -> MahaPhotoUIConfiguration {
        showScrollToBottomBtn = value
        return self
    }
    
    @discardableResult
    func showCaptureImageOnTakePhotoBtn(_ value: Bool) -> MahaPhotoUIConfiguration {
        showCaptureImageOnTakePhotoBtn = value
        return self
    }
    
    @discardableResult
    func showSelectedMask(_ value: Bool) -> MahaPhotoUIConfiguration {
        showSelectedMask = value
        return self
    }
    
    @discardableResult
    func showSelectedBorder(_ value: Bool) -> MahaPhotoUIConfiguration {
        showSelectedBorder = value
        return self
    }
    
    @discardableResult
    func showInvalidMask(_ value: Bool) -> MahaPhotoUIConfiguration {
        showInvalidMask = value
        return self
    }
    
    @discardableResult
    func showSelectedPhotoPreview(_ value: Bool) -> MahaPhotoUIConfiguration {
        showSelectedPhotoPreview = value
        return self
    }
    
    @discardableResult
    func showAddPhotoButton(_ value: Bool) -> MahaPhotoUIConfiguration {
        showAddPhotoButton = value
        return self
    }
    
    @discardableResult
    func showEnterSettingTips(_ value: Bool) -> MahaPhotoUIConfiguration {
        showEnterSettingTips = value
        return self
    }
    
    @discardableResult
    func timeout(_ timeout: TimeInterval) -> MahaPhotoUIConfiguration {
        self.timeout = timeout
        return self
    }
    
    @discardableResult
    func navViewBlurEffectOfAlbumList(_ effect: UIBlurEffect?) -> MahaPhotoUIConfiguration {
        navViewBlurEffectOfAlbumList = effect
        return self
    }
    
    @discardableResult
    func navViewBlurEffectOfPreview(_ effect: UIBlurEffect?) -> MahaPhotoUIConfiguration {
        navViewBlurEffectOfPreview = effect
        return self
    }
    
    @discardableResult
    func bottomViewBlurEffectOfAlbumList(_ effect: UIBlurEffect?) -> MahaPhotoUIConfiguration {
        bottomViewBlurEffectOfAlbumList = effect
        return self
    }
    
    @discardableResult
    func bottomViewBlurEffectOfPreview(_ effect: UIBlurEffect?) -> MahaPhotoUIConfiguration {
        bottomViewBlurEffectOfPreview = effect
        return self
    }
    
    @discardableResult
    func customImageNames(_ names: [String]) -> MahaPhotoUIConfiguration {
        customImageNames = names
        return self
    }
    
    @discardableResult
    func customImageForKey(_ map: [String: UIImage?]) -> MahaPhotoUIConfiguration {
        customImageForKey = map
        return self
    }
    
    @discardableResult
    func languageType(_ type: MahaLanguageType) -> MahaPhotoUIConfiguration {
        languageType = type
        return self
    }
    
    @discardableResult
    func customLanguageKeyValue(_ map: [MahaLocalLanguageKey: String]) -> MahaPhotoUIConfiguration {
        customLanguageKeyValue = map
        return self
    }
    
    @discardableResult
    func themeFontName(_ name: String) -> MahaPhotoUIConfiguration {
        themeFontName = name
        return self
    }
    
    @discardableResult
    func themeColor(_ color: UIColor) -> MahaPhotoUIConfiguration {
        themeColor = color
        return self
    }
    
    @discardableResult
    func sheetTranslucentColor(_ color: UIColor) -> MahaPhotoUIConfiguration {
        sheetTranslucentColor = color
        return self
    }
    
    @discardableResult
    func sheetBtnBgColor(_ color: UIColor) -> MahaPhotoUIConfiguration {
        sheetBtnBgColor = color
        return self
    }
    
    @discardableResult
    func sheetBtnTitleColor(_ color: UIColor) -> MahaPhotoUIConfiguration {
        sheetBtnTitleColor = color
        return self
    }
    
    @discardableResult
    func sheetBtnTitleTintColor(_ color: UIColor) -> MahaPhotoUIConfiguration {
        sheetBtnTitleTintColor = color
        return self
    }
    
    @discardableResult
    func navBarColor(_ color: UIColor) -> MahaPhotoUIConfiguration {
        navBarColor = color
        return self
    }
    
    @discardableResult
    func navBarColorOfPreviewVC(_ color: UIColor) -> MahaPhotoUIConfiguration {
        navBarColorOfPreviewVC = color
        return self
    }
    
    @discardableResult
    func navTitleColor(_ color: UIColor) -> MahaPhotoUIConfiguration {
        navTitleColor = color
        return self
    }
    
    @discardableResult
    func navTitleColorOfPreviewVC(_ color: UIColor) -> MahaPhotoUIConfiguration {
        navTitleColorOfPreviewVC = color
        return self
    }
    
    @discardableResult
    func navEmbedTitleViewBgColor(_ color: UIColor) -> MahaPhotoUIConfiguration {
        navEmbedTitleViewBgColor = color
        return self
    }
    
    @discardableResult
    func albumListBgColor(_ color: UIColor) -> MahaPhotoUIConfiguration {
        albumListBgColor = color
        return self
    }
    
    @discardableResult
    func embedAlbumListTranslucentColor(_ color: UIColor) -> MahaPhotoUIConfiguration {
        embedAlbumListTranslucentColor = color
        return self
    }
    
    @discardableResult
    func albumListTitleColor(_ color: UIColor) -> MahaPhotoUIConfiguration {
        albumListTitleColor = color
        return self
    }
    
    @discardableResult
    func albumListCountColor(_ color: UIColor) -> MahaPhotoUIConfiguration {
        albumListCountColor = color
        return self
    }
    
    @discardableResult
    func separatorColor(_ color: UIColor) -> MahaPhotoUIConfiguration {
        separatorColor = color
        return self
    }
    
    @discardableResult
    func thumbnailBgColor(_ color: UIColor) -> MahaPhotoUIConfiguration {
        thumbnailBgColor = color
        return self
    }
    
    @discardableResult
    func previewVCBgColor(_ color: UIColor) -> MahaPhotoUIConfiguration {
        previewVCBgColor = color
        return self
    }
    
    @discardableResult
    func noLibraryAuthTitleAndDescColor(_ color: UIColor) -> MahaPhotoUIConfiguration {
        noLibraryAuthTitleAndDescColor = color
        return self
    }
    
    @discardableResult
    func noLibraryAuthGotoSettingBtnTitleColor(_ color: UIColor) -> MahaPhotoUIConfiguration {
        noLibraryAuthGotoSettingBtnTitleColor = color
        return self
    }
    
    @discardableResult
    func bottomToolViewBgColor(_ color: UIColor) -> MahaPhotoUIConfiguration {
        bottomToolViewBgColor = color
        return self
    }
    
    @discardableResult
    func bottomToolViewBgColorOfPreviewVC(_ color: UIColor) -> MahaPhotoUIConfiguration {
        bottomToolViewBgColorOfPreviewVC = color
        return self
    }
    
    @discardableResult
    func originalSizeLabelTextColor(_ color: UIColor) -> MahaPhotoUIConfiguration {
        originalSizeLabelTextColor = color
        return self
    }
    
    @discardableResult
    func originalSizeLabelTextColorOfPreviewVC(_ color: UIColor) -> MahaPhotoUIConfiguration {
        originalSizeLabelTextColorOfPreviewVC = color
        return self
    }
    
    @discardableResult
    func bottomToolViewBtnNormalTitleColor(_ color: UIColor) -> MahaPhotoUIConfiguration {
        bottomToolViewBtnNormalTitleColor = color
        return self
    }
    
    @discardableResult
    func bottomToolViewDoneBtnNormalTitleColor(_ color: UIColor) -> MahaPhotoUIConfiguration {
        bottomToolViewDoneBtnNormalTitleColor = color
        return self
    }
    
    @discardableResult
    func bottomToolViewBtnNormalTitleColorOfPreviewVC(_ color: UIColor) -> MahaPhotoUIConfiguration {
        bottomToolViewBtnNormalTitleColorOfPreviewVC = color
        return self
    }
    
    @discardableResult
    func bottomToolViewDoneBtnNormalTitleColorOfPreviewVC(_ color: UIColor) -> MahaPhotoUIConfiguration {
        bottomToolViewDoneBtnNormalTitleColorOfPreviewVC = color
        return self
    }
    
    @discardableResult
    func bottomToolViewBtnDisableTitleColor(_ color: UIColor) -> MahaPhotoUIConfiguration {
        bottomToolViewBtnDisableTitleColor = color
        return self
    }
    
    @discardableResult
    func bottomToolViewDoneBtnDisableTitleColor(_ color: UIColor) -> MahaPhotoUIConfiguration {
        bottomToolViewDoneBtnDisableTitleColor = color
        return self
    }
    
    @discardableResult
    func bottomToolViewBtnDisableTitleColorOfPreviewVC(_ color: UIColor) -> MahaPhotoUIConfiguration {
        bottomToolViewBtnDisableTitleColorOfPreviewVC = color
        return self
    }
    
    @discardableResult
    func bottomToolViewDoneBtnDisableTitleColorOfPreviewVC(_ color: UIColor) -> MahaPhotoUIConfiguration {
        bottomToolViewDoneBtnDisableTitleColorOfPreviewVC = color
        return self
    }
    
    @discardableResult
    func bottomToolViewBtnNormalBgColor(_ color: UIColor) -> MahaPhotoUIConfiguration {
        bottomToolViewBtnNormalBgColor = color
        return self
    }
    
    @discardableResult
    func bottomToolViewBtnNormalBgColorOfPreviewVC(_ color: UIColor) -> MahaPhotoUIConfiguration {
        bottomToolViewBtnNormalBgColorOfPreviewVC = color
        return self
    }
    
    @discardableResult
    func bottomToolViewBtnDisableBgColor(_ color: UIColor) -> MahaPhotoUIConfiguration {
        bottomToolViewBtnDisableBgColor = color
        return self
    }
    
    @discardableResult
    func bottomToolViewBtnDisableBgColorOfPreviewVC(_ color: UIColor) -> MahaPhotoUIConfiguration {
        bottomToolViewBtnDisableBgColorOfPreviewVC = color
        return self
    }
    
    @discardableResult
    func limitedAuthorityTipsColor(_ color: UIColor) -> MahaPhotoUIConfiguration {
        limitedAuthorityTipsColor = color
        return self
    }
    
    @discardableResult
    func cameraRecodeProgressColor(_ color: UIColor) -> MahaPhotoUIConfiguration {
        cameraRecodeProgressColor = color
        return self
    }
    
    @discardableResult
    func selectedMaskColor(_ color: UIColor) -> MahaPhotoUIConfiguration {
        selectedMaskColor = color
        return self
    }
    
    @discardableResult
    func selectedBorderColor(_ color: UIColor) -> MahaPhotoUIConfiguration {
        selectedBorderColor = color
        return self
    }
    
    @discardableResult
    func invalidMaskColor(_ color: UIColor) -> MahaPhotoUIConfiguration {
        invalidMaskColor = color
        return self
    }
    
    @discardableResult
    func indexLabelTextColor(_ color: UIColor) -> MahaPhotoUIConfiguration {
        indexLabelTextColor = color
        return self
    }
    
    @discardableResult
    func indexLabelBgColor(_ color: UIColor) -> MahaPhotoUIConfiguration {
        indexLabelBgColor = color
        return self
    }
    
    @discardableResult
    func cameraCellBgColor(_ color: UIColor) -> MahaPhotoUIConfiguration {
        cameraCellBgColor = color
        return self
    }
    
    @discardableResult
    func adjustSliderNormalColor(_ color: UIColor) -> MahaPhotoUIConfiguration {
        adjustSliderNormalColor = color
        return self
    }
    
    @discardableResult
    func adjustSliderTintColor(_ color: UIColor) -> MahaPhotoUIConfiguration {
        adjustSliderTintColor = color
        return self
    }
    
    @discardableResult
    func imageEditorToolTitleNormalColor(_ color: UIColor) -> MahaPhotoUIConfiguration {
        imageEditorToolTitleNormalColor = color
        return self
    }
    
    @discardableResult
    func imageEditorToolTitleTintColor(_ color: UIColor) -> MahaPhotoUIConfiguration {
        imageEditorToolTitleTintColor = color
        return self
    }
    
    @discardableResult
    func imageEditorToolIconTintColor(_ color: UIColor) -> MahaPhotoUIConfiguration {
        imageEditorToolIconTintColor = color
        return self
    }
    
    @discardableResult
    func trashCanBackgroundNormalColor(_ color: UIColor) -> MahaPhotoUIConfiguration {
        trashCanBackgroundNormalColor = color
        return self
    }
    
    @discardableResult
    func trashCanBackgroundTintColor(_ color: UIColor) -> MahaPhotoUIConfiguration {
        trashCanBackgroundTintColor = color
        return self
    }
}
