//
//  MahaAlbumListCell.swift
//  MahaPhotoBrowser
//
//  Created by long on 2020/8/19.
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

class MahaAlbumListCell: UITableViewCell {
    private enum Layout {
        static let titleHeight: CGFloat = 30
        static let selectionIndicatorSize: CGFloat = 20
        static let disclosureIndicatorSize = CGSize(width: 15, height: 15)
        static let horizontalInset: CGFloat = 20
        static let externalStyleImageInset: CGFloat = 12
        static let itemSpacing: CGFloat = 10
        static let imageVerticalInset: CGFloat = 2
    }

    private lazy var coverImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        if MahaPhotoUIConfiguration.default().cellCornerRadio > 0 {
            view.layer.masksToBounds = true
            view.layer.cornerRadius = MahaPhotoUIConfiguration.default().cellCornerRadio
        }
        return view
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .maha.font(ofSize: 17)
        label.textColor = .maha.albumListTitleColor
        return label
    }()

    private lazy var countLabel: UILabel = {
        let label = UILabel()
        label.font = .maha.font(ofSize: 16)
        label.textColor = .maha.albumListCountColor
        return label
    }()

    private var displayedImageIdentifier: String?

    private var model: MahaAlbumListModel!

    private var browserStyle: MahaPhotoBrowserStyle = .embedAlbumList

    private var indicator: UIImageView = {
        var image = UIImage.maha.getImage("zl_ablumList_arrow")
        if isRTL() {
            image = image?.imageFlippedForRightToLeftLayoutDirection()
        }

        let view = UIImageView(image: image)
        view.contentMode = .scaleAspectFit
        return view
    }()

    lazy var selectBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.isUserInteractionEnabled = false
        btn.isHidden = true
        btn.setImage(.maha.getImage("zl_albumSelect"), for: .selected)
        return btn
    }()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let width = contentView.maha.width
        let height = contentView.maha.height

        let coverImageWidth = height - Layout.imageVerticalInset * 2
        let maxTitleWidth = width - coverImageWidth - 80

        var titleWidth: CGFloat = 0
        var countWidth: CGFloat = 0
        if let model = model {
            titleWidth = min(
                bounds.width / 3 * 2,
                model.title.maha.boundingRect(
                    font: .maha.font(ofSize: 17),
                    limitSize: CGSize(width: CGFloat.greatestFiniteMagnitude, height: Layout.titleHeight)
                ).width
            )
            titleWidth = min(titleWidth, maxTitleWidth)

            countWidth = ("(" + String(model.count) + ")").maha
                .boundingRect(
                    font: .maha.font(ofSize: 16),
                    limitSize: CGSize(width: CGFloat.greatestFiniteMagnitude, height: Layout.titleHeight)
                ).width
        }

        if isRTL() {
            let imageViewX: CGFloat
            if browserStyle == .embedAlbumList {
                imageViewX = width - coverImageWidth
            } else {
                imageViewX = width - coverImageWidth - Layout.externalStyleImageInset
            }

            coverImageView.frame = CGRect(x: imageViewX, y: Layout.imageVerticalInset, width: coverImageWidth, height: coverImageWidth)
            titleLabel.frame = CGRect(
                x: coverImageView.maha.left - titleWidth - Layout.itemSpacing,
                y: (height - Layout.titleHeight) / 2,
                width: titleWidth,
                height: Layout.titleHeight
            )

            countLabel.frame = CGRect(
                x: titleLabel.maha.left - countWidth - Layout.itemSpacing,
                y: (height - Layout.titleHeight) / 2,
                width: countWidth,
                height: Layout.titleHeight
            )
            selectBtn.frame = CGRect(x: Layout.horizontalInset, y: (height - Layout.selectionIndicatorSize) / 2, width: Layout.selectionIndicatorSize, height: Layout.selectionIndicatorSize)
            indicator.frame = CGRect(x: Layout.horizontalInset, y: (bounds.height - Layout.disclosureIndicatorSize.height) / 2, width: Layout.disclosureIndicatorSize.width, height: Layout.disclosureIndicatorSize.height)
            return
        }

        let imageViewX: CGFloat
        if browserStyle == .embedAlbumList {
            imageViewX = 0
        } else {
            imageViewX = Layout.externalStyleImageInset
        }

        coverImageView.frame = CGRect(x: imageViewX, y: Layout.imageVerticalInset, width: coverImageWidth, height: coverImageWidth)
        titleLabel.frame = CGRect(
            x: coverImageView.maha.right + Layout.itemSpacing,
            y: (bounds.height - Layout.titleHeight) / 2,
            width: titleWidth,
            height: Layout.titleHeight
        )
        countLabel.frame = CGRect(x: titleLabel.maha.right + Layout.itemSpacing, y: (height - Layout.titleHeight) / 2, width: countWidth, height: Layout.titleHeight)
        selectBtn.frame = CGRect(x: width - Layout.horizontalInset - Layout.selectionIndicatorSize, y: (height - Layout.selectionIndicatorSize) / 2, width: Layout.selectionIndicatorSize, height: Layout.selectionIndicatorSize)
        indicator.frame = CGRect(x: width - Layout.horizontalInset - Layout.disclosureIndicatorSize.width, y: (height - Layout.disclosureIndicatorSize.height) / 2, width: Layout.disclosureIndicatorSize.width, height: Layout.disclosureIndicatorSize.height)
    }

    func setupUI() {
        backgroundColor = .maha.albumListBgColor
        selectionStyle = .none
        accessoryType = .none

        contentView.addSubview(coverImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(countLabel)
        contentView.addSubview(selectBtn)
        contentView.addSubview(indicator)
    }

    func configureCell(model: MahaAlbumListModel, style: MahaPhotoBrowserStyle) {
        self.model = model
        browserStyle = style

        titleLabel.text = model.title
        countLabel.text = "(" + String(model.count) + ")"

        if style == .embedAlbumList {
            selectBtn.isHidden = false
            indicator.isHidden = true
        } else {
            indicator.isHidden = false
            selectBtn.isHidden = true
        }

        displayedImageIdentifier = model.headImageAsset?.localIdentifier
        if let asset = model.headImageAsset {
            let w = bounds.height * 2.5
            MahaPhotoManager.fetchImage(for: asset, size: CGSize(width: w, height: w)) { [weak self] image, _ in
                if self?.displayedImageIdentifier == self?.model.headImageAsset?.localIdentifier {
                    self?.coverImageView.image = image ?? .maha.getImage("zl_defaultphoto")
                }
            }
        }
    }
}
