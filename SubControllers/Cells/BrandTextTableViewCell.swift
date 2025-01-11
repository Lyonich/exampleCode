//
//  BrandTextTableViewCell.swift
//  Stats
//
//  Created by Leonid Kibukevich on 29.10.2021.
//

import UIKit

class BrandTextTableViewCell: UITableViewCell {
    private let titleLabel = UILabel()
    private let selectionImageView = UIImageView(image: UIImage(named: "orangeCheck"))
    private let separatorView = UIView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
       
        selectionStyle = .none
        configureTitleLabel()
        configureSelectionImageView()
        configureSeparatorView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(title: String, isSelected: Bool) {
        titleLabel.text = title
        selectionImageView.isHidden = !isSelected
    }
    
    // MARK: - Private
    
    private func configureTitleLabel() {
        contentView.addSubview(titleLabel)
        
        titleLabel.font = Font.main(size: 14, weight: .regular400)
        
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(20)
            make.right.equalTo(-20)
            make.centerY.equalToSuperview()
        }
    }
    
    private func configureSelectionImageView() {
        contentView.addSubview(selectionImageView)
        
        selectionImageView.snp.makeConstraints { make in
            make.width.equalTo(12)
            make.height.equalTo(8)
            make.right.equalTo(-14)
            make.centerY.equalToSuperview()
        }
    }
    
    private func configureSeparatorView() {
        contentView.addSubview(separatorView)
        
        separatorView.backgroundColor = Colors.Palette.darkGrey85
        
        separatorView.snp.makeConstraints { make in
            make.left.equalTo(20)
            make.right.equalTo(-3)
            make.bottom.equalTo(0)
            make.height.equalTo(0.5)
        }
    }
}
