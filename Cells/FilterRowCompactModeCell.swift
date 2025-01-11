//
//  FilterRowCompactModeCell.swift
//  Stats
//
//  Created by Leonid Kibukevich on 04.10.2021.
//

import UIKit

fileprivate class FiltersCompactHeaderView: UICollectionReusableView {
    private var titleLabel = UILabel()

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        commonInit()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }

    private func commonInit() {
        addSubview(titleLabel)
        titleLabel.backgroundColor = .white
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(0)
            make.left.equalTo(1)
            make.height.equalTo(12)
        }
        titleLabel.font = Font.main(size: 10, weight: .light300)
    }

    func configure(title: String) {
        titleLabel.text = title
    }
}

protocol FilterRowCompactModeCellDelegate: AnyObject {
    func didPressCellFilter(data: CategoryValueFilterViewModel, categoryIndex: Int)
    func didPressButtonFilter(categoryIndex: Int)
}

class FilterRowCompactModeCell: ReportFiltersTableViewCell, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    enum UIConstants {
        static let headerId = "headerView"
        static let footerId = "footerId"
    }
    private var collectionView: UICollectionView!
    
    var categories = [CategoryFilterViewModel]()
    
    private var isShowsDeselected: Bool = false
    private var rightMargin: CGFloat = 0
    
    weak var delegate: FilterRowCompactModeCellDelegate?
    
    override func commonInit() {
        super.commonInit()
        
        let layout = ReportFiltersFlowLayout()

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.backgroundColor = .white
        collectionView.clipsToBounds = true
        collectionView.alwaysBounceVertical = false
        collectionView.registerClass(ReportFilterSeparatorCollectionViewCell.self)

        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 40)
        
        collectionView.register(FiltersCompactHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: UIConstants.headerId)
        
        collectionView.register(VerticalSeparatorFilterHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: UIConstants.footerId)
        
        collectionView.registerNib(FilterValueCell.self)
        collectionView.registerNib(FilterValueClosableCell.self)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        contentView.addSubview(collectionView)
        
        collectionView.snp.makeConstraints { make in
            make.left.right.equalTo(0)
            make.top.equalTo(6)
            make.height.equalTo(60)
        }
        
        self.clipsToBounds = true
        self.addRightFading()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    func configure(categories: [CategoryFilterViewModel], isShowsDeselected: Bool) {
        self.categories = categories
        self.isShowsDeselected = isShowsDeselected
        rightMargin = 0
        collectionView.reloadData()
    }
    
    func getCells(for section: Int) -> [FilterCellType] {
        if isShowsDeselected {
            return categories[section].cells
        } else {
            let filteredArray = categories[section].cells.filter {
                switch $0 {
                 
                    case .usual(let data):
                        return data.isSelected
                    case .closable(let data):
                        return data.isSelected
                    case .button( _):
                        return false
                }
             }
            
            return filteredArray
        }
    }
    
    // MARK: - UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return getCells(for: section).count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let filteredArray = getCells(for: indexPath.section)
        
        let type = filteredArray[indexPath.row]
        
        switch type {
            case .usual(let data):
                let cell: FilterValueCell = collectionView.dequeueReusableCellForIndexPath(indexPath)
                cell.backgroundColor = .clear
                cell.configure(title: data.name, style: .color, isSelection: data.isSelected)
                
                return cell
            case .closable(let data):
                let cell: FilterValueClosableCell = collectionView.dequeueReusableCellForIndexPath(indexPath)
                cell.configure(title: data.name, style: .color)
                
                return cell
            case .button(let title):
                let cell: FilterValueCell = collectionView.dequeueReusableCellForIndexPath(indexPath)
                cell.configure(title: title, style: .border, isSelection: false)
                
                return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        switch kind {
            case UICollectionView.elementKindSectionHeader:
                let view: FiltersCompactHeaderView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: UIConstants.headerId, for: indexPath) as! FiltersCompactHeaderView
                
                view.configure(title: categories[indexPath.section].name.uppercased())

                return view
            case UICollectionView.elementKindSectionFooter:
                let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: UIConstants.footerId, for: indexPath)
                
                return headerView
            default:
                return UICollectionReusableView()
        }
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: 1, height: 60)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: 16, height: 60)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return Constants.itemSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cells = getCells(for: indexPath.section)
        let type = cells[indexPath.row]
        
        switch type {
            case .usual(let data):
                return FilterValueCell.prefferedSize(title: data.name, style: .color, height: 32)
            case .closable(let data):
                return FilterValueClosableCell.prefferedSize(title: data.name, style: .color, height: 32)
            case .button(let title):
                return FilterValueCell.prefferedSize(title: title, style: .color, height: 32)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cells = getCells(for: indexPath.section)
        let type = cells[indexPath.row]
        
        switch type {
            case .button(_):
                delegate?.didPressButtonFilter(categoryIndex: self.tag)
            case .closable(let data):
                delegate?.didPressCellFilter(data: data, categoryIndex: indexPath.section)
            case .usual(let data):
                delegate?.didPressCellFilter(data: data, categoryIndex: indexPath.section)
        }
    }
}
