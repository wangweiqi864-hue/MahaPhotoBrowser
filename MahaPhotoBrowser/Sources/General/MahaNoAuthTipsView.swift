//
//  MahaNoAuthTipsView.swift
//  MahaPhotoBrowser
//
//  Created by long on 2025/3/13.
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

class MahaNoAuthTipsView: UIView {
    private enum Layout {
        static let horizontalInset: CGFloat = 20
        static let titleTopDivisor: CGFloat = 4.6
        static let titleDescriptionSpacing: CGFloat = 18
        static let buttonBottomInset: CGFloat = 40
        static let buttonMinimumWidth: CGFloat = 200
        static let buttonExpandedHorizontalInset: CGFloat = 30
        static let buttonMaximumWidth: CGFloat = 280
        static let buttonHeight: CGFloat = 50
        static let buttonTextMaximumWidth: CGFloat = 250
        static let titleFont = UIFont.maha.font(ofSize: 24, bold: true)
        static let descFont = UIFont.maha.font(ofSize: 17)
        static let btnFont = UIFont.maha.font(ofSize: 17, bold: true)
    }

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = localLanguageTextValue(.noLibraryAuthTitleInThumbList)
        label.textColor = .maha.noLibraryAuthTitleAndDescColor
        label.textAlignment = .center
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.font = Layout.titleFont
        return label
    }()

    private lazy var descLabel: UILabel = {
        let label = UILabel()
        label.text = localLanguageTextValue(.noLibraryAuthDescInThumbList)
            .replacingOccurrences(of: "%@", with: getAppName())
        label.textColor = .maha.noLibraryAuthTitleAndDescColor
        label.textAlignment = .center
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.font = Layout.descFont
        return label
    }()

    private lazy var gotoSettingControl: UIControl = {
        let control = UIControl()
        control.maha.setCornerRadius(6)
        control.backgroundColor = .maha.bottomToolViewBtnNormalBgColor
        control.addTarget(self, action: #selector(gotoSetting), for: .touchUpInside)
        return control
    }()

    private lazy var gotoSettingLabel: UILabel = {
        let label = UILabel()
        label.text = localLanguageTextValue(.gotoSystemSettingInThumbList)
        label.textColor = .maha.noLibraryAuthGotoSettingBtnTitleColor
        label.font = Layout.btnFont
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = .center
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let layoutInsets = resolvedLayoutInsets()
        let totalHorizontalSafeAreaInset = layoutInsets.left + layoutInsets.right
        let contentWidth = maha.width - Layout.horizontalInset * 2 - totalHorizontalSafeAreaInset
        let contentOriginX = Layout.horizontalInset + totalHorizontalSafeAreaInset / 2

        let titleY = maha.height / Layout.titleTopDivisor
        let titleH = ceil(
            (titleLabel.text ?? "").maha.boundingRect(
                font: Layout.titleFont,
                limitSize: CGSize(width: contentWidth, height: .greatestFiniteMagnitude),
                lineBreakMode: .byWordWrapping
            ).height
        )
        titleLabel.frame = CGRect(x: contentOriginX, y: titleY, width: contentWidth, height: titleH)

        let descY = titleLabel.maha.bottom + Layout.titleDescriptionSpacing
        let descH = ceil(
            (descLabel.text ?? "").maha.boundingRect(
                font: Layout.descFont,
                limitSize: CGSize(width: contentWidth, height: .greatestFiniteMagnitude),
                lineBreakMode: .byWordWrapping
            ).height
        )
        descLabel.frame = CGRect(x: contentOriginX, y: descY, width: contentWidth, height: descH)

        let settingLabelSize = (gotoSettingLabel.text ?? "").maha.boundingRect(
            font: Layout.btnFont,
            limitSize: CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude),
            lineBreakMode: .byWordWrapping
        )
        let controlSize = calculateSettingControlSize(for: settingLabelSize)
        let labelWidth = min(Layout.buttonTextMaximumWidth, settingLabelSize.width)

        gotoSettingControl.frame = CGRect(
            x: maha.centerX - controlSize.width / 2,
            y: maha.height - controlSize.height - Layout.buttonBottomInset,
            width: controlSize.width,
            height: controlSize.height
        )

        gotoSettingLabel.frame = CGRect(
            x: (controlSize.width - labelWidth) / 2,
            y: 0,
            width: labelWidth,
            height: controlSize.height
        )
    }

    private func resolvedLayoutInsets() -> UIEdgeInsets {
        if #available(iOS 11.0, *), deviceIsFringeScreen() {
            return safeAreaInsets
        }
        return UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
    }

    private func calculateSettingControlSize(for labelSize: CGSize) -> CGSize {
        let labelWidth = min(labelSize.width, Layout.buttonTextMaximumWidth)
        let buttonWidth: CGFloat
        if labelSize.width <= 170 {
            buttonWidth = Layout.buttonMinimumWidth
        } else if labelSize.width <= Layout.buttonTextMaximumWidth {
            buttonWidth = labelSize.width + Layout.buttonExpandedHorizontalInset
        } else {
            buttonWidth = Layout.buttonMaximumWidth
        }

        let labelHeight = ceil(
            (gotoSettingLabel.text ?? "").maha.boundingRect(
                font: Layout.btnFont,
                limitSize: CGSize(width: labelWidth, height: CGFloat.greatestFiniteMagnitude),
                lineBreakMode: .byWordWrapping
            ).height
        )
        let buttonHeight = labelHeight > ceil(Layout.btnFont.lineHeight)
            ? max(labelHeight + Layout.buttonExpandedHorizontalInset, Layout.buttonHeight)
            : Layout.buttonHeight

        return CGSize(width: buttonWidth, height: buttonHeight)
    }

    private func setupUI() {
        addSubview(titleLabel)
        addSubview(descLabel)
        addSubview(gotoSettingControl)
        gotoSettingControl.addSubview(gotoSettingLabel)
    }

    @objc private func gotoSetting() {
        guard let url = URL(string: UIApplication.openSettingsURLString),
              UIApplication.shared.canOpenURL(url) else {
            return
        }

        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}
