//
//  FilterValueClosableCell.swift
//  Stats
//
//  Created by Leonid Kibukevich on 01.10.2021.
//

import UIKit

class FilterValueClosableCell: TextCollectionViewCell {
    private enum Constants {
        static let margins = UIEdgeInsets(top: 6, left: 9, bottom: 6, right: 9)
        static let spacing: CGFloat = 10
        static let iconWidth: CGFloat = 16
    }

    @IBOutlet private var titleIconSpacing: NSLayoutConstraint!
    @IBOutlet private var iconImageView: UIImageView!
    @IBOutlet private var iconWidth: NSLayoutConstraint!

    override class func prefferedSize(title: String, style: Style, height: CGFloat) -> CGSize {
        var size = title.boundingRect(
            with: CGSize(width: .greatestFiniteMagnitude, height: height),
            options: [],
            attributes: [.font: style.font(isSelected: true)],
            context: nil
        ).size
        size.width = size.width.rounded(.up) + Constants.margins.left + Constants.margins.right + Constants.spacing + Constants.iconWidth
        size.height = height
        
        return size
    }

    override var isSelected: Bool {
        didSet { updateSelection(isSelected: true) } // эти ячейки всегда должны быть визуально выбранные
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
        titleIconSpacing.constant = Constants.spacing
        margins = Constants.margins
        iconWidth.constant = Constants.iconWidth
    }

    override func configure(title: String, style: TextCollectionViewCell.Style) {
        super.configure(title: title, style: style)
        
        iconImageView.tintColor = style.textColor(isSelected: true)
        updateSelection(isSelected: true)
    }
}
