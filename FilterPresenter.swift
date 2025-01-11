//
//  FilterPresenter.swift
//  Stats
//
//  Created by Leonid Kibukevich on 21.09.2021.
//

import Foundation
import Macaroni

class FilterPresenter {
    @Injected private var logger: LoggerService
    private var controller: FilterControllerInput?
    private var interactor: FilterInteractorInput?
    
    private var filterViewModel: FilterViewModel?
    
    private var isPopUpNewRowMode: Bool
    
    init(controller: FilterControllerInput, isPopUpNewRowMode: Bool, filterType: FilterType) {
        self.controller = controller
        self.isPopUpNewRowMode = isPopUpNewRowMode
        self.interactor = FilterInteractor(presenter: self, filterType: filterType)
    }
}

extension FilterPresenter: FilterControllerOutput {
    func didChooseFiltersFromPopUp(values: [CategoryValueFilterViewModel], parentValue: CategoryValueFilterViewModel?, category: CategoryFilterViewModel) {
        guard let viewModel = filterViewModel else { return }
        
        let filteredValues = values.filter({ $0.parentItemId == parentValue?.itemId })
        
        if values.isEmpty {
            handlerForClearFiltersFromButtonPopUp(category: category)
            
            return
        }
        
        guard parentValue != nil else {
            handlerForSelectFiltersFromButtonPopUp(values: values, category: category)
            
            return
        }
    
        if isPopUpNewRowMode {
            removeAllAdditionalHiddenStateRow(for: nil)
            
            values.forEach({ $0.isSelected = true })
            
            let newCategory = CategoryFilterViewModel(
                category: filteredValues,
                name: parentValue?.name ?? CommonStrings.empty,
                filterType: category.filterType
            )
            if filteredValues.isNotEmpty {
                viewModel.categories.append(newCategory)
            }
        } else {
            values.forEach({ $0.isSelected = true })
            
            viewModel.categories.forEach { category in
                if category.name == parentValue?.parentItemId {
                    category.values = category.values.filter({ $0.type == .usual || $0.type == .total })
                    category.values.insert(contentsOf: filteredValues, at: 0)
                }
            }
        }
        
        viewModel.categories.forEach({ $0.generateCells() })
        self.filterViewModel = viewModel
        controller?.updateData(filters: viewModel.categories)
    }
    
    func selectedFilters() -> [String] {
        guard let viewModel = filterViewModel else { return [] }

        var result: Set<String> = []
        for category in viewModel.categories.filter({ $0.filterType == .apiFilter }) {
            for value in category.values {
                findSelectedTreeIds(startedCategory: value).filter { $0.isNotEmpty }.forEach { result.insert($0) }
            }
            
        }
        
        return Array(result)
    }

    func selectedParameters() -> [String] {
        guard let viewModel = filterViewModel else { return [] }

        var result: Set<String> = []
        for category in viewModel.categories.filter({ $0.filterType == .localParameter }) {
            for value in category.values {
                findSelectedTreeIds(startedCategory: value).filter { $0.isNotEmpty }.forEach { result.insert($0) }
            }

        }

        return Array(result)
    }
    
    func needGetSelectedFiltersModels() -> [CategoryValueFilterViewModel] {
        guard let viewModel = filterViewModel else { return [] }
        var result = [CategoryValueFilterViewModel]()
        for category in viewModel.categories {
            for value in category.values {
                result.append(contentsOf: findSelectedModels(startedCategory: value))
            }
            
        }

        return result
    }
    
    func findSelectedTreeIds(startedCategory: CategoryValueFilterViewModel) -> [String] {
        var result = [String]()

        if !startedCategory.isSelected {
            return []
        } else {
            result.append(startedCategory.itemId)
        }
        
        for child in startedCategory.children {
            let temp = findSelectedTreeIds(startedCategory: child)
            result.append(contentsOf: temp)
        }
        
        return result
    }
    
    func findSelectedModels(startedCategory: CategoryValueFilterViewModel) -> [CategoryValueFilterViewModel] {
        var result = [CategoryValueFilterViewModel]()
        
        if !startedCategory.isSelected {
            return []
        } else {
            result.append(startedCategory)
        }
        
        for child in startedCategory.children {
            let temp = findSelectedModels(startedCategory: child)
            result.append(contentsOf: temp)
        }
        
        return result
    }
    
    func didPressButtonFilter(categoryIndex: Int) {
        guard let viewModel = filterViewModel else { return }

        let category = viewModel.categories[categoryIndex]
        let choosedFilters = category.values.filter({ $0.type == .hidden && $0.isSelected })
            
        controller?.showPopUpFilters(for: category, parentValue: nil, title: category.name, selectedValues: choosedFilters, images: viewModel.images)
    }
    
    func didPressCellFilter(filterId: String, categoryIndex: Int) {
        guard let viewModel = filterViewModel else { return }
        
        let category = viewModel.categories[categoryIndex]
        guard let selectedFilterValue = category.values.first(where: { $0.itemId == filterId }) else { return }
        
        guard selectedFilterValue.type != .hidden else {
            if isPopUpNewRowMode {
                handlerTapForHiddenTypeFiltersForNewRowMode(selectedFilterValue: selectedFilterValue, category: category)
            } else {
                handlerTapForHiddenTypeFilters(selectedFilterValue: selectedFilterValue, category: category)
            }
            
            self.filterViewModel = viewModel
            self.filterViewModel?.categories.forEach({ $0.generateCells() })
            self.controller?.updateData(filters: viewModel.categories)
            
            return
        }
        
        if selectedFilterValue.isSelected {
            if selectedFilterValue.isNeedShowPopup {
                let choosedFilters = selectedFilterValue.children.filter({ $0.isSelected && $0.type != .total})
                
                controller?.showPopUpFilters(
                    for: CategoryFilterViewModel(
                        category: selectedFilterValue.children,
                        name: selectedFilterValue.itemId,
                        filterType: category.filterType
                    ),
                    parentValue: selectedFilterValue,
                    title: selectedFilterValue.name,
                    selectedValues: choosedFilters,
                    images: viewModel.images
                )
            } else {
                removeAllOldTreesFor(category: selectedFilterValue)
                
                category.values.forEach({ $0.isSelected = false })
                setDefaultSelected(category: category)
                
                removeAllAdditionalHiddenStateRow(for: category)
            }
        } else {
            if selectedFilterValue.type == .total {
                removeAllOldTreeForTotal(with: category, selectedFilterValue: selectedFilterValue)
                
                category.values.forEach({ $0.isSelected = false })
                category.values.first(where: { $0.type == .total })?.isSelected = true
            } else {
                removeAllOldTreesFor(category: selectedFilterValue)
                category.values.forEach({ $0.isSelected = false })
                selectedFilterValue.isSelected = true
                
                if selectedFilterValue.children.isNotEmpty {
                    addChildCategory(for: selectedFilterValue, categoryIndex: categoryIndex)
                }
            }
 
            removeAllAdditionalHiddenStateRow(for: category)
        }
        
        viewModel.categories.forEach({ $0.generateCells() })
        self.filterViewModel = viewModel
        self.controller?.updateData(filters: viewModel.categories)
    }
    
    ///Здесь происходит обработка данных в кейсе когда из попапа фильтров
    private func handlerForClearFiltersFromButtonPopUp(category: CategoryFilterViewModel) {
        guard let viewModel = filterViewModel else { return }
        
        category.values.forEach({ $0.isSelected = false })
        category.values.first(where: { $0.type == .total })?.isSelected = true
        
        self.filterViewModel = viewModel
        self.filterViewModel?.categories.forEach({ $0.generateCells() })
        controller?.updateData(filters: viewModel.categories)
    }
    
    ///Здесь происходит обработка события при выборе фильтров из попапа, вызванного из кнопки. У него отсуствует parentId
    private func handlerForSelectFiltersFromButtonPopUp(values: [CategoryValueFilterViewModel], category: CategoryFilterViewModel) {
        guard let viewModel = filterViewModel else { return }
        
        category.values.forEach({ $0.isSelected = false })
        values.forEach({ $0.isSelected = true })
        
        category.values.removeAll { value in
            return values.contains(where: { $0.itemId == value.itemId })
        }
        
        category.values.insert(contentsOf: values, at: 0)
        
        self.filterViewModel = viewModel
        self.filterViewModel?.categories.forEach({ $0.generateCells() })
        controller?.updateData(filters: viewModel.categories)
    }
    
    /// Было ли выбрано дерево раньше, если было выборанно, то удаляем
    private func removeAllOldTreesFor(category: CategoryValueFilterViewModel) {
        guard let viewModel = filterViewModel else { return }

        if category.children.contains(where: { $0.children.isNotEmpty }) || (category.children.isNotEmpty && category.isNeedShowPopup == false) {
            let olderTreeIds = selectedFilters() + selectedParameters()
            needRemoveTreeStructure(for: olderTreeIds, viewModel: viewModel)
        }
    }
    
    private func removeAllOldTreeForTotal(with category: CategoryFilterViewModel, selectedFilterValue: CategoryValueFilterViewModel) {
        guard let viewModel = filterViewModel else { return }
        
        if category.values.contains(where: { $0.children.isNotEmpty }) {
            let olderTreeIds = (selectedFilters() + selectedParameters()).filter { $0 != selectedFilterValue.parentItemId }
            needRemoveTreeStructure(for: olderTreeIds, viewModel: viewModel)
        }
    }
    
    ///Обработка нажатия на скрытый фильтр в режиме не переноса на новую строку
    private func handlerTapForHiddenTypeFilters(selectedFilterValue: CategoryValueFilterViewModel, category: CategoryFilterViewModel) {
        if let indexForRemove = category.values.firstIndex(of: selectedFilterValue) {
            category.values[indexForRemove].isSelected = false
        }
        
        if !category.values.contains(where: { $0.isSelected && $0.type == .hidden }) {
            setDefaultSelected(category: category)
        }
    }
    
    private func setDefaultSelected(category: CategoryFilterViewModel) {
        category.values.forEach { value in
            if category.defaultFilterIds.isEmpty {
                category.values.first(where: { $0.type == .total })?.isSelected = true
            } else {
                for selectedId in category.defaultFilterIds {
                    if value.itemId == selectedId {
                        value.isSelected = true
                        
                        if category.defaultFilterIds.contains(value.itemId) {
                            if let index = filterViewModel?.categories.firstIndex(where: { $0 == category }) {
                                addChildCategory(for: value, categoryIndex: index)
                            }
                        }
                    }
                }
            }
        }
    }
    
    /// Здесь происходит обрабокта нажатия на фильтр с крестиком (hidden) на следующей строке (только для режима isPopUpNewRowMode)
    private func handlerTapForHiddenTypeFiltersForNewRowMode(selectedFilterValue: CategoryValueFilterViewModel, category: CategoryFilterViewModel) {
        if let indexForRemove = category.values.firstIndex(of: selectedFilterValue) {
            category.values[indexForRemove].isSelected = false
            
            if isPopUpNewRowMode {
                category.values.remove(at: indexForRemove)
            }
        }
        
        if category.values.isEmpty {
            self.filterViewModel?.categories.removeAll(where: { $0.name == category.name })
            
            guard let viewModel = filterViewModel else { return }
            
            viewModel.categories.forEach { category in
                category.values.forEach { filterValue in
                    if filterValue.itemId == selectedFilterValue.parentItemId {
                        category.values.forEach({ $0.isSelected = false })
                        
                        if isPopUpNewRowMode {
                            category.values.first(where: { $0.type == .total })?.isSelected = true
                        } else {
                            setDefaultSelected(category: category)
                        }
                    }
                }
            }
        } else if category.values.filter({ $0.isSelected }).isEmpty {
            setDefaultSelected(category: category)
        }
    }
    
    /// Удаляет все строки с фильтрами где есть только hidden фильтры
    private func removeAllAdditionalHiddenStateRow(for category: CategoryFilterViewModel?) {
        guard let viewModel = filterViewModel else { return }
        
        if let category = category {
            guard category.values.contains(where: { $0.children.isNotEmpty }) else { return}
            
            for (index, categoryElement) in viewModel.categories.enumerated() {
                if categoryElement.values.contains(where: { $0.type == .hidden }) {
                    categoryElement.values.forEach({ $0.isSelected = false })
                    viewModel.categories.remove(at: index)
                } else if categoryElement.values.isEmpty {
                    viewModel.categories.remove(at: index)
                }
            }
        } else {
            for (index, categoryElement) in viewModel.categories.enumerated() {
                if categoryElement.values.contains(where: { $0.type == .hidden }) {
                    categoryElement.values.forEach({ $0.isSelected = false })
                    viewModel.categories.remove(at: index)
                } else if categoryElement.values.isEmpty {
                    viewModel.categories.remove(at: index)
                }
            }
        }
    }

    /// Функция удаляет все зависимые деревья для модели данных
    private func needRemoveTreeStructure(for ids: [String], viewModel: FilterViewModel) {
        guard ids.isNotEmpty else { return }
        
        viewModel.categories.removeAll { categoryFilter in
            let isDelete = ids.contains(where: { $0 == categoryFilter.name })
            if isDelete {
                categoryFilter.values.forEach { categoryFilterValue in
                    categoryFilterValue.isSelected = false
                    
                    if categoryFilterValue.itemId.isEmpty {
                        categoryFilterValue.isSelected = true
                    }
                }
                
                categoryFilter.values = categoryFilter.values.filter({ $0.type == .total || $0.type == .usual })
            }
            
            return isDelete
        }
    }
    
    func addChildCategory(for filter: CategoryValueFilterViewModel, categoryIndex: Int) {
        let parentCategory = filterViewModel?.categories[categoryIndex]
        if filter.children.isNotEmpty {
            // Проверка на показ PopUp
            if filter.children.filter({  $0.type == .total || $0.type == .usual }).count < 2 {
                let choosedFilters = filter.children.filter({ $0.isSelected && $0.type != .total})
                
                controller?.showPopUpFilters(
                    for: CategoryFilterViewModel(
                        category: filter.children,
                        name: filter.itemId,
                        filterType: parentCategory?.filterType ?? .apiFilter
                    ),
                    parentValue: filter,
                    title: filter.name,
                    selectedValues: choosedFilters,
                    images: filterViewModel?.images ?? []
                )
            } else {
                filterViewModel!.categories.insert(
                    CategoryFilterViewModel(
                        category: filter.children,
                        name: filter.itemId,
                        filterType: parentCategory?.filterType ?? .apiFilter
                    ),
                    at: categoryIndex + 1
                )
            }
        }
    }
    
    func viewReadyToWork() {
        interactor?.loadFilters(completion: { [self] result in
            switch result {
                case .success(let response):
                    let apiFilters = FilterViewModel(
                        apiFilters: response.filters,
                        paramerers: self.controller?.localParameters() ?? [],
                        images: response.imageMapping
                    )

                    if self.filterViewModel.isNil {
                        self.filterViewModel = apiFilters
                        // Если по дефолту выбран в фильтрах не тотал, то раскрываем фильтр при наличии дополнительных значений
                        for (index, defaultFilter) in apiFilters.categories.enumerated() {
                            if let element = defaultFilter.values.first(where: { valueFilter in
                                return defaultFilter.defaultFilterIds.contains(valueFilter.itemId)
                            }) {
                                addChildCategory(for: element, categoryIndex: index)
                            }
                        }

                        self.controller?.finishLoadFilters(filtersWithDefaultSelected: apiFilters.categories)
                    } else {
                        self.controller?.updateData(filters: apiFilters.categories)
                    }
                case .failure(let error):
                    self.logger.debug(from: self, message: "Request error: \(error)")

                    if !error.isCancelled {
                        self.controller?.updateData(filters: [])
                    }
            }
        })
    }
}

extension FilterPresenter: FilterInteractorOutput {
    
}
