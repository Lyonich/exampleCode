//
//  FilterModuleCell.swift
//  Stats
//
//  Created by Leonid Kibukevich on 05.10.2021.
//

import UIKit

protocol FilterModuleCellDelegate: AnyObject {
    func didUpdateSelected(filters: [String], parameters: [String])
    func localParameters() -> [FilterItem]
    func didChangeHeight(height: CGFloat)
}

class FilterModuleCell: UITableViewCell, FilterControllerDelegate {
    var filterController: FilterController?

    weak var delegate: FilterModuleCellDelegate?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        selectionStyle = .none
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setType(_ type: FilterType, isPopUpNewRowMode: Bool, showBorder: Bool = true, isScrollToFirstSelected: Bool = false) {
        guard self.filterController != nil else {
            filterController = FilterController(
                delegate: self,
                isPopUpNewRowMode: isPopUpNewRowMode,
                filterType: type,
                showBorder: showBorder,
                isScrollToFirstSelected: isScrollToFirstSelected
            )
            let filterView = filterController?.view
            contentView.addSubview(filterView!)
            
            return
        }
    }
    
    // MARK - FilterControllerDelegate
    
    func didUpdateSelected(filters: [String], parameters: [String]) {
        delegate?.didUpdateSelected(filters: filters, parameters: parameters)
    }

    func localParameters() -> [FilterItem] {
        return delegate?.localParameters() ?? []
    }
    
    func didChangeHeight(height: CGFloat) {
        guard let controller = self.filterController else { return }
        
        controller.view!.snp.remakeConstraints { make in
            make.top.equalTo(0)
            make.bottom.equalTo(0)
            make.left.right.equalTo(0)
            make.height.equalTo(height)
        }
        
        delegate?.didChangeHeight(height: height)
    }
}
