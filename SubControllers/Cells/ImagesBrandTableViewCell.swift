//
//  ImageBrandTableViewCell.swift
//  Stats
//
//  Created by Leonid Kibukevich on 29.10.2021.
//

import UIKit

class ImagesBrandTableViewCell: UITableViewCell, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    enum Constants {
        static let inset: CGFloat = 10
        static let ratio: CGFloat = 0.283

        static let topInset: CGFloat = 14

        static let minimumLineSpacing: CGFloat = inset / 2
        static let minimumInteritemSpacing: CGFloat = inset / 2
    }

    typealias BrandSelectionAction = ((BrandItem) -> Void)

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collection = UICollectionView(frame: bounds, collectionViewLayout: layout)
        collection.isPagingEnabled = false
        collection.isScrollEnabled = false
        collection.showsHorizontalScrollIndicator = false
        collection.showsVerticalScrollIndicator = false
        collection.isPrefetchingEnabled = false
        collection.backgroundColor = .white
        
        return collection
    }()

    class var cellSize: CGSize {
        let screenWidth = UIScreen.main.bounds.width
        let width = (screenWidth - Constants.inset * 2 - Constants.minimumInteritemSpacing * 2) / 3
        let height = width * Constants.ratio
        
        return CGSize(width: width, height: height)
    }

    private var topBrands: [BrandItem] = []
    private var selectedIds: [String] = []

    var onBrandSelectAction: BrandSelectionAction?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        layout()
    }

    @available(*, unavailable)
    public required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func layout() {
        contentView.addSubview(collectionView)
        
        collectionView.snp.makeConstraints { make in
            make.left.top.bottom.equalTo(0)
            make.width.equalTo(UIScreen.main.bounds.width)
        }

        collectionView.registerClass(ImageBrandCollectionCell.self)

        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    func setBrands(imageBrands: [BrandItem], selectedIds: [String]) {
        topBrands = imageBrands
        self.selectedIds = selectedIds
        collectionView.reloadData()
    }

    class func prefferedHeight(for count: Int) -> CGFloat {
        let remainder = Float(count).truncatingRemainder(dividingBy: 3)
        let lineCount = count > 3 ? (Int(remainder) + count) / 3 : 1
        
        return CGFloat(lineCount) * (cellSize.height + Constants.minimumLineSpacing) + Constants.topInset
    }
    
    // MARK: - UICollectionViewDataSource
    
    func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, insetForSectionAt _: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: Constants.topInset, left: Constants.inset, bottom: 0, right: Constants.inset)
    }

    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return topBrands.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: ImageBrandCollectionCell = collectionView.dequeueReusableCellForIndexPath(indexPath)
        let brand = topBrands[indexPath.item]
        cell.configure(brand: brand, isSelected: selectedIds.contains(where: { $0 == brand.name }))
        
        return cell
    }
    
    // MARK: - UICollectionViewDelegate

    func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        onBrandSelectAction?(topBrands[indexPath.row])
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, sizeForItemAt _: IndexPath) -> CGSize {
        return Self.cellSize
    }

    func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, minimumLineSpacingForSectionAt _: Int) -> CGFloat {
        return Constants.minimumLineSpacing
    }

    func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, minimumInteritemSpacingForSectionAt _: Int) -> CGFloat {
        return Constants.minimumInteritemSpacing
    }
}
