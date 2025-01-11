//
//  CategoryFilterViewModel.swift
//  Stats
//
//  Created by Leonid Kibukevich on 06.10.2021.
//

import Foundation

class CategoryValueFilterViewModel: Equatable {
    static func == (lhs: CategoryValueFilterViewModel, rhs: CategoryValueFilterViewModel) -> Bool {
        return lhs.itemId == rhs.itemId
    }
    
    enum ButtonType: Int {
        case usual = 1
        case hidden = 2
        case total = 3
        case button = 4
    }
    
    let itemId: String
    var totalId: String?
    var name: String
    var children: [CategoryValueFilterViewModel] = []
    var parentItemId: String = CommonStrings.empty
    var isSelected: Bool = false
    var type: ButtonType = .usual
    
    var isNeedShowPopup = false
    
    init(apiFilterValue: FilterValueItem, selectedIds: [String]) {
        self.itemId = apiFilterValue.itemId
        
        self.type = ButtonType(rawValue: apiFilterValue.itemType.rawValue) ?? .usual
        
        ///Total
        if self.itemId.isEmpty && selectedIds.isEmpty {
            self.isSelected = true
        } else if selectedIds.contains(self.itemId) {
            self.isSelected = true
        }
        
        self.name = apiFilterValue.name
        
        self.parentItemId = apiFilterValue.parentItemId
        
        
        apiFilterValue.children.forEach { children in
            self.children.append(CategoryValueFilterViewModel(apiFilterValue: children, selectedIds: selectedIds) )
        }
        
        if type == .usual && children.contains(where: { $0.children.isEmpty && $0.type == .hidden }) {
            isNeedShowPopup = true
        }
    }
}
