//
//  FilterTagView.swift
//  Stats
//
//  Created by Leonid Kibukevich on 25.10.2021.
//

import UIKit

class FilterTagView: UIView {
    private enum Constants {
        static let margins = UIEdgeInsets(top: 6, left: 8, bottom: 6, right: 9)
        static let spacing: CGFloat = 10
        static let iconWidth: CGFloat = 16
    }
    
    private let label = UILabel()
    private let iconImageView = UIImageView(image: UIImage(named: "delete"))
    
    private let font = Font.main(size: 13, weight: .light300)
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        backgroundColor = Colors.orange
        layer.cornerRadius = 6
        
        configureIconImageView()
        configureLabel()
    }
    
    // MARK: - Public
    
    func setName(_ name: String) {
        label.text = name
    }
    
    // MARK: - Private
    private func configureLabel() {
        addSubview(label)
        
        label.textAlignment = .center
        label.textColor = .white
        label.font = self.font
        
        label.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(Constants.margins.left)
            make.right.equalTo(iconImageView.snp.left).offset(-Constants.spacing)
            make.width.greaterThanOrEqualTo(1)
        }
    }
    
    private func configureIconImageView() {
        addSubview(iconImageView)
        
        iconImageView.tintColor = .white
        
        iconImageView.snp.makeConstraints { make in
            make.width.height.equalTo(Constants.iconWidth)
            make.right.equalTo(-Constants.margins.right)
            make.centerY.equalToSuperview()
        }
    }
    
    func prefferedSize(title: String, height: CGFloat) -> CGSize {
        var size = title.boundingRect(
            with: CGSize(width: .greatestFiniteMagnitude, height: height),
            options: [],
            attributes: [.font: self.font],
            context: nil
        ).size
        size.width = size.width.rounded(.up) + Constants.margins.left + Constants.margins.right + Constants.iconWidth + Constants.spacing
        size.height = height
        
        return size
    }
}
