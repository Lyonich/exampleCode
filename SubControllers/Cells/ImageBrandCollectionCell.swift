//
//  ImageBrandCollectionCell.swift
//  Stats
//
//  Created by Leonid Kibukevich on 29.10.2021.
//

import SnapKit
import UIKit

class ImageBrandCollectionCell: UICollectionViewCell {
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        
        return imageView
    }()
    
    private var selectedIndicatorView = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        layout()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(brand: BrandItem, isSelected: Bool) {
        fill(withImage: brand.image)
        if brand.image.isNil {
            print("image not found for brand: \(brand.name)")
        }
        
        selectedIndicatorView.isHidden = !isSelected
    }

    private func fill(withImage image: UIImage?) {
        imageView.image = image
    }
    
    private func configureSelectedIndicatorView() {
        contentView.addSubview(selectedIndicatorView)
        
        selectedIndicatorView.backgroundColor = Colors.orange
        selectedIndicatorView.isHidden = true
        
        selectedIndicatorView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(3)
        }
    }

    private func layout() {
        contentView.pinSubview(imageView, inset: .init(top: 0, left: 4, bottom: 0, right: 4))
        configureSelectedIndicatorView()
    }
}
