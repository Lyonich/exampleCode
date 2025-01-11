//
//  FilterController.swift
//  Stats
//
//  Created by Leonid Kibukevich on 21.09.2021.
//

import UIKit

protocol FilterControllerDelegate: AnyObject {
    func didUpdateSelected(filters: [String], parameters: [String])
    func localParameters() -> [FilterItem]
    func didChangeHeight(height: CGFloat)
}

protocol FilterControllerOutput {
    func viewReadyToWork()
    func didPressCellFilter(filterId: String, categoryIndex: Int)
    func didPressButtonFilter(categoryIndex: Int)
    func selectedFilters() -> [String]
    func selectedParameters() -> [String]
    func didChooseFiltersFromPopUp(values: [CategoryValueFilterViewModel], parentValue: CategoryValueFilterViewModel?, category: CategoryFilterViewModel)
}

protocol FilterControllerInput {
    func localParameters() -> [FilterItem]
    func updateData(filters: [CategoryFilterViewModel])
    func finishLoadFilters(filtersWithDefaultSelected: [CategoryFilterViewModel])
    func showPopUpFilters(for filter: CategoryFilterViewModel, parentValue: CategoryValueFilterViewModel?, title: String, selectedValues: [CategoryValueFilterViewModel], images: [ImageMappingFilterElement])
}

class FilterController: UIViewController, UITableViewDelegate, UITableViewDataSource, FilterPopUpControllerDelegate, FiltersRowCellDelegate, FilterRowCompactModeCellDelegate {
    enum State {
        case expanded
        case minimized
        case landscape
    }
    
    enum Constants {
        static let cellHeight: CGFloat = 40
        static let topInset: CGFloat = 12
    }
    
    private let tableViewInset = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
    
    weak var delegate: FilterControllerDelegate?
    
    private var presenter: FilterControllerOutput?
    
    private let tableView = UITableView()
    
    private var filters: [CategoryFilterViewModel] = []
    
    private let borderView = UIView()
    
    private let expandButton = UIButton(type: .custom)

    private var showBorder: Bool = true

    private var isLoading: Bool = true
    
    private var isScrollToFirstSelected: Bool = false
    
    var state: State = .expanded
    
    init(delegate: FilterControllerDelegate, isPopUpNewRowMode: Bool, filterType: FilterType, showBorder: Bool, isScrollToFirstSelected: Bool = false) {
        super.init(nibName: nil, bundle: nil)

        self.delegate = delegate
        self.showBorder = showBorder
        self.isScrollToFirstSelected = isScrollToFirstSelected
        presenter = FilterPresenter(controller: self, isPopUpNewRowMode: isPopUpNewRowMode, filterType: filterType)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTableView()
        configureBorderView(showBorder: showBorder)
        configureExpandButton()
        
        presenter?.viewReadyToWork()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        tableView.reloadData()
        recalculateHeightTableView()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        self.updateAppearance()
    }

    /// Height only TableView
    private var tableViewHeight: CGFloat {
        return isLoading ? SkeletonCell.preferedFilterSkeletonHeight : CGFloat(self.filters.count) * Constants.cellHeight
    }
    
    func updateAppearance() {

        if UIDevice.current.orientation.isLandscape {
            state = .landscape
            expandButton.isHidden = true
        } else {
            state = .expanded
            expandButton.isHidden = true
            expandButton.isSelected = false
        }
        
        tableView.reloadData()
        recalculateHeightTableView()
    }
    
    // MARK: - Actions
    
    @objc func expandButtonAction() {
        expandButton.isSelected = !expandButton.isSelected
        
        if expandButton.isSelected {
            state = .minimized
        } else {
            state = .expanded
        }
        
        tableView.reloadData()
        recalculateHeightTableView()
    }
    
    // MARK: - Private
    
    private func configureBorderView(showBorder: Bool) {
        view.insertSubview(borderView, at: 0)
        borderView.backgroundColor = .white

        let cornerRadius: CGFloat = 17
        borderView.layer.cornerRadius = cornerRadius
        if showBorder {
            borderView.layer.borderWidth = 1
            borderView.layer.borderColor = Colors.Palette.f4f4f4.cgColor
        } else {
            borderView.addShadowView(cornerRadius: cornerRadius)
        }
        borderView.clipsToBounds = true
        borderView.isHidden = false
        
        borderView.snp.makeConstraints { make in
            make.left.equalTo(12)
            make.right.equalTo(-12)
            make.top.equalTo(Constants.topInset)
            make.bottom.equalTo(tableView.snp.bottom).offset(tableViewInset.bottom)
        }
    }
    
    private func configureTableView() {
        borderView.addSubview(tableView)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isScrollEnabled = false
        tableView.separatorStyle = .none
        tableView.registerClass(FiltersRowCell.self)
        tableView.registerClass(FilterRowCompactModeCell.self)
        tableView.clipsToBounds = true

        tableView.snp.makeConstraints { make in
            make.left.equalTo(tableViewInset.left)
            make.top.equalTo(tableViewInset.top)
            make.right.equalTo(-tableViewInset.left)
            make.bottom.equalTo(0)
            make.height.greaterThanOrEqualTo(tableViewHeight)
        }
    }
    
    private func configureExpandButton() {
        view.addSubview(expandButton)
        
        expandButton.isHidden = true
        expandButton.setImage(UIImage(named: "plus"), for: .selected)
        expandButton.setImage(UIImage(named: "minus"), for: .normal)
        expandButton.addTarget(self, action: #selector(expandButtonAction), for: .touchUpInside)
        
        expandButton.snp.makeConstraints { make in
            make.width.height.equalTo(40)
            make.top.equalTo(borderView.snp.top)
            make.right.equalTo(borderView.snp.right)
        }
    }
    
    private func recalculateHeightTableView() {
        let offset: CGFloat = state == .expanded ? 0 : 12
        
        tableView.snp.remakeConstraints { make in
            make.left.equalTo(tableViewInset.left)
            make.top.equalTo(tableViewInset.top)
            make.right.equalTo(-tableViewInset.left)
            make.bottom.equalTo(-tableViewInset.bottom)
            make.height.greaterThanOrEqualTo(tableViewHeight + offset)
        }
        
        delegate?.didChangeHeight(height: tableViewHeight + tableViewInset.bottom + tableViewInset.top + Constants.topInset + offset)
    }
    
    // MARK: - FilterPopUpControllerDelegate
    
    func reportFiltersPickerViewController(_ controller: FilterPopUpController, didSelect values: [CategoryValueFilterViewModel], for filter: CategoryFilterViewModel, parentValue: CategoryValueFilterViewModel?) {
        presenter?.didChooseFiltersFromPopUp(values: values, parentValue: parentValue, category: filter)
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard !isLoading
        else {
            return SkeletonCell.preferedFilterSkeletonHeight
        }

        switch state {
            case .expanded:
                return Constants.cellHeight
            case .minimized, .landscape:
                return 64
        }
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard !isLoading
        else {
            return 1
        }

        switch state {
            case .expanded:
                return filters.count
            case .minimized:
                return 1
            case .landscape:
                return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard !isLoading
        else {
            let cell: SkeletonCell = .init(skeletonType: .filter)
            cell.startSkeleton()

            return cell
        }

        switch state {
            case .expanded:
                let cell: FiltersRowCell = tableView.dequeueReusableCellForIndexPath(indexPath)
                cell.delegate = self
                cell.setFilters(filters[indexPath.row].cells, categoryIndex: indexPath.row, isScrollToFirstSelected: isScrollToFirstSelected)
                
                return cell
            case .minimized:
                let cell: FilterRowCompactModeCell = tableView.dequeueReusableCellForIndexPath(indexPath)
                cell.configure(categories: filters, isShowsDeselected: false)
                cell.delegate = self
                
                return cell
            case .landscape:
                let cell: FilterRowCompactModeCell = tableView.dequeueReusableCellForIndexPath(indexPath)
                cell.configure(categories: filters, isShowsDeselected: true)
                cell.delegate = self
                
                return cell
        }
    }
    
    // MARK: - FiltersRowCellDelegate, FilterRowCompactModeCellDelegate
    
    func didPressCellFilter(data: CategoryValueFilterViewModel, categoryIndex: Int) {
        presenter?.didPressCellFilter(filterId: data.itemId, categoryIndex: categoryIndex)
    }
    
    func didPressButtonFilter(categoryIndex: Int) {
        presenter?.didPressButtonFilter(categoryIndex: categoryIndex)
    }
}

extension FilterController: FilterControllerInput {
    func localParameters() -> [FilterItem] {
        return delegate?.localParameters() ?? []
    }

    func showPopUpFilters(for filter: CategoryFilterViewModel, parentValue: CategoryValueFilterViewModel?, title: String, selectedValues: [CategoryValueFilterViewModel], images: [ImageMappingFilterElement]) {
        let vc = FilterPopUpController.buildView(filter: filter, parentValue: parentValue, screenTitle: title, values: filter.values, selectedViewValues: selectedValues, delegate: self, images: images)
        
        self.present(vc: vc)
    }
    
    func finishLoadFilters(filtersWithDefaultSelected: [CategoryFilterViewModel]) {
        isLoading = false
        filters = filtersWithDefaultSelected
        tableView.reloadData()

        recalculateHeightTableView()
        delegate?.didUpdateSelected(
            filters: presenter?.selectedFilters() ?? [],
            parameters: presenter?.selectedParameters() ?? []
        )
    }
    
    func updateData(filters: [CategoryFilterViewModel]) {
        self.filters = filters
        tableView.reloadData()
        
        delegate?.didUpdateSelected(
            filters: presenter?.selectedFilters() ?? [],
            parameters: presenter?.selectedParameters() ?? []
        )
        recalculateHeightTableView()
    }
    
    func recursiveSearchSelectedFilters(filters: [CategoryValueFilterViewModel]) -> [String] {
        var result = [String]()
        
        filters.forEach { filter in
            if filter.isSelected {
                if filter.itemId.isNotEmpty {
                    result.append(filter.itemId)
                    result.append(contentsOf: recursiveSearchSelectedFilters(filters: filter.children))
                }
            }
        }
        
        return result
    }
}
