//
//  VerticalSeparatorFilterHeaderView.swift
//  Stats
//
//  Created by Leonid Kibukevich on 01.10.2021.
//

import UIKit

class VerticalSeparatorFilterHeaderView: UICollectionReusableView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        
        configureSeparator()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private
    
    private func configureSeparator() {
        let separatorView = UIView()
        addSubview(separatorView)
        
        separatorView.backgroundColor = Colors.Palette.e0e0e0
        
        separatorView.snp.makeConstraints { make in
            make.width.equalTo(1)
            make.centerX.equalTo(self)
            make.height.equalTo(16)
            make.centerY.equalToSuperview()
        }
    }
}
