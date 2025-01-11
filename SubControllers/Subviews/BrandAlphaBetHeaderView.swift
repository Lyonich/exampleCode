//
//  BrandAlphaBetHeaderView.swift
//  Stats
//
//  Created by Leonid Kibukevich on 29.10.2021.
//

import UIKit

class BrandAlphaBetHeaderView: UITableViewHeaderFooterView {
    var label = UILabel()

    override var reuseIdentifier: String? {
        return "BrandAlphaBetHeaderView"
    }
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        contentView.backgroundColor = .white
        configureLabel()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }


    override func prepareForReuse() {
        super.prepareForReuse()
        
        label.text = nil
    }
    
    // MARK: - Private
    
    private func configureLabel() {
        contentView.addSubview(label)
        
        label.font = Font.main(size: 16, weight: .semibold600)
        label.textColor = Colors.orange
        
        label.snp.makeConstraints { make in
            make.left.equalTo(20)
            make.centerY.equalToSuperview()
        }
    }
}
