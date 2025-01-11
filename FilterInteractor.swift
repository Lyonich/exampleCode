//
//  FilterInteractor.swift
//  Stats
//
//  Created by Leonid Kibukevich on 21.09.2021.
//

import Foundation
import Macaroni

protocol FilterInteractorInput {
    func loadFilters(completion: @escaping ((Result<FiltersResponse, StatsAppError>) -> Void))
}

protocol FilterInteractorOutput {
    
}

class FilterInteractor: FilterInteractorInput {
    @Injected
    private var filterService: FilterService
    
    private var filterType: FilterType
    private var presenter: FilterInteractorOutput?
    
    init(presenter: FilterInteractorOutput, filterType: FilterType) {
        self.filterType = filterType
        self.presenter = presenter
    }
    
    // MARK: - FilterInteractorInput
    
    func loadFilters(completion: @escaping ((Result<FiltersResponse, StatsAppError>) -> Void)) {
        filterService.loadFilters(filterType: filterType, completion: completion)
    }
}
