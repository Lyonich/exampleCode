//
//  FilterPopUpController.swift
//  Stats
//
//  Created by Leonid Kibukevich on 30.09.2021.
//

import Typist
import UIKit
import TTGTags

protocol FilterPopUpControllerDelegate: AnyObject {
    func reportFiltersPickerViewController(
        _ controller: FilterPopUpController,
        didSelect values: [CategoryValueFilterViewModel], for filter: CategoryFilterViewModel,
        parentValue: CategoryValueFilterViewModel?
    )
}

class FilterPopUpController: PanelViewController, Buildable, KeyboardHandling, TTGTagCollectionViewDelegate, TTGTagCollectionViewDataSource, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    static var storyboard: UIStoryboard {
        return Storyboards.sales
    }
    
    private enum Constants {
        static let margins = ReportsAppearance.filterPickerMargins
        static let spacing: CGFloat = 10
        static let tableCellHeight: CGFloat = 40
        static let collectionCellHeight: CGFloat = 32
        static let allBrandsTitleCellHeight: CGFloat = 48
        static let searchBarPadding: CGFloat = 8
        
        static let filtersInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        static let filterInterItemInset: CGFloat = 8
    }
    
    private enum CellType {
        case common(value: CategoryValueFilterViewModel, isSelected: Bool)
    }
    
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var searchBar: UISearchBar!
    private var collectionView: TTGTagCollectionView!
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var selectButton: UIButton!
    @IBOutlet private var tableViewHeight: NSLayoutConstraint!
    @IBOutlet private var closeButton: UIButton!
    @IBOutlet private var clearButton: UIButton!
    
    @IBOutlet var closeButtonWidth: NSLayoutConstraint!
    @IBOutlet var headerLeftMargin: NSLayoutConstraint!
    @IBOutlet var headerRightMargin: NSLayoutConstraint!
    
    @IBOutlet var searchBarLeftMargin: NSLayoutConstraint!
    @IBOutlet var searchBarRightMargin: NSLayoutConstraint!
    
    @IBOutlet var bottomBarConstraint: NSLayoutConstraint!
    
    private var cells: [String: [CellType]] = [:]
    
    private(set) var screenTitle: String = CommonStrings.empty
    private(set) var sectionTitles: [String] = []
    let keyboard = Typist()
    
    
    private var viewFilter: CategoryFilterViewModel!
    private var viewParentValue: CategoryValueFilterViewModel?
    private var viewValues: [CategoryValueFilterViewModel] = []
    private var selectedViewValues: [CategoryValueFilterViewModel] = [] {
        didSet {
            guard isViewLoaded else { return }
            
            clearButton.isHidden = selectedViewValues.isEmpty
        }
    }
    private var images: [BrandItem] = []
    
    private var filterTags: [FilterTagView] = []
    
    private var additionalSectionsCount: Int {
        if images.isEmpty {
            return 1
        }
        
        return 2
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return [.portrait, .landscapeLeft, .landscapeRight]
    }
    
    weak var delegate: FilterPopUpControllerDelegate?
    
    static func buildView(filter: CategoryFilterViewModel, parentValue: CategoryValueFilterViewModel? = nil, screenTitle: String, values: [CategoryValueFilterViewModel], selectedViewValues: [CategoryValueFilterViewModel], delegate: FilterPopUpControllerDelegate?, images: [ImageMappingFilterElement]) -> Self {
        let controller = storyboard.instantiateViewController(Self.self)
        controller.viewFilter = filter
        controller.viewParentValue = parentValue
        images.forEach({ controller.images.append(BrandItem(name: $0.id ?? CommonStrings.empty, imageName: $0.imageCode ?? CommonStrings.empty)) })
        controller.screenTitle = screenTitle
        controller.selectedViewValues = selectedViewValues.filter({ $0.name.caseInsensitiveCompare("Total") != .orderedSame &&
                                                            $0.name.caseInsensitiveCompare("TOP30") != .orderedSame})
        controller.viewValues = values.filter({ $0.name.caseInsensitiveCompare("Total") != .orderedSame &&
                                            $0.name.caseInsensitiveCompare("TOP30") != .orderedSame})
        
        selectedViewValues.forEach { selectedValue in
            let tagView = FilterTagView()
            tagView.setName(selectedValue.name)
            controller.filterTags.append(tagView)
        }
        
        controller.delegate = delegate
        
        return controller
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView = TTGTagCollectionView()
        
        title = screenTitle
        
        configureTableHeight()
        
        headerLeftMargin.constant = Constants.margins.left - (closeButtonWidth.constant - (closeButton.imageView?.image?.size.width ?? 0)) / 2
        headerRightMargin.constant = Constants.margins.right
        searchBarLeftMargin.constant = Constants.margins.left - Constants.searchBarPadding
        searchBarRightMargin.constant = Constants.margins.right - Constants.searchBarPadding
        
        titleLabel.text = title
        titleLabel.font = TextStyle.commonTitle.font
        
        selectButton.apply(style: .main)
        clearButton.apply(style: .secondary)
        clearButton.isHidden = selectedViewValues.isEmpty
        
        tableView.configureForAutolayout(Constants.tableCellHeight)
        tableView.registerClass(BrandTextTableViewCell.self)
        tableView.registerClass(ImagesBrandTableViewCell.self)
        tableView.registerNib(BrandTitleTableViewCell.self)
        tableView.registerClassForHeaderFooterView(BrandAlphaBetHeaderView.self)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.sectionIndexColor = Colors.orange
        
        collectionView.alignment = .left
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .white
        collectionView.horizontalSpacing = Constants.filterInterItemInset
        collectionView.verticalSpacing = Constants.filterInterItemInset
        collectionView.manualCalculateHeight = true

        searchBar.delegate = self
        searchBar.placeholder = "Type \(screenTitle.lowercased()) here"
        
        configureAppearance()
        collectionView.preferredMaxLayoutWidth = tableView.frame.width - Constants.filtersInset.left -  Constants.filtersInset.right
        reload()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        startKeyboardHandling()
    }

    // MARK: - TTGTagCollectionViewDelegate
    
    func tagCollectionView(_ tagCollectionView: TTGTagCollectionView!, didSelectTag tagView: UIView!, at index: UInt) {
        filterTags.remove(at: Int(index))
        selectedViewValues.remove(at: Int(index))
        tagCollectionView.reload()
        reload()
    }
    
    func tagCollectionView(_ tagCollectionView: TTGTagCollectionView!, sizeForTagAt index: UInt) -> CGSize {
        guard selectedViewValues.isNotEmpty else { return .zero }
        
        let size = filterTags[Int(index)].prefferedSize(title: selectedViewValues[Int(index)].name,
                                                                      height: Constants.collectionCellHeight)
        
        return size
    }
    
    // MARK: - TTGTagCollectionViewDataSource
    
    func numberOfTags(in tagCollectionView: TTGTagCollectionView!) -> UInt {
        return UInt(filterTags.count)
    }
    
    func tagCollectionView(_ tagCollectionView: TTGTagCollectionView!, tagViewFor index: UInt) -> UIView! {
        return filterTags[Int(index)]
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        stopKeyboardHandling()
        
        super.viewWillDisappear(animated)
    }
    
    func handleKeyboard(forEvent event: Typist.KeyboardEvent, options: Typist.KeyboardOptions) {
        switch event {
            case .willShow, .didShow, .willChangeFrame, .didChangeFrame:
                var inset = tableView.contentInset
                inset.bottom = options.endFrame.height - view.safeAreaInsets.bottom
                bottomBarConstraint.constant = inset.bottom
            default:
                bottomBarConstraint.constant = 0
        }
        
        UIView.animate(withDuration: options.animationDuration,
                       delay: 0,
                       options: UIView.AnimationOptions(rawValue: UInt(options.animationCurve.rawValue << 16)),
                       animations: {
                        self.view.layoutIfNeeded()
                       })
    }
    
    private func configureTableHeight() {
        tableViewHeight.constant = CGFloat(viewValues.count) * Constants.tableCellHeight
    }
    
    private func reload() {
        configureAppearance()
        
        makeDataSource()
    }
    
    private func makeDataSource() {
        sectionTitles = []
        cells = [:]
        
        let searchText = searchBar.text ?? CommonStrings.empty
        let values = searchText.isEmpty ? self.viewValues : self.viewValues.filter { $0.name.lowercased().contains(searchText.lowercased()) }
        
        let sortedValues = values.sorted(by: { $0.name.lowercased() < $1.name.lowercased() }).filter { !String($0.name.prefix(1)).isNumber }
        
        sortedValues.forEach {
            let title = String($0.name.prefix(1)).uppercased()
            
            var sectionCells = cells[title] ?? []
            sectionCells.append(.common(value: $0, isSelected: selectedViewValues.contains($0)))
            cells[title] = sectionCells
            
            if !sectionTitles.contains(title) {
                sectionTitles.append(title)
            }
        }
        
        collectionView.reload()
        tableView.reloadData()
    }
    
    private func configureAppearance() {
        var buttonTitle: String
        
        if selectedViewValues.isEmpty {
            buttonTitle = "View All \(screenTitle)"
        } else {
            buttonTitle = "Select \(selectedViewValues.count)"
        }
        
        selectButton.setTitle(buttonTitle, for: .normal)
    }
}

extension FilterPopUpController {
    @IBAction private func selectButtonPressed(_: Any) {
        var selectedViewValues = self.selectedViewValues
        
        if let parentValue = self.viewParentValue {
            selectedViewValues.append(parentValue)
        }
        
        delegate?.reportFiltersPickerViewController(self, didSelect: selectedViewValues, for: viewFilter, parentValue: viewParentValue)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func closeButtonPressed(_: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func clearButtonPressed(_: Any) {
        selectedViewValues.removeAll()
        filterTags.removeAll()

        reload()
    }
    
    // MARK: - UITableViewDataSource
    
    func numberOfSections(in _: UITableView) -> Int {
        return sectionTitles.count + additionalSectionsCount
    }
    
    func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard section > 0 else { return 0 }
        
        if additionalSectionsCount > 1 {
            if section == 1 {
                return 2
            }
        }
        
        let title = sectionTitles[section - additionalSectionsCount]
        
        return cells[title]!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if additionalSectionsCount > 1 {
            if indexPath.section == 1 {
                if indexPath.row == 0 {
                    return createTopBrandsImageCell(tableView: tableView, indexPath: indexPath)
                }
                
                let cell: BrandTitleTableViewCell = tableView.dequeueReusableCellForIndexPath(indexPath)
                
                return cell
            }
        }
        
        let title = sectionTitles[indexPath.section - additionalSectionsCount]
        
        switch cells[title]![indexPath.row] {
            case let .common(value, isSelected):
                let cell: BrandTextTableViewCell = tableView.dequeueReusableCellForIndexPath(indexPath)
                cell.configure(title: value.name, isSelected: isSelected)
                
                return cell
        }
    }
    
    private func createTopBrandsImageCell(tableView: UITableView, indexPath: IndexPath) -> ImagesBrandTableViewCell {
        let cell: ImagesBrandTableViewCell = tableView.dequeueReusableCellForIndexPath(indexPath)
        
        cell.setBrands(imageBrands: images, selectedIds: selectedViewValues.compactMap({ $0.itemId }))
        
        cell.onBrandSelectAction = { [weak self] selectedBrand in
            guard let self = self else { return }
            
            guard let filterValue = self.viewValues.filter({ $0.itemId == selectedBrand.name }).first else { return }

            if self.selectedViewValues.contains(where: { $0.itemId == filterValue.itemId }) {
                guard let index = self.selectedViewValues.firstIndex(of: filterValue) else { return }
                
                self.selectedViewValues.remove(at: index)
                self.filterTags.remove(at: index)
            } else {
                self.selectedViewValues.insert(filterValue, at: 0)
                let tagView = FilterTagView()
                tagView.setName(filterValue.name)
                self.filterTags.insert(tagView, at: 0)
            }
            
            self.reload()
        }
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if additionalSectionsCount > 1 {
            if indexPath.section == 1 {
                if indexPath.row == 0 {
                    return TopBrandsTableViewCell.prefferedHeight(for: images.count)
                }
                
                return Constants.allBrandsTitleCellHeight
            }
        }
        return Constants.tableCellHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard indexPath.section > additionalSectionsCount - 1 else { return }
        
        let title = sectionTitles[indexPath.section - additionalSectionsCount]
        
        switch cells[title]![indexPath.row] {
            case let .common(value, isSelected):
                if isSelected {
                    guard let index = selectedViewValues.firstIndex(of: value) else { return }
                    
                    selectedViewValues.remove(at: index)
                    filterTags.remove(at: index)
                    
                } else {
                    selectedViewValues.insert(value, at: 0)
                    let tagView = FilterTagView()
                    tagView.setName(value.name)
                    filterTags.insert(tagView, at: 0)
                }
        }
        
        reload()
    }
    
    func sectionIndexTitles(for _: UITableView) -> [String]? {
        return nil //sectionTitles временно отключено до следующего релиза
    }
    
    func tableView(_: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        guard index > additionalSectionsCount - 1 else { return 0 }
        
        guard let sectionIndex = sectionTitles.firstIndex(of: title) else { return 0 }
        
        return sectionIndex + additionalSectionsCount
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            collectionView.preferredMaxLayoutWidth = tableView.frame.width - Constants.filtersInset.left -  Constants.filtersInset.right
            collectionView.frame = CGRect(
                x: Constants.filtersInset.left,
                y: 0,
                width: tableView.frame.size.width - Constants.filtersInset.left - Constants.filtersInset.right,
                height: collectionView.contentSize.height
            )
            
            let containerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: collectionView.contentSize.height))
            containerView.backgroundColor = .clear
            containerView.addSubview(collectionView)
            
            return containerView
        }
        
        if section >= additionalSectionsCount {
            let headerView = tableView.dequeueReusableHeaderFooterView(BrandAlphaBetHeaderView.self)
            headerView?.label.text = sectionTitles[section - additionalSectionsCount]
            
            return headerView
        }

        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            guard collectionView.contentSize.height > Constants.collectionCellHeight else { return CGFloat.zero }
     
            return collectionView.contentSize.height
        }
        
        if section >= additionalSectionsCount {
            return 40
        }
        
        return CGFloat.zero
    }
    
    // MARK: - UISearchBarDelegate
    
    func searchBar(_: UISearchBar, textDidChange _: String) {
        makeDataSource()
        scrollToBottom()
    }
    
    private func scrollToBottom()  {
        if sectionTitles.isNotEmpty {
            tableView.scrollToRow(at: IndexPath(row: 0, section: (sectionTitles.count + additionalSectionsCount) - 1), at: .top, animated: false)
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
