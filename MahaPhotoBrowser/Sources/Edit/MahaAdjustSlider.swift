//
//  MahaAdjustSlider.swift
//  MahaPhotoBrowser
//
//  Created by long on 2021/12/17.
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

class MahaAdjustSlider: UIView {
    static let maximumValue: Float = 1

    static let minimumValue: Float = -1

    private let sliderWidth: CGFloat = 5

    private let isVerticalLayout = MahaPhotoUIConfiguration.default().adjustSliderType == .vertical

    lazy var valueLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.layer.shadowColor = UIColor.black.withAlphaComponent(0.6).cgColor
        label.layer.shadowOffset = .zero
        label.layer.shadowOpacity = 1
        label.textColor = .white
        label.textAlignment = isVerticalLayout ? .right : .center
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.6
        return label
    }()

    lazy var separator: UIView = {
        let view = UIView()
        view.backgroundColor = .maha.rgba(230, 230, 230)
        return view
    }()

    lazy var shadowView: UIView = {
        let view = UIView()
        view.backgroundColor = .maha.adjustSliderNormalColor
        view.layer.cornerRadius = sliderWidth / 2
        view.layer.shadowColor = UIColor.black.withAlphaComponent(0.4).cgColor
        view.layer.shadowOffset = .zero
        view.layer.shadowOpacity = 1
        view.layer.shadowRadius = 3
        return view
    }()

    lazy var whiteView: UIView = {
        let view = UIView()
        view.backgroundColor = .maha.adjustSliderNormalColor
        view.layer.cornerRadius = sliderWidth / 2
        view.layer.masksToBounds = true
        return view
    }()

    lazy var tintView: UIView = {
        let view = UIView()
        view.backgroundColor = .maha.adjustSliderTintColor
        return view
    }()

    lazy var panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))

    private var impactFeedback: UIImpactFeedbackGenerator?

    private var initialPanValue: Float = 0

    var value: Float = 0 {
        didSet {
            valueLabel.text = String(Int(roundf(value * 100)))
            tintView.frame = calculateTintFrame()
        }
    }

    var beginAdjust: (() -> Void)?

    var valueChanged: ((Float) -> Void)?

    var endAdjust: (() -> Void)?

    deinit {
        mahaDebugPrint("MahaAdjustSlider deinit")
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()

        let editConfig = MahaPhotoConfiguration.default().editImageConfiguration
        if editConfig.impactFeedbackWhenAdjustSliderValueIsZero {
            impactFeedback = UIImpactFeedbackGenerator(style: editConfig.impactFeedbackStyle)
        }

        addGestureRecognizer(panGesture)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if isVerticalLayout {
            shadowView.frame = CGRect(x: 40, y: 0, width: sliderWidth, height: bounds.height)
            whiteView.frame = shadowView.frame
            tintView.frame = calculateTintFrame()
            let separatorH: CGFloat = 1
            separator.frame = CGRect(x: 0, y: (bounds.height - separatorH) / 2, width: sliderWidth, height: separatorH)
            valueLabel.frame = CGRect(x: 0, y: bounds.height / 2 - 10, width: 38, height: 20)
        } else {
            valueLabel.frame = CGRect(x: 0, y: 0, width: maha.width, height: 38)
            shadowView.frame = CGRect(x: 0, y: valueLabel.maha.bottom + 2, width: maha.width, height: sliderWidth)
            whiteView.frame = shadowView.frame
            tintView.frame = calculateTintFrame()
            let separatorW: CGFloat = 1
            separator.frame = CGRect(x: (maha.width - separatorW) / 2, y: 0, width: separatorW, height: sliderWidth)
        }
    }

    private func setupUI() {
        addSubview(shadowView)
        addSubview(whiteView)
        whiteView.addSubview(tintView)
        whiteView.addSubview(separator)
        addSubview(valueLabel)
    }

    private func calculateTintFrame() -> CGRect {
        if isVerticalLayout {
            let totalH = maha.height / 2
            let tintH = totalH * abs(CGFloat(value)) / CGFloat(MahaAdjustSlider.maximumValue)
            if value > 0 {
                return CGRect(x: 0, y: totalH - tintH, width: sliderWidth, height: tintH)
            } else {
                return CGRect(x: 0, y: totalH, width: sliderWidth, height: tintH)
            }
        } else {
            let totalW = maha.width / 2
            let tintW = totalW * abs(CGFloat(value)) / CGFloat(MahaAdjustSlider.maximumValue)
            if value > 0 {
                return CGRect(x: totalW, y: 0, width: tintW, height: sliderWidth)
            } else {
                return CGRect(x: totalW - tintW, y: 0, width: tintW, height: sliderWidth)
            }
        }
    }

    @objc private func handlePanGesture(_ pan: UIPanGestureRecognizer) {
        let translation = pan.translation(in: self)

        if pan.state == .began {
            initialPanValue = value
            beginAdjust?()
            impactFeedback?.prepare()
        } else if pan.state == .changed {
            let translatedValue = isVerticalLayout ? -translation.y : translation.x
            let totalLength = isVerticalLayout ? maha.height / 2 : maha.width / 2
            var updatedValue = initialPanValue + Float(translatedValue / totalLength)
            updatedValue = max(MahaAdjustSlider.minimumValue, min(MahaAdjustSlider.maximumValue, updatedValue))

            if (-0.0049..<0.005) ~= updatedValue {
                updatedValue = 0
            }

            guard value != updatedValue else { return }

            value = updatedValue
            valueChanged?(value)

            guard #available(iOS 10.0, *) else { return }
            if value == 0 {
                impactFeedback?.impactOccurred()
            }
        } else {
            initialPanValue = value
            endAdjust?()
        }
    }
}
