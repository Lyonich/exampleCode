//
//  CategoryFilterViewModel.swift
//  Stats
//
//  Created by Leonid Kibukevich on 06.10.2021.
//

import Foundation

class CategoryFilterViewModel: Equatable {
    static func == (lhs: CategoryFilterViewModel, rhs: CategoryFilterViewModel) -> Bool {
        return lhs.name == rhs.name
    }

    enum FilterType {
        case apiFilter
        case localParameter
    }
    
    var name: String = CommonStrings.empty
    var values: [CategoryValueFilterViewModel] = [] {
        didSet {
            generateCells()
        }
    }
    let filterType: FilterType
    var defaultFilterIds:  [String] = []
    var cells: [FilterCellType] = []
    
    init(apiFilter: FilterItem) {
        name = apiFilter.name
        filterType = .apiFilter
        defaultFilterIds = apiFilter.selectedFilterIds
        
        apiFilter.values.forEach({ apiFilterValue in
            values.append(CategoryValueFilterViewModel(apiFilterValue: apiFilterValue, selectedIds: apiFilter.selectedFilterIds))
        })
        
        // принудительно выделяем Total в случае если фильтр по умолчанию выбран не Total и у него есть children
        values.forEach { value in
            value.children.forEach({ $0.isSelected = $0.type == .total })
        }
        
        generateCells()
    }
    
    init(category childs: [CategoryValueFilterViewModel], name: String, filterType: FilterType) {
        self.values = childs
        self.name = name
        self.filterType = filterType
    }

    init(localParameter: FilterItem) {
        name = localParameter.name
        filterType = .localParameter
        defaultFilterIds = localParameter.selectedFilterIds

        localParameter.values.forEach({ apiFilterValue in
            values.append(CategoryValueFilterViewModel(apiFilterValue: apiFilterValue, selectedIds: localParameter.selectedFilterIds))
        })

        generateCells()
    }
    
    func generateCells() {
        cells.removeAll()
        
        for value in values {
            switch value.type {
                case .total:
                    cells.append(.usual(data: value))
                case .usual:
                    cells.append(.usual(data: value))
                case .hidden:
                    if value.isSelected {
                        cells.append(.closable(data: value))
                    }
                case .button:
                    cells.append(.button(title: value.name))
            }
        }
    }
}
