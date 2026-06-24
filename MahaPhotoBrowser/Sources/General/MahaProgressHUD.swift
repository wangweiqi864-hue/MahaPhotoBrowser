//
//  MahaProgressHUD.swift
//  MahaPhotoBrowser
//
//  Created by long on 2020/8/17.
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

public class MahaProgressHUD: UIView {
    private enum Layout {
        static let containerSize = CGSize(width: 135, height: 135)
        static let cornerRadius: CGFloat = 12
        static let iconSize = CGSize(width: 40, height: 40)
        static let iconTop: CGFloat = 27
        static let titleHorizontalInset: CGFloat = 10
        static let titleTop: CGFloat = 70
        static let titleHeight: CGFloat = 60
    }

    private let style: MahaProgressHUD.Style

    private lazy var loadingView = UIImageView(image: style.icon)

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 2
        label.textColor = style.textColor
        label.font = .maha.font(ofSize: 16)
        label.text = localLanguageTextValue(.hudLoading)
        label.lineBreakMode = .byWordWrapping
        label.minimumScaleFactor = 0.5
        label.adjustsFontSizeToFitWidth = true
        return label
    }()

    private var timeoutTimer: Timer?

    public var timeoutBlock: (() -> Void)?

    deinit {
        mahaDebugPrint("MahaProgressHUD deinit")
        invalidateTimeoutTimer()
    }

    public init(style: MahaProgressHUD.Style) {
        self.style = style
        super.init(frame: UIScreen.main.bounds)
        setupUI()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        let containerView = UIView(frame: CGRect(origin: .zero, size: Layout.containerSize))
        containerView.layer.masksToBounds = true
        containerView.layer.cornerRadius = Layout.cornerRadius
        containerView.backgroundColor = style.bgColor
        containerView.clipsToBounds = true
        containerView.center = center

        if let effectStyle = style.blurEffectStyle {
            let effect = UIBlurEffect(style: effectStyle)
            let effectView = UIVisualEffectView(effect: effect)
            effectView.frame = containerView.bounds
            containerView.addSubview(effectView)
        }

        loadingView.frame = CGRect(
            x: (Layout.containerSize.width - Layout.iconSize.width) / 2,
            y: Layout.iconTop,
            width: Layout.iconSize.width,
            height: Layout.iconSize.height
        )
        containerView.addSubview(loadingView)

        titleLabel.frame = CGRect(
            x: Layout.titleHorizontalInset,
            y: Layout.titleTop,
            width: containerView.bounds.width - Layout.titleHorizontalInset * 2,
            height: Layout.titleHeight
        )
        containerView.addSubview(titleLabel)

        addSubview(containerView)
    }

    private func startAnimation() {
        let animation = CABasicAnimation(keyPath: "transform.rotation.z")
        animation.fromValue = 0
        animation.toValue = CGFloat.pi * 2
        animation.duration = 0.8
        animation.repeatCount = .infinity
        animation.fillMode = .forwards
        animation.isRemovedOnCompletion = false
        loadingView.layer.add(animation, forKey: nil)
    }

    public func show(
        toast: MahaProgressHUD.Toast = .loading,
        in view: UIView? = UIApplication.shared.keyWindow,
        timeout: TimeInterval = 100
    ) {
        MahaMainAsync {
            self.titleLabel.text = toast.value
            self.startAnimation()
            view?.addSubview(self)
        }

        if timeout > 0 {
            invalidateTimeoutTimer()
            timeoutTimer = Timer.scheduledTimer(timeInterval: timeout, target: MahaWeakProxy(target: self), selector: #selector(handleTimeout(_:)), userInfo: nil, repeats: false)
            RunLoop.current.add(timeoutTimer!, forMode: .default)
        }
    }

    @objc public func hide() {
        invalidateTimeoutTimer()
        MahaMainAsync {
            self.loadingView.layer.removeAllAnimations()
            self.removeFromSuperview()
        }
    }

    @objc func handleTimeout(_ timer: Timer) {
        timeoutBlock?()
        hide()
    }

    func invalidateTimeoutTimer() {
        timeoutTimer?.invalidate()
        timeoutTimer = nil
    }
}

public extension MahaProgressHUD {
    class func show(
        toast: MahaProgressHUD.Toast = .loading,
        in view: UIView? = UIApplication.shared.keyWindow,
        timeout: TimeInterval = 100
    ) -> MahaProgressHUD {
        let hud = MahaProgressHUD(style: MahaPhotoUIConfiguration.default().hudStyle)
        hud.show(toast: toast, in: view, timeout: timeout)
        return hud
    }
}

public extension MahaProgressHUD {
    @objc(MahaProgressHUDStyle)
    enum Style: Int {
        case light
        case lightBlur
        case dark
        case darkBlur

        var bgColor: UIColor {
            switch self {
            case .light:
                return .white
            case .dark:
                return .darkGray
            case .lightBlur:
                return UIColor.white.withAlphaComponent(0.8)
            case .darkBlur:
                return UIColor.darkGray.withAlphaComponent(0.8)
            }
        }

        var icon: UIImage? {
            switch self {
            case .light, .lightBlur:
                return .maha.getImage("zl_loading_dark")
            case .dark, .darkBlur:
                return .maha.getImage("zl_loading_light")
            }
        }

        var textColor: UIColor {
            switch self {
            case .light, .lightBlur:
                return .black
            case .dark, .darkBlur:
                return .white
            }
        }

        var blurEffectStyle: UIBlurEffect.Style? {
            switch self {
            case .light, .dark:
                return nil
            case .lightBlur:
                return .extraLight
            case .darkBlur:
                return .dark
            }
        }
    }

    enum Toast {
        case loading
        case processing
        case custome(String)

        var value: String {
            switch self {
            case .loading:
                return localLanguageTextValue(.hudLoading)
            case .processing:
                return localLanguageTextValue(.hudProcessing)
            case let .custome(text):
                return text
            }
        }
    }
}
