//
//  FilterValueCell.swift
//  Stats
//
//  Created by Leonid Kibukevich on 22.09.2021.
//

import UIKit

class FilterValueCell: UICollectionViewCell, HasShadowView, HasMarginsConstraints {
    private enum Constants {
        static let horizontalMargin: CGFloat = 8
    }
    
    enum Style {
        case shadow, border, color
        
        var cornerRadius: CGFloat {
            switch self {
                case .shadow:
                    return 12
                case .border:
                    return 4
                case .color:
                    return 6
            }
        }
        
        var isShadowHidden: Bool {
            switch self {
                case .shadow:
                    return false
                case .border, .color:
                    return true
            }
        }
        
        func font(isSelected _: Bool) -> UIFont {
            switch self {
                case .shadow:
                    return Font.main(size: 14, weight: .bold700)
                case .border:
                    return Font.main(size: 13, weight: .light300)
                case .color:
                    return Font.main(size: 13, weight: .light300)
            }
        }
        
        func borderWidth(isSelected: Bool) -> CGFloat {
            switch self {
                case .shadow, .color:
                    return 0
                case .border:
                    return isSelected ? 2 : 1
            }
        }
        
        func borderColor(isSelected: Bool) -> UIColor? {
            switch self {
                case .shadow, .color:
                    return nil
                case .border:
                    return isSelected ? Colors.orange : Colors.textMain
            }
        }
        
        func textColor(isSelected: Bool) -> UIColor? {
            switch self {
                case .shadow, .border:
                    return Colors.textMain
                case .color:
                    return isSelected ? .white : Colors.textMain
            }
        }
        
        func backgroundColor(isSelected: Bool) -> UIColor? {
            switch self {
                case .shadow, .border:
                    return .white
                case .color:
                    return isSelected ? Colors.orange : Colors.lightGray
            }
        }
    }
    
    @IBOutlet private(set) var titleLabel: UILabel!
    @IBOutlet private(set) var leftMargin: NSLayoutConstraint!
    @IBOutlet private(set) var rightMargin: NSLayoutConstraint!
    @IBOutlet private(set) var topMargin: NSLayoutConstraint!
    @IBOutlet private(set) var bottomMargin: NSLayoutConstraint!
    
    private var style: Style = .shadow
    var shadowView: ShadowView?
    
    class func prefferedSize(title: String, style: Style, height: CGFloat) -> CGSize {
        var size = title.boundingRect(
            with:CGSize(width: .greatestFiniteMagnitude, height: height),
            options: [],
            attributes: [.font: style.font(isSelected: true)],
            context: nil
        ).size
        size.width = size.width.rounded(.up) + Constants.horizontalMargin * 2
        size.height = height
        return size
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = .clear
        clipsToBounds = false
        contentView.backgroundColor = .white
        contentView.clipsToBounds = false
        contentView.borderColor = Colors.orange
        shadowView = contentView.addShadowView()
        margins = UIEdgeInsets(top: 0, left: Constants.horizontalMargin, bottom: 0, right: Constants.horizontalMargin)
    }
    
    func configure(title: String, style: Style, isSelection: Bool) {
        self.style = style
        titleLabel.text = title
        contentView.round(with: style.cornerRadius)
        shadowView?.isHidden = style.isShadowHidden
        updateSelection(isSelected: isSelection)
    }
    
    private func updateSelection(isSelected: Bool) {
        titleLabel.font = style.font(isSelected: isSelected)
        titleLabel.textColor = style.textColor(isSelected: isSelected)
        contentView.backgroundColor = style.backgroundColor(isSelected: isSelected)
        contentView.borderWidth = style.borderWidth(isSelected: isSelected)
        contentView.borderColor = style.borderColor(isSelected: isSelected)
    }
    
    override func systemLayoutSizeFitting(
        _ targetSize: CGSize,
        withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority,
        verticalFittingPriority: UILayoutPriority) -> CGSize {
        var size = super.systemLayoutSizeFitting(targetSize,
                                                 withHorizontalFittingPriority: horizontalFittingPriority,
                                                 verticalFittingPriority: verticalFittingPriority)
        size.height = targetSize.height
        
        return size
    }
}
