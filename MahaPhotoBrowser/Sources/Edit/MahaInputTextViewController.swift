//
//  MahaInputTextViewController.swift
//  MahaPhotoBrowser
//
//  Created by long on 2020/10/30.
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

class MahaInputTextViewController: UIViewController {
    private static let toolViewHeight: CGFloat = 70

    private let image: UIImage?

    private var text: String

    private var font: UIFont = .boldSystemFont(ofSize: MahaTextStickerView.fontSize)

    private var currentColor: UIColor {
        didSet {
            textView.typingAttributes = typingAttributes
            strokeTextView.strokeColor = currentColor
            strokeTextView.setNeedsDisplay()
            refreshTextAppearance()
        }
    }

    private var textStyle: MahaInputTextStyle {
        didSet {
            textView.typingAttributes = typingAttributes
            strokeTextView.isHidden = textStyle != .stroke
            strokeTextView.setNeedsDisplay()
        }
    }

    private lazy var bgImageView: UIImageView = {
        let view = UIImageView(image: image?.maha.blurImage(level: 4))
        view.contentMode = .scaleAspectFit
        return view
    }()

    private lazy var coverView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.alpha = 0.4
        return view
    }()

    private lazy var cancelBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle(localLanguageTextValue(.cancel), for: .normal)
        btn.setTitleColor(.maha.bottomToolViewDoneBtnNormalTitleColor, for: .normal)
        btn.titleLabel?.font = MahaLayout.bottomToolTitleFont
        btn.addTarget(self, action: #selector(cancelBtnClick), for: .touchUpInside)
        return btn
    }()

    private lazy var doneBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle(localLanguageTextValue(.inputDone), for: .normal)
        btn.titleLabel?.font = MahaLayout.bottomToolTitleFont
        btn.setTitleColor(.maha.bottomToolViewDoneBtnNormalTitleColor, for: .normal)
        btn.backgroundColor = .maha.bottomToolViewBtnNormalBgColor
        btn.addTarget(self, action: #selector(doneBtnClick), for: .touchUpInside)
        btn.layer.masksToBounds = true
        btn.layer.cornerRadius = MahaLayout.bottomToolBtnCornerRadius
        return btn
    }()

    private var typingAttributes: [NSAttributedString.Key: Any] {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 2
        var attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .paragraphStyle: paragraphStyle
        ]
        var foregroundColor = currentColor

        if textStyle == .bg {
            if currentColor == .white {
                foregroundColor = .black
            } else if currentColor == .black {
                foregroundColor = .white
            } else {
                foregroundColor = .white
            }
        } else if textStyle == .shadow {
            let shadow = NSShadow()
            shadow.shadowColor = UIColor.black
            shadow.shadowOffset = CGSize(width: 2, height: 2)
            shadow.shadowBlurRadius = 3
            attributes[.shadow] = shadow
        }

        attributes[.foregroundColor] = foregroundColor
        return attributes
    }

    private lazy var textView: UITextView = {
        let textView = UITextView()
        textView.keyboardAppearance = .dark
        textView.returnKeyType = .done
        textView.delegate = self
        textView.backgroundColor = .clear
        textView.tintColor = .maha.bottomToolViewBtnNormalBgColor
        textView.attributedText = NSAttributedString(string: text, attributes: typingAttributes)
        textView.typingAttributes = typingAttributes
        textView.textContainerInset = UIEdgeInsets(top: 8, left: 10, bottom: 8, right: 10)
        textView.textContainer.lineFragmentPadding = 0
        textView.layoutManager.delegate = self
        return textView
    }()

    private lazy var strokeTextView: MahaStrokeTextView = {
        let view = MahaStrokeTextView()
        view.backgroundColor = .clear
        view.font = font
        view.strokeColor = currentColor
        view.text = text
        view.isHidden = textStyle != .stroke
        return view
    }()

    private lazy var toolView = UIView(frame: CGRect(
        x: 0,
        y: view.maha.height - Self.toolViewHeight,
        width: view.maha.width,
        height: Self.toolViewHeight
    ))

    private lazy var textStyleBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.addTarget(self, action: #selector(textStyleBtnClick), for: .touchUpInside)
        return btn
    }()

    private lazy var collectionView: UICollectionView = {
        let layout = MahaCollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 36, height: 36)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .horizontal
        let inset = (Self.toolViewHeight - layout.itemSize.height) / 2
        layout.sectionInset = UIEdgeInsets(top: inset, left: 0, bottom: inset, right: 0)

        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: layout
        )
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        MahaDrawColorCell.maha.register(collectionView)

        return collectionView
    }()

    private var needsLayoutUpdate = true

    private lazy var textBackgroundLayer = CAShapeLayer()

    private let textBackgroundCornerRadius: CGFloat = 10

    private let maxTextCount = 100

    private var textContainerFrameObservation: NSKeyValueObservation?

    /// text, textColor, image, style
    var endInput: ((String, UIColor, UIFont, UIImage?, MahaInputTextStyle) -> Void)?

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        deviceIsiPhone() ? .portrait : .all
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    deinit {
        textContainerFrameObservation?.invalidate()
        mahaDebugPrint("MahaInputTextViewController deinit")
    }

    init(image: UIImage?, text: String? = nil, textColor: UIColor? = nil, font: UIFont? = nil, style: MahaInputTextStyle = .normal) {
        self.image = image
        self.text = text ?? ""
        if let font = font {
            self.font = font.withSize(MahaTextStickerView.fontSize)
        }
        if let textColor = textColor {
            currentColor = textColor
        } else {
            let editConfig = MahaPhotoConfiguration.default().editImageConfiguration
            if !editConfig.textStickerTextColors.contains(editConfig.textStickerDefaultTextColor) {
                currentColor = editConfig.textStickerTextColors.first!
            } else {
                currentColor = editConfig.textStickerDefaultTextColor
            }
        }
        textStyle = style
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIApplication.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIApplication.keyboardWillHideNotification, object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        textView.becomeFirstResponder()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        guard needsLayoutUpdate else { return }

        needsLayoutUpdate = false
        bgImageView.frame = view.bounds

        // iPad图片由竖屏切换到横屏时候填充方式会有点异常，这里重置下
        if deviceIsiPad() {
            if UIApplication.shared.statusBarOrientation.isLandscape {
                bgImageView.contentMode = .scaleAspectFill
            } else {
                bgImageView.contentMode = .scaleAspectFit
            }
        }

        coverView.frame = bgImageView.bounds

        let btnY = max(deviceSafeAreaInsets().top, 20)
        let cancelBtnW = localLanguageTextValue(.cancel).maha.boundingRect(font: MahaLayout.bottomToolTitleFont, limitSize: CGSize(width: .greatestFiniteMagnitude, height: MahaLayout.bottomToolBtnH)).width + 20
        cancelBtn.frame = CGRect(x: 15, y: btnY, width: cancelBtnW, height: MahaLayout.bottomToolBtnH)

        let doneBtnW = (doneBtn.currentTitle ?? "")
            .maha.boundingRect(
                font: MahaLayout.bottomToolTitleFont,
                limitSize: CGSize(width: .greatestFiniteMagnitude, height: MahaLayout.bottomToolBtnH)
            ).width + 20
        doneBtn.frame = CGRect(x: view.maha.width - 20 - doneBtnW, y: btnY, width: doneBtnW, height: MahaLayout.bottomToolBtnH)

        textView.frame = CGRect(x: 10, y: doneBtn.maha.bottom + 30, width: view.maha.width - 20, height: 200)

        textStyleBtn.frame = CGRect(
            x: 12,
            y: 0,
            width: 50,
            height: Self.toolViewHeight
        )
        collectionView.frame = CGRect(
            x: textStyleBtn.maha.right + 5,
            y: 0,
            width: view.maha.width - textStyleBtn.maha.right - 5 - 24,
            height: Self.toolViewHeight
        )

        for subview in textView.subviews {
            if NSStringFromClass(subview.classForCoder) == "_UITextContainerView" {
                textView.insertSubview(strokeTextView, belowSubview: subview)
                refreshStrokeTextViewFrame(for: subview)

                textContainerFrameObservation?.invalidate()
                textContainerFrameObservation = subview.observe(
                    \.frame,
                     options: .new,
                     changeHandler: { object, change in
                         self.refreshStrokeTextViewFrame(for: subview)
                     }
                )

                break
            }
        }

        if let index = MahaPhotoConfiguration.default().editImageConfiguration.textStickerTextColors.firstIndex(where: { $0 == self.currentColor }) {
            collectionView.scrollToItem(at: IndexPath(row: index, section: 0), at: .centeredHorizontally, animated: false)
        }
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        needsLayoutUpdate = true
    }

    private func setupUI() {
        view.backgroundColor = .black

        view.addSubview(bgImageView)
        bgImageView.addSubview(coverView)
        view.addSubview(cancelBtn)
        view.addSubview(doneBtn)
        view.addSubview(textView)
        view.addSubview(toolView)
        toolView.addSubview(textStyleBtn)
        toolView.addSubview(collectionView)

        // 这个要放到这里，不能放到懒加载里，因为放到懒加载里会触发layoutManager(_:, didCompleteLayoutFor:,atEnd)，导致循环调用
        textView.textAlignment = .left

        refreshTextAppearance()
    }

    private func refreshStrokeTextViewFrame(for containerView: UIView) {
        var rect = self.textView.convert(containerView.frame, from: containerView)
        rect = rect.insetBy(dx: textView.textContainerInset.left, dy: 0)
        rect.origin.y += textView.textContainerInset.top + 0.5
        self.strokeTextView.frame = rect
    }

    private func refreshTextAppearance() {
        textStyleBtn.setImage(textStyle.btnImage, for: .normal)
        textStyleBtn.setImage(textStyle.btnImage, for: .highlighted)

        drawTextBackground()

        guard textView.text != nil else { return }

        textView.attributedText = NSAttributedString(string: textView.text, attributes: typingAttributes)
    }

    @objc private func textStyleBtnClick() {
        textStyle = textStyle.next
        refreshTextAppearance()
    }

    @objc private func cancelBtnClick() {
        dismiss(animated: true, completion: nil)
    }

    @objc private func doneBtnClick() {
        textView.tintColor = .clear
        textView.endEditing(true)

        var image: UIImage?

        if !textView.text.isEmpty {
            for subview in textView.subviews {
                if NSStringFromClass(subview.classForCoder) == "_UITextContainerView" {
                    let renderedImageSize = textView.sizeThatFits(subview.frame.size)
                    image = UIGraphicsImageRenderer.maha.renderImage(size: renderedImageSize) { context in
                        if textStyle == .bg {
                            textBackgroundLayer.render(in: context)
                        }

                        var offsetX: CGFloat = 0
                        var offsetY: CGFloat = 0
                        if textStyle == .stroke {
                            let frame = textView.convert(strokeTextView.frame, to: subview)
                            context.translateBy(x: frame.minX, y: frame.minY)
                            offsetX = -frame.minX
                            offsetY = -frame.minY
                            strokeTextView.layer.render(in: context)
                        }

                        context.translateBy(x: offsetX, y: offsetY)
                        subview.layer.render(in: context)
                    }
                }
            }
        }

        endInput?(textView.text, currentColor, font, image, textStyle)
        dismiss(animated: true, completion: nil)
    }

    @objc private func keyboardWillShow(_ notify: Notification) {
        let rect = notify.userInfo?[UIApplication.keyboardFrameEndUserInfoKey] as? CGRect
        let keyboardH = rect?.height ?? 366
        let duration: TimeInterval = notify.userInfo?[UIApplication.keyboardAnimationDurationUserInfoKey] as? TimeInterval ?? 0.25

        let toolViewFrame = makeToolViewFrame(bottomOffset: keyboardH)

        var textViewFrame = textView.frame
        textViewFrame.size.height = toolViewFrame.minY - textViewFrame.minY - 20

        UIView.animate(withDuration: max(duration, 0.25)) {
            self.toolView.frame = toolViewFrame
            self.textView.frame = textViewFrame
        }
    }

    @objc private func keyboardWillHide(_ notify: Notification) {
        let duration: TimeInterval = notify.userInfo?[UIApplication.keyboardAnimationDurationUserInfoKey] as? TimeInterval ?? 0.25

        let toolViewFrame = makeToolViewFrame(bottomOffset: deviceSafeAreaInsets().bottom)

        var textViewFrame = textView.frame
        textViewFrame.size.height = toolViewFrame.minY - textViewFrame.minY - 20

        UIView.animate(withDuration: max(duration, 0.25)) {
            self.toolView.frame = toolViewFrame
            self.textView.frame = textViewFrame
        }
    }

    private func makeToolViewFrame(bottomOffset: CGFloat) -> CGRect {
        CGRect(
            x: 0,
            y: view.maha.height - bottomOffset - Self.toolViewHeight,
            width: view.maha.width,
            height: Self.toolViewHeight
        )
    }
}

extension MahaInputTextViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return MahaPhotoConfiguration.default().editImageConfiguration.textStickerTextColors.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MahaDrawColorCell.maha.identifier, for: indexPath) as! MahaDrawColorCell

        let color = MahaPhotoConfiguration.default().editImageConfiguration.textStickerTextColors[indexPath.row]
        cell.color = color
        if color == currentColor {
            cell.bgWhiteView.layer.transform = CATransform3DMakeScale(1.33, 1.33, 1)
            cell.colorView.layer.transform = CATransform3DMakeScale(1.2, 1.2, 1)
        } else {
            cell.bgWhiteView.layer.transform = CATransform3DIdentity
            cell.colorView.layer.transform = CATransform3DIdentity
        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        currentColor = MahaPhotoConfiguration.default().editImageConfiguration.textStickerTextColors[indexPath.row]
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        collectionView.reloadData()
    }
}

// MARK: Draw text layer

extension MahaInputTextViewController {
    private func drawTextBackground() {
        guard textStyle == .bg, !textView.text.isEmpty else {
            textBackgroundLayer.removeFromSuperlayer()
            return
        }

        let textRects = calculateTextRects()

        let path = UIBezierPath()
        for (index, rect) in textRects.enumerated() {
            if index == 0 {
                path.move(to: CGPoint(x: rect.minX, y: rect.minY + textBackgroundCornerRadius))
                path.addArc(withCenter: CGPoint(x: rect.minX + textBackgroundCornerRadius, y: rect.minY + textBackgroundCornerRadius), radius: textBackgroundCornerRadius, startAngle: .pi, endAngle: .pi * 1.5, clockwise: true)
                path.addLine(to: CGPoint(x: rect.maxX - textBackgroundCornerRadius, y: rect.minY))
                path.addArc(withCenter: CGPoint(x: rect.maxX - textBackgroundCornerRadius, y: rect.minY + textBackgroundCornerRadius), radius: textBackgroundCornerRadius, startAngle: .pi * 1.5, endAngle: .pi * 2, clockwise: true)
            } else {
                let previousRect = textRects[index - 1]
                if rect.maxX > previousRect.maxX {
                    path.addLine(to: CGPoint(x: previousRect.maxX, y: rect.minY - textBackgroundCornerRadius))
                    path.addArc(withCenter: CGPoint(x: previousRect.maxX + textBackgroundCornerRadius, y: rect.minY - textBackgroundCornerRadius), radius: textBackgroundCornerRadius, startAngle: -.pi, endAngle: -.pi * 1.5, clockwise: false)
                    path.addLine(to: CGPoint(x: rect.maxX - textBackgroundCornerRadius, y: rect.minY))
                    path.addArc(withCenter: CGPoint(x: rect.maxX - textBackgroundCornerRadius, y: rect.minY + textBackgroundCornerRadius), radius: textBackgroundCornerRadius, startAngle: .pi * 1.5, endAngle: .pi * 2, clockwise: true)
                } else if rect.maxX < previousRect.maxX {
                    path.addLine(to: CGPoint(x: previousRect.maxX, y: previousRect.maxY - textBackgroundCornerRadius))
                    path.addArc(withCenter: CGPoint(x: previousRect.maxX - textBackgroundCornerRadius, y: previousRect.maxY - textBackgroundCornerRadius), radius: textBackgroundCornerRadius, startAngle: 0, endAngle: .pi / 2, clockwise: true)
                    path.addLine(to: CGPoint(x: rect.maxX + textBackgroundCornerRadius, y: previousRect.maxY))
                    path.addArc(withCenter: CGPoint(x: rect.maxX + textBackgroundCornerRadius, y: previousRect.maxY + textBackgroundCornerRadius), radius: textBackgroundCornerRadius, startAngle: -.pi / 2, endAngle: -.pi, clockwise: false)
                } else {
                    path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY + textBackgroundCornerRadius))
                }
            }

            if index == textRects.count - 1 {
                path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - textBackgroundCornerRadius))
                path.addArc(withCenter: CGPoint(x: rect.maxX - textBackgroundCornerRadius, y: rect.maxY - textBackgroundCornerRadius), radius: textBackgroundCornerRadius, startAngle: 0, endAngle: .pi / 2, clockwise: true)
                path.addLine(to: CGPoint(x: rect.minX + textBackgroundCornerRadius, y: rect.maxY))
                path.addArc(withCenter: CGPoint(x: rect.minX + textBackgroundCornerRadius, y: rect.maxY - textBackgroundCornerRadius), radius: textBackgroundCornerRadius, startAngle: .pi / 2, endAngle: .pi, clockwise: true)

                let firstRect = textRects[0]
                path.addLine(to: CGPoint(x: firstRect.minX, y: firstRect.minY + textBackgroundCornerRadius))
                path.close()
            }
        }

        textBackgroundLayer.path = path.cgPath
        textBackgroundLayer.fillColor = currentColor.cgColor
        if textBackgroundLayer.superlayer == nil {
            textView.layer.insertSublayer(textBackgroundLayer, at: 0)
        }
    }

    private func calculateTextRects() -> [CGRect] {
        let layoutManager = textView.layoutManager

        // 这里必须用utf16.count 或者 (text as NSString).length，因为用count的话不准，一个emoji表情的count为2或更大
        let range = layoutManager.glyphRange(forCharacterRange: NSMakeRange(0, textView.text.utf16.count), actualCharacterRange: nil)
        let glyphRange = layoutManager.glyphRange(forCharacterRange: range, actualCharacterRange: nil)

        var rects: [CGRect] = []

        let insetLeft = textView.textContainerInset.left
        let insetTop = textView.textContainerInset.top
        layoutManager.enumerateLineFragments(forGlyphRange: glyphRange) { _, usedRect, _, _, _ in
            rects.append(CGRect(x: usedRect.minX - 10 + insetLeft, y: usedRect.minY - 8 + insetTop, width: usedRect.width + 20, height: usedRect.height + 16))
        }

        guard rects.count > 1 else {
            return rects
        }

        for i in 1..<rects.count {
            normalizeAdjacentRects(&rects, index: i, maxIndex: i)
        }

        return rects
    }

    private func normalizeAdjacentRects(_ rects: inout [CGRect], index: Int, maxIndex: Int) {
        guard rects.count > 1, index > 0, index <= maxIndex else {
            return
        }

        var preRect = rects[index - 1]
        var currRect = rects[index]

        var preChanged = false
        var currChanged = false

        // 当前rect宽度大于上方的rect，但差值小于2倍圆角
        if currRect.width > preRect.width, currRect.width - preRect.width < 2 * textBackgroundCornerRadius {
            var size = preRect.size
            size.width = currRect.width
            preRect = CGRect(origin: preRect.origin, size: size)
            preChanged = true
        }

        if currRect.width < preRect.width, preRect.width - currRect.width < 2 * textBackgroundCornerRadius {
            var size = currRect.size
            size.width = preRect.width
            currRect = CGRect(origin: currRect.origin, size: size)
            currChanged = true
        }

        if preChanged {
            rects[index - 1] = preRect
            normalizeAdjacentRects(&rects, index: index - 1, maxIndex: maxIndex)
        }

        if currChanged {
            rects[index] = currRect
            normalizeAdjacentRects(&rects, index: index + 1, maxIndex: maxIndex)
        }
    }
}

extension MahaInputTextViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        defer {
            strokeTextView.text = textView.text
            if textStyle == .stroke {
                strokeTextView.setNeedsDisplay()
            }
        }

        let markedTextRange = textView.markedTextRange
        guard markedTextRange == nil || (markedTextRange?.isEmpty ?? true) else {
            return
        }

        let text = textView.text ?? ""
        if text.count > maxTextCount {
            let endIndex = text.index(text.startIndex, offsetBy: maxTextCount)
            textView.attributedText = NSAttributedString(
                string: String(text[..<endIndex]),
                attributes: typingAttributes
            )
        }
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            doneBtnClick()
            return false
        }

        return true
    }
}

extension MahaInputTextViewController: NSLayoutManagerDelegate {
    func layoutManager(_ layoutManager: NSLayoutManager, didCompleteLayoutFor textContainer: NSTextContainer?, atEnd layoutFinishedFlag: Bool) {
        guard layoutFinishedFlag else {
            return
        }

        drawTextBackground()
    }
}

public enum MahaInputTextStyle {
    case normal
    case bg
    case stroke
    case shadow

    fileprivate var next: MahaInputTextStyle {
        switch self {
        case .normal:
            return .bg
        case .bg:
            return .stroke
        case .stroke:
            return .shadow
        case .shadow:
            return.normal
        }
    }

    fileprivate var btnImage: UIImage? {
        switch self {
        case .normal:
            return .maha.getImage("zl_input_font")
        case .bg:
            return .maha.getImage("zl_input_font_bg")
        case .stroke:
            return .maha.getImage("zl_input_font_stroke")
        case .shadow:
            return .maha.getImage("zl_input_font_shadow")
        }
    }
}

class MahaStrokeTextView: UIView {
    var font: UIFont = .boldSystemFont(ofSize: MahaTextStickerView.fontSize)
    var strokeColor: UIColor = .white
    var strokeWidth: CGFloat = 4.0
    var text = ""

    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }

        context.clear(bounds)
        context.saveGState()
        context.textMatrix = .identity
        context.translateBy(x: 0, y: bounds.height)
        context.scaleBy(x: 1.0, y: -1.0)

        // 设置描边和填充颜色
        var textColorARGB = strokeColor.maha.argbTuple()
        if textColorARGB.red <= 0.1, textColorARGB.green <= 0.1, textColorARGB.blue <= 0.1 {
            // 黑色的话修改为白色，方便看出边框
            textColorARGB = (1, 1, 1, 1)
        }
        let fillColor = UIColor(red: textColorARGB.red * 0.45, green: textColorARGB.green * 0.45, blue: textColorARGB.blue * 0.5, alpha: 1)

        context.setTextDrawingMode(.fillStroke)
        // 描边宽度
        context.setLineWidth(strokeWidth)
        context.setFillColor(fillColor.cgColor)
        context.setLineJoin(.round)

        // 创建 Core Text 绘制
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 2.2
        let attributedString = NSAttributedString(string: text, attributes: [.foregroundColor: fillColor, .font: font, .paragraphStyle: paragraphStyle])

        let framesetter = CTFramesetterCreateWithAttributedString(attributedString)
        let path = CGMutablePath()

        path.addRect(bounds)
        let frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, attributedString.length), path, nil)

        // 绘制文本
        CTFrameDraw(frame, context)
        context.restoreGState()
    }
}
