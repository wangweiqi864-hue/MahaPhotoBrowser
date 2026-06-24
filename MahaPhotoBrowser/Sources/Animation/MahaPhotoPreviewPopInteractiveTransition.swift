//
//  MahaPhotoPreviewPopInteractiveTransition.swift
//  MahaPhotoBrowser
//
//  Created by long on 2020/9/3.
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
import AVFoundation

class MahaPhotoPreviewPopInteractiveTransition: UIPercentDrivenInteractiveTransition {
    weak var transitionContext: UIViewControllerContextTransitioning?

    weak var viewController: MahaPhotoPreviewController?

    private let transitionAnimationDuration: TimeInterval = 0.3
    private let cancelAnimationDuration: TimeInterval = 0.25

    lazy var dismissPanGesture: UIPanGestureRecognizer = {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(dismissPanAction(_:)))
        pan.delegate = self
        return pan
    }()

    var transitionShadowView: UIView?

    var transitionImageView: UIImageView?

    var playerLayer: AVPlayerLayer?

    var transitionImageOriginalFrame: CGRect = .zero

    var panStartPoint: CGPoint = .zero

    var isInteractive = false

    var currentCell: MahaPreviewBaseCell?
    /// 取消动画时候，是否需要将Y值修正为0
    var needCorrectYToZeroWhenCancel = false

    var translationBeforeInteraction: CGPoint = .zero

    var shouldStartTransition: ((CGPoint) -> Bool)?

    var startTransition: (() -> Void)?

    var cancelTransition: (() -> Void)?

    var finishTransition: (() -> Void)?

    deinit {
        mahaDebugPrint("MahaPhotoPreviewPopInteractiveTransition deinit")
    }

    init(viewController: MahaPhotoPreviewController) {
        self.viewController = viewController
        super.init()

        viewController.view.addGestureRecognizer(dismissPanGesture)
    }

    @objc func dismissPanAction(_ pan: UIPanGestureRecognizer) {
        guard canStartPan() else { return }

        if pan.state == .began {
            beginInteractiveTransition(with: pan)
        } else if pan.state == .changed {
            if !isInteractive {
                beginInteractiveTransition(with: pan)
                if isInteractive {
                    translationBeforeInteraction = pan.translation(in: viewController?.view)
                }
                return
            }

            let panState = makePanState(for: pan)
            transitionImageView?.transform = CGAffineTransform(scaleX: panState.scale, y: panState.scale)
            transitionImageView?.center = CGPoint(x: panState.frame.midX, y: panState.frame.midY)

            transitionShadowView?.alpha = pow(panState.scale, 2)

            update(panState.scale)
        } else if pan.state == .cancelled || pan.state == .ended {
            guard isInteractive else { return }

            let velocity = pan.velocity(in: viewController?.view)
            let translation = pan.translation(in: viewController?.view)
            let transY = translation.y - translationBeforeInteraction.y
            let percent = max(0.0, transY / (viewController?.view.bounds.height ?? UIScreen.main.bounds.height))

            let shouldDismiss = velocity.y > 300 || (percent > 0.1 && velocity.y >= 0)

            if shouldDismiss {
                finish()
            } else {
                cancel()
            }

            resetInteractiveState()
        }
    }

    /// 判断是否开始手势
    func canStartPan() -> Bool {
        guard !isInteractive else { return true }

        guard let viewController,
              let cell = viewController.collectionView.cellForItem(
                  at: IndexPath(row: viewController.currentIndex, section: 0)
              ) as? MahaPreviewBaseCell,
              let scrollView = cell.scrollView,
              let contentView = scrollView.subviews.first else {
            return true
        }

        let convertRect = contentView.convert(contentView.bounds, to: scrollView)
        if scrollView.isZooming ||
            scrollView.isZoomBouncing ||
            scrollView.contentOffset.y > 0 ||
            // cell放大时候，当拖拽到最左和最右时，会拉动vc的collectionView，这时不能进行pop动画
            (convertRect.minX != 0 && contentView.maha.width > scrollView.maha.width) {
            return false
        }

        return true
    }

    /// 开始手势
    func beginInteractiveTransition(with pan: UIPanGestureRecognizer) {
        guard !isInteractive else { return }

        let velocity = pan.velocity(in: viewController?.view)
        if abs(velocity.x) >= abs(velocity.y) || velocity.y <= 0 {
            return
        }

        panStartPoint = pan.location(in: viewController?.view)
        isInteractive = true
        startTransition?()
        viewController?.navigationController?.popViewController(animated: true)
    }

    func makePanState(for pan: UIPanGestureRecognizer) -> (frame: CGRect, scale: CGFloat) {
        // 拖动偏移量
        let translation = pan.translation(in: viewController?.view)
        let transY = translation.y - translationBeforeInteraction.y
        let currentTouch = pan.location(in: viewController?.view)

        // 由下拉的偏移值决定缩放比例，越往下偏移，缩得越小。scale值区间[0.3, 1.0]
        let scale = min(1.0, max(0.3, 1 - transY / UIScreen.main.bounds.height))

        let width = transitionImageOriginalFrame.size.width * scale
        let height = transitionImageOriginalFrame.size.height * scale

        // 计算x和y。保持手指在图片上的相对位置不变。
        let xRate = (panStartPoint.x - transitionImageOriginalFrame.origin.x) / transitionImageOriginalFrame.size.width
        let currentTouchDeltaX = xRate * width
        let x = currentTouch.x - currentTouchDeltaX

        let yRate = (panStartPoint.y - transitionImageOriginalFrame.origin.y) / transitionImageOriginalFrame.size.height
        let currentTouchDeltaY = yRate * height
        let y = currentTouch.y - currentTouchDeltaY

        return (CGRect(x: x.isNaN ? 0 : x, y: y.isNaN ? 0 : y, width: width, height: height), scale)
    }

    override func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        self.transitionContext = transitionContext
        startTransitionAnimation()
    }

    func startTransitionAnimation() {
        guard let transitionContext = transitionContext else {
            return
        }

        guard let fromVC = transitionContext.viewController(forKey: .from) as? MahaPhotoPreviewController,
              let toVC = transitionContext.viewController(forKey: .to) as? MahaThumbnailViewController else {
            return
        }

        let containerView = transitionContext.containerView
        containerView.addSubview(toVC.view)

        guard let cell = fromVC.collectionView.cellForItem(at: IndexPath(row: fromVC.currentIndex, section: 0)) as? MahaPreviewBaseCell else {
            return
        }

        currentCell = cell
        let shadowView = UIView(frame: containerView.bounds)
        shadowView.backgroundColor = MahaPhotoUIConfiguration.default().previewVCBgColor
        transitionShadowView = shadowView
        containerView.addSubview(shadowView)

        let fromImageViewFrame = cell.animateImageFrame(convertTo: containerView)

        let imageView = UIImageView(frame: fromImageViewFrame)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        transitionImageView = imageView

        if let videoCell = cell as? MahaVideoPreviewCell, let playerLayer = videoCell.playerLayer, videoCell.imageView.isHidden {
            playerLayer.removeFromSuperlayer()
            self.playerLayer = playerLayer
            imageView.layer.insertSublayer(playerLayer, at: 0)
        } else {
            imageView.image = cell.currentImage
        }

        containerView.addSubview(imageView)
        containerView.addSubview(fromVC.view)

        transitionImageOriginalFrame = imageView.frame
        updateSourceViewStatus(isTransitionStarting: true)
    }

    override func finish() {
        super.finish()
        finishTransitionAnimation()
    }

    func finishTransitionAnimation() {
        guard let transitionContext = transitionContext else {
            return
        }
        guard let fromVC = transitionContext.viewController(forKey: .from) as? MahaPhotoPreviewController,
              let toVC = transitionContext.viewController(forKey: .to) as? MahaThumbnailViewController else {
            return
        }

        let sourceModel = fromVC.arrDataSources[fromVC.currentIndex]
        let visibleIndexPaths = toVC.collectionView.indexPathsForVisibleItems

        var indexOffset = 0
        if !MahaPhotoUIConfiguration.default().sortAscending {
            if toVC.showCameraCell {
                indexOffset = -1
            }
            if #available(iOS 14.0, *), toVC.showAddPhotoCell {
                indexOffset -= 1
            }
        }
        var toIndex: Int?
        for indexPath in visibleIndexPaths {
            let dataSourceIndex = indexPath.row + indexOffset
            if dataSourceIndex >= toVC.arrDataSources.count || dataSourceIndex < 0 {
                continue
            }
            let model = toVC.arrDataSources[dataSourceIndex]
            if model == sourceModel {
                toIndex = indexPath.row
                break
            }
        }

        var toFrame: CGRect?

        if let toIndex = toIndex, let toCell = toVC.collectionView.cellForItem(at: IndexPath(row: toIndex, section: 0)) {
            toFrame = toVC.collectionView.convert(toCell.frame, to: transitionContext.containerView)
        }

        toVC.endPopTransition()

        UIView.animate(withDuration: transitionAnimationDuration, animations: {
            if let toFrame, self.playerLayer == nil {
                self.transitionImageView?.transform = .identity
                self.transitionImageView?.frame = toFrame
            } else {
                self.transitionImageView?.alpha = 0
            }
            self.transitionShadowView?.alpha = 0
        }) { _ in
            self.cleanupTemporaryViews()
            self.finishTransition?()
            transitionContext.finishInteractiveTransition()
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }

    override func cancel() {
        super.cancel()
        cancelTransitionAnimation()
    }

    func cancelTransitionAnimation() {
        guard let transitionContext = transitionContext else {
            return
        }

        var toFrame = transitionImageOriginalFrame
        if needCorrectYToZeroWhenCancel {
            toFrame.origin.y = 0
        }

        UIView.animate(withDuration: cancelAnimationDuration, animations: {
            self.transitionImageView?.transform = .identity
            self.transitionImageView?.frame = toFrame
            self.transitionShadowView?.alpha = 1
        }) { _ in
            self.updateSourceViewStatus(isTransitionStarting: false)
            if let playerLayer = self.playerLayer {
                playerLayer.removeFromSuperlayer()
                (self.currentCell as? MahaVideoPreviewCell)?.playerView.layer.insertSublayer(playerLayer, at: 0)
            }
            self.currentCell = nil
            self.playerLayer = nil
            self.cleanupTemporaryViews()
            self.cancelTransition?()
            transitionContext.cancelInteractiveTransition()
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }

    func updateSourceViewStatus(isTransitionStarting: Bool) {
        currentCell?.scrollView?.isScrollEnabled = !isTransitionStarting
        currentCell?.scrollView?.pinchGestureRecognizer?.isEnabled = !isTransitionStarting
        (currentCell as? MahaVideoPreviewCell)?.singleTapGes.isEnabled = !isTransitionStarting

        guard let transitionContext = transitionContext,
              let fromVC = transitionContext.viewController(forKey: .from) as? MahaPhotoPreviewController else {
            return
        }

        fromVC.view.backgroundColor = isTransitionStarting ? .clear : MahaPhotoUIConfiguration.default().previewVCBgColor
        fromVC.collectionView.isHidden = isTransitionStarting
    }

    private func cleanupTemporaryViews() {
        transitionImageView?.removeFromSuperview()
        transitionShadowView?.removeFromSuperview()
        transitionImageView = nil
        transitionShadowView = nil
    }

    private func resetInteractiveState() {
        transitionImageOriginalFrame = .zero
        panStartPoint = .zero
        translationBeforeInteraction = .zero
        isInteractive = false
    }
}

extension MahaPhotoPreviewPopInteractiveTransition: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let point = gestureRecognizer.location(in: viewController?.view)
        let shouldBegin = shouldStartTransition?(point) == true
        if shouldBegin,
           let viewController,
           let cell = viewController.collectionView.cellForItem(
               at: IndexPath(row: viewController.currentIndex, section: 0)
           ) as? MahaPreviewBaseCell,
           let scrollView = cell.scrollView {
            let contentSizeH = scrollView.contentSize.height
            needCorrectYToZeroWhenCancel = contentSizeH > scrollView.maha.height && scrollView.contentOffset.y >= 0
        }

        return shouldBegin
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if otherGestureRecognizer is UITapGestureRecognizer,
           otherGestureRecognizer.view is UIScrollView {
            return false
        }

        if otherGestureRecognizer == viewController?.collectionView.panGestureRecognizer {
            return false
        }

        return !(viewController?.collectionView.isDragging ?? false)
    }
}
