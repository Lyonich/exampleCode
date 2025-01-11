//
//  FilterViewModel.swift
//  Stats
//
//  Created by Leonid Kibukevich on 22.09.2021.
//

import Foundation

class FilterViewModel {
    var categories: [CategoryFilterViewModel] = [] {
        didSet {
            categories.forEach { $0.generateCells() }
        }
    }
    
    var images: [ImageMappingFilterElement] = []

    init(apiFilters: [FilterItem], paramerers: [FilterItem], images: [ImageMappingFilterElement]) {
        self.images = images

        var result: [CategoryFilterViewModel] = []
        apiFilters.forEach { result.append(CategoryFilterViewModel(apiFilter: $0)) }
        paramerers.forEach { result.append(CategoryFilterViewModel(localParameter: $0)) }

        categories = result
    }
}




