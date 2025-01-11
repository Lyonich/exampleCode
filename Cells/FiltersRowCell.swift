//
//  FiltersRowCell.swift
//  Stats
//
//  Created by Leonid Kibukevich on 21.09.2021.
//

import UIKit

protocol FiltersRowCellDelegate: AnyObject {
    func didPressCellFilter(data: CategoryValueFilterViewModel, categoryIndex: Int)
    func didPressButtonFilter(categoryIndex: Int)
}

class FiltersRowCell: UITableViewCell, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    weak var delegate: FiltersRowCellDelegate?
    
    struct Constants {
        static let cellHeight: CGFloat = 32
    }
    
    private var cells = [FilterCellType]()
    
    private let collectionView: UICollectionView = {
        let layout = ReportFiltersFlowLayout()
        
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.showsHorizontalScrollIndicator = false
        view.showsVerticalScrollIndicator = false
        view.backgroundColor = .white
        view.registerNib(FilterValueCell.self)
        view.registerNib(FilterValueClosableCell.self)
        view.registerNib(FilterPopUpCell.self)
        view.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 48)
        
        view.allowsMultipleSelection = true
        view.clipsToBounds = true
        
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.left.equalTo(0)
            make.right.equalTo(0)
            make.top.bottom.equalTo(0)
        }
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        self.addRightFading()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setFilters(_ cells: [FilterCellType], categoryIndex: Int, isScrollToFirstSelected: Bool = false) {
        self.tag = categoryIndex
        self.cells = cells
        
        self.collectionView.reloadData()
        
        if isScrollToFirstSelected {
            DispatchQueue.main.async {
                self.setScrollToFirstSelected()
            }
        }
    }
    
    private func setScrollToFirstSelected() {
        for (index, cell) in cells.enumerated() {
            switch cell {
                case .usual(let data):
                    if data.isSelected {
                        collectionView.scrollToItem(at: IndexPath(row: index, section: 0), at: .left, animated: true)
                    }
                default: break
            }
        }
    }
    
    // MARK: - UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cells.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let type: FilterCellType = cells[indexPath.row]

        
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
                let cell: FilterPopUpCell = collectionView.dequeueReusableCellForIndexPath(indexPath)
                cell.configure(title: title, style: .color)
                
                return cell
        }
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let type: FilterCellType = cells[indexPath.row]

        switch type {
            case .usual(let data):
                return FilterValueCell.prefferedSize(title: data.name, style: .color, height: Constants.cellHeight)
            case .closable(let data):
                return FilterValueClosableCell.prefferedSize(title: data.name, style: .color, height: Constants.cellHeight)
            case .button(let title):
                return FilterPopUpCell.prefferedSize(title: title, style: .color, height: Constants.cellHeight)
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let type = cells[indexPath.row]
        
        switch type {
            case .button(_):
                delegate?.didPressButtonFilter(categoryIndex: self.tag)
            case .closable(let data):
                delegate?.didPressCellFilter(data: data, categoryIndex: self.tag)
            case .usual(let data):
                delegate?.didPressCellFilter(data: data, categoryIndex: self.tag)
        }
        
    }
}

