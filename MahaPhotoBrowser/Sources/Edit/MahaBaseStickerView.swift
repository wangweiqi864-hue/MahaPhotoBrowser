//
//  MahaBaseStickerView.swift
//  MahaPhotoBrowser
//
//  Created by long on 2022/11/28.
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

protocol MahaStickerViewDelegate: NSObject {
    /// Called when scale or rotate or move.
    func stickerBeginOperation(_ sticker: MahaBaseStickerView)

    /// Called during scale or rotate or move.
    func stickerOnOperation(_ sticker: MahaBaseStickerView, panGesture: UIPanGestureRecognizer)

    /// Called after scale or rotate or move.
    func stickerEndOperation(_ sticker: MahaBaseStickerView, panGesture: UIPanGestureRecognizer)

    /// Called when tap sticker.
    func stickerDidTap(_ sticker: MahaBaseStickerView)

    func sticker(_ textSticker: MahaTextStickerView, editText text: String)
}

protocol MahaStickerViewAdditional: NSObject {
    var isGestureEnabled: Bool { get set }

    func resetState()

    func moveToAshbin()

    func addScale(_ scale: CGFloat)
}

class MahaBaseStickerView: UIView, UIGestureRecognizerDelegate {
    private enum Direction: Int {
        case up = 0
        case right = 90
        case bottom = 180
        case left = 270
    }

    var id: String

    var borderWidth = 1 / UIScreen.main.scale

    var needsInitialLayout = true

    let originScale: CGFloat

    let originAngle: CGFloat

    var maximumGestureScale: CGFloat

    var originTransform: CGAffineTransform = .identity

    var borderHideTimer: Timer?

    var totalTranslation: CGPoint = .zero

    var currentGestureTranslation: CGPoint = .zero

    var currentGestureRotation: CGFloat = 0

    var currentGestureScale: CGFloat = 1

    var isOperating = false

    var isGestureEnabled = true

    var originFrame: CGRect

    lazy var tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapAction(_:)))

    lazy var pinchGesture: UIPinchGestureRecognizer = {
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(pinchAction(_:)))
        pinch.delegate = self
        return pinch
    }()

    lazy var panGesture: UIPanGestureRecognizer = {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(panAction(_:)))
        pan.delegate = self
        return pan
    }()

    var state: MahaBaseStickertState {
        fatalError()
    }

    var borderView: UIView {
        return self
    }

    weak var delegate: MahaStickerViewDelegate?

    deinit {
        cleanTimer()
    }

    class func initWithState(_ state: MahaBaseStickertState) -> MahaBaseStickerView? {
        if let state = state as? MahaTextStickerState {
            return MahaTextStickerView(state: state)
        } else if let state = state as? MahaImageStickerState {
            return MahaImageStickerView(state: state)
        } else {
            return nil
        }
    }

    init(
        id: String = UUID().uuidString,
        originScale: CGFloat,
        originAngle: CGFloat,
        originFrame: CGRect,
        gesScale: CGFloat = 1,
        gesRotation: CGFloat = 0,
        totalTranslationPoint: CGPoint = .zero,
        showBorder: Bool = true
    ) {
        self.id = id
        self.originScale = originScale
        self.originAngle = originAngle
        self.originFrame = originFrame
        maximumGestureScale = 4 / originScale
        super.init(frame: .zero)

        currentGestureScale = gesScale
        currentGestureRotation = gesRotation
        totalTranslation = totalTranslationPoint

        borderView.layer.borderWidth = borderWidth
        hideBorder()
        if showBorder {
            startTimer()
        }

        addGestureRecognizer(tapGesture)
        addGestureRecognizer(pinchGesture)

        let rotationGes = UIRotationGestureRecognizer(target: self, action: #selector(rotationAction(_:)))
        rotationGes.delegate = self
        addGestureRecognizer(rotationGes)

        addGestureRecognizer(panGesture)
        tapGesture.require(toFail: panGesture)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        guard needsInitialLayout else {
            return
        }

        // Rotate must be first when first layout.
        transform = transform.rotated(by: originAngle.maha.toPi)

        if totalTranslation != .zero {
            let direction = direction(for: originAngle)
            if direction == .right {
                transform = transform.translatedBy(x: totalTranslation.y, y: -totalTranslation.x)
            } else if direction == .bottom {
                transform = transform.translatedBy(x: -totalTranslation.x, y: -totalTranslation.y)
            } else if direction == .left {
                transform = transform.translatedBy(x: -totalTranslation.y, y: totalTranslation.x)
            } else {
                transform = transform.translatedBy(x: totalTranslation.x, y: totalTranslation.y)
            }
        }

        transform = transform.scaledBy(x: originScale, y: originScale)

        originTransform = transform

        if currentGestureScale != 1 {
            transform = transform.scaledBy(x: currentGestureScale, y: currentGestureScale)
        }
        if currentGestureRotation != 0 {
            transform = transform.rotated(by: currentGestureRotation)
        }

        needsInitialLayout = false
        setupUIFrameWhenFirstLayout()
    }

    func setupUIFrameWhenFirstLayout() {}

    private func direction(for angle: CGFloat) -> MahaBaseStickerView.Direction {
        // 将角度转换为0~360，并对360取余
        let angle = ((Int(angle) % 360) + 360) % 360
        return MahaBaseStickerView.Direction(rawValue: angle) ?? .up
    }

    @objc func tapAction(_ ges: UITapGestureRecognizer) {
        guard isGestureEnabled else { return }

        delegate?.stickerDidTap(self)
        startTimer()
    }

    @objc func pinchAction(_ ges: UIPinchGestureRecognizer) {
        guard isGestureEnabled else { return }

        let scale = min(maximumGestureScale, currentGestureScale * ges.scale)
        ges.scale = 1

        var scaleChanged = false
        if scale != currentGestureScale {
            currentGestureScale = scale
            scaleChanged = true
        }

        if ges.state == .began {
            setOperation(true)
        } else if ges.state == .changed {
            if scaleChanged {
                updateTransform()
            }
        } else if ges.state == .ended || ges.state == .cancelled {
            // 当有拖动时，在panAction中执行setOperation(false)
            if currentGestureTranslation == .zero {
                setOperation(false)
            }
        }
    }

    @objc func rotationAction(_ ges: UIRotationGestureRecognizer) {
        guard isGestureEnabled else { return }

        currentGestureRotation += ges.rotation
        ges.rotation = 0

        if ges.state == .began {
            setOperation(true)
        } else if ges.state == .changed {
            updateTransform()
        } else if ges.state == .ended || ges.state == .cancelled {
            if currentGestureTranslation == .zero {
                setOperation(false)
            }
        }
    }

    @objc func panAction(_ ges: UIPanGestureRecognizer) {
        guard isGestureEnabled else { return }

        let point = ges.translation(in: superview)
        currentGestureTranslation = CGPoint(x: point.x / originScale, y: point.y / originScale)

        if ges.state == .began {
            setOperation(true)
        } else if ges.state == .changed {
            updateTransform()
        } else if ges.state == .ended || ges.state == .cancelled {
            totalTranslation.x += point.x
            totalTranslation.y += point.y
            setOperation(false)
            let direction = direction(for: originAngle)
            if direction == .right {
                originTransform = originTransform.translatedBy(x: currentGestureTranslation.y, y: -currentGestureTranslation.x)
            } else if direction == .bottom {
                originTransform = originTransform.translatedBy(x: -currentGestureTranslation.x, y: -currentGestureTranslation.y)
            } else if direction == .left {
                originTransform = originTransform.translatedBy(x: -currentGestureTranslation.y, y: currentGestureTranslation.x)
            } else {
                originTransform = originTransform.translatedBy(x: currentGestureTranslation.x, y: currentGestureTranslation.y)
            }
            currentGestureTranslation = .zero
        }
    }

    func setOperation(_ isOn: Bool) {
        if isOn, !isOperating {
            isOperating = true
            cleanTimer()
            borderView.layer.borderColor = UIColor.white.cgColor
            delegate?.stickerBeginOperation(self)
        } else if !isOn, isOperating {
            isOperating = false
            startTimer()
            delegate?.stickerEndOperation(self, panGesture: panGesture)
        }
    }

    func updateTransform() {
        var transform = originTransform

        let direction = direction(for: originAngle)
        if direction == .right {
            transform = transform.translatedBy(x: currentGestureTranslation.y, y: -currentGestureTranslation.x)
        } else if direction == .bottom {
            transform = transform.translatedBy(x: -currentGestureTranslation.x, y: -currentGestureTranslation.y)
        } else if direction == .left {
            transform = transform.translatedBy(x: -currentGestureTranslation.y, y: currentGestureTranslation.x)
        } else {
            transform = transform.translatedBy(x: currentGestureTranslation.x, y: currentGestureTranslation.y)
        }
        // Scale must after translate.
        transform = transform.scaledBy(x: currentGestureScale, y: currentGestureScale)
        // Rotate must after scale.
        transform = transform.rotated(by: currentGestureRotation)
        self.transform = transform

        delegate?.stickerOnOperation(self, panGesture: panGesture)
    }

    @objc private func hideBorder() {
        borderView.layer.borderColor = UIColor.clear.cgColor
    }

    func startTimer() {
        cleanTimer()
        borderView.layer.borderColor = UIColor.white.cgColor
        borderHideTimer = Timer.scheduledTimer(timeInterval: 2, target: MahaWeakProxy(target: self), selector: #selector(hideBorder), userInfo: nil, repeats: false)
        RunLoop.current.add(borderHideTimer!, forMode: .common)
    }

    private func cleanTimer() {
        borderHideTimer?.invalidate()
        borderHideTimer = nil
    }

    // MARK: UIGestureRecognizerDelegate

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

extension MahaBaseStickerView: MahaStickerViewAdditional {
    func resetState() {
        isOperating = false
        cleanTimer()
        hideBorder()
    }

    func moveToAshbin() {
        cleanTimer()
        removeFromSuperview()
    }

    func addScale(_ scale: CGFloat) {
        // Revert zoom scale.
        transform = transform.scaledBy(x: 1 / originScale, y: 1 / originScale)
        // Revert ges scale.
        transform = transform.scaledBy(x: 1 / currentGestureScale, y: 1 / currentGestureScale)
        // Revert ges rotation.
        transform = transform.rotated(by: -currentGestureRotation)

        var origin = frame.origin
        origin.x *= scale
        origin.y *= scale

        let newSize = CGSize(width: frame.width * scale, height: frame.height * scale)
        let newOrigin = CGPoint(x: frame.minX + (frame.width - newSize.width) / 2, y: frame.minY + (frame.height - newSize.height) / 2)
        let diffX: CGFloat = (origin.x - newOrigin.x)
        let diffY: CGFloat = (origin.y - newOrigin.y)

        let direction = direction(for: originAngle)
        if direction == .right {
            transform = transform.translatedBy(x: diffY, y: -diffX)
            originTransform = originTransform.translatedBy(x: diffY / originScale, y: -diffX / originScale)
        } else if direction == .bottom {
            transform = transform.translatedBy(x: -diffX, y: -diffY)
            originTransform = originTransform.translatedBy(x: -diffX / originScale, y: -diffY / originScale)
        } else if direction == .left {
            transform = transform.translatedBy(x: -diffY, y: diffX)
            originTransform = originTransform.translatedBy(x: -diffY / originScale, y: diffX / originScale)
        } else {
            transform = transform.translatedBy(x: diffX, y: diffY)
            originTransform = originTransform.translatedBy(x: diffX / originScale, y: diffY / originScale)
        }
        totalTranslation.x += diffX
        totalTranslation.y += diffY

        transform = transform.scaledBy(x: scale, y: scale)

        // Readd zoom scale.
        transform = transform.scaledBy(x: originScale, y: originScale)
        // Readd ges scale.
        transform = transform.scaledBy(x: currentGestureScale, y: currentGestureScale)
        // Readd ges rotation.
        transform = transform.rotated(by: currentGestureRotation)

        currentGestureScale *= scale
        maximumGestureScale *= scale
    }
}
