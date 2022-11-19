import UIKit
import SnapKit
import WebKit

protocol MainViewControllerProtocol: AnyObject {
    
    typealias Event = MainScene.Event
    
    func displayUpdateScene(response: Event.UpdateScene.Response)
    func displayLoadMore(response: Event.LoadMore.Response)
    func displayPickerView(response: Event.SetFilter.Response)
}

final class MainViewController: UIViewController {
    
    public var presenter: MainPresenterProtocol!
    
    // MARK: - Private properties
    
    private let pagitationSpinner = UIActivityIndicatorView(style: .large)
    private let loadSpinner = UIActivityIndicatorView(style: .large)
    
    private let searchBar: UISearchBar = .init()
    private let sortButton: ActionButton = .init()
    private let categoryButton: ActionButton = .init()
    private let countryButton: ActionButton = .init()
    private let sourceButton: ActionButton = .init()
    private let pickerContainerView: UIView = .init()
    private let pickerView: UIPickerView = .init()
    private let tableView: UITableView = .init()
    private let emptyLabel: UILabel = .init()
    private let refreshControl: UIRefreshControl = .init()
    
    private var tableViewSection: [MainScene.Model.TableViewSection] = []
    
    private var pickerDataSource: [String] = []
    private var pickerFilters: (String?, String?, String?) = (nil, nil, nil)
    private var pickerDictaonary: [String : String] = [:]
    private var currentPickerType: Filters? = nil
    
    private var pagitation: Int = 10
    
    // MARK: - Overridden
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let request = Event.UpdateScene.Request()
        presenter.onUpdateScene(request: request)
    }
}

private extension MainViewController {
    
    func setup() {
        setupView()
        setupSearchBar()
        setupSortButton()
        setupFilterButtons()
        setupPickerContainerView()
        setupPickerView()
        setupTableView()
        setupEmptyLabel()
        setupRefreshControl()
        setupLayout()
    }
    
    func setupView() {
        self.hideKeyboardWhenTappedAround()
        view.backgroundColor = Theme.Colors.white
    }
    
    func setupSearchBar() {
        searchBar.delegate = self
        searchBar.placeholder = Localized(.main_screen_search_bar_placeholder)
        searchBar.searchBarStyle = .minimal
    }
    
    func setupSortButton() {
        sortButton.title = "⇩"
        sortButton.onTouchUpInside = { [weak self] in
            let request = Event.Sort.Request()
            self?.presenter.onSort(request: request)
        }
    }
    
    func setupFilterButtons() {
        
        categoryButton.title = Filters.category.rawValue
        categoryButton.onTouchUpInside = { [weak self] in
            self?.currentPickerType = .category
            let request = MainScene.Event.SetFilter.Request(pickerType: .category)
            self?.presenter.onPickerView(request: request)
        }
        
        countryButton.title = Filters.country.rawValue
        countryButton.onTouchUpInside = { [weak self] in
            self?.currentPickerType = .country
            let request = MainScene.Event.SetFilter.Request(pickerType: .country)
            self?.presenter.onPickerView(request: request)
        }
        
        sourceButton.title = Filters.sources.rawValue
        sourceButton.onTouchUpInside = { [weak self] in
            self?.currentPickerType = .sources
            let request = MainScene.Event.SetFilter.Request(pickerType: .sources)
            self?.presenter.onPickerView(request: request)
        }
    }
    
    func setupPickerContainerView() {
        pickerContainerView.isHidden = true
        pickerContainerView.backgroundColor = Theme.Colors.black.withAlphaComponent(0.25)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        pickerContainerView.addGestureRecognizer(tap)
    }
    
    @objc func handleTap(_ isRefreshing: Bool = false) {
        searchBar.text = nil
        pickerContainerView.isHidden = true
        pickerContainerView.isUserInteractionEnabled = true
        
        if !isRefreshing && pickerFilters != (nil, nil, nil) {
            emptyLabel.isHidden = true
            loadSpinner.startAnimating()
        }
        
        var request = MainScene.Event.Search.Request(type: .text(""))
        
        if let pickerType = currentPickerType {
            switch pickerType {
            case .category:
                if let category = pickerFilters.0,
                   let country = pickerFilters.1 {
                    request.type = .categoryAndCountry(pickerDictaonary.someKey(forValue: category) ?? .empty,
                                                       pickerDictaonary.someKey(forValue: country) ?? .empty)
                } else if let category = pickerFilters.0 {
                    request.type = .category(pickerDictaonary.someKey(forValue: category) ?? .empty)
                }
            case .country:
                if let category = pickerFilters.0,
                   let country = pickerFilters.1 {
                    request.type = .categoryAndCountry(pickerDictaonary.someKey(forValue: category) ?? .empty,
                                                       pickerDictaonary.someKey(forValue: country) ?? .empty)
                } else if let country = pickerFilters.1 {
                    request.type = .country(pickerDictaonary.someKey(forValue: country) ?? .empty)
                }
            case .sources:
                if let sources = pickerFilters.2 {
                    request.type = .sources(pickerDictaonary.someKey(forValue: sources) ?? .empty)
                }
            }
        }
        
        presenter.onSearch(request: request)
    }
    
    func setupPickerView() {
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.backgroundColor = Theme.Colors.white
        pickerView.layer.cornerRadius = 22.0
        pickerView.layer.masksToBounds = true
    }
    
    func setupTableView() {
        tableView.backgroundColor = .clear
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isUserInteractionEnabled = true
        tableView.estimatedRowHeight = 0
        tableView.estimatedSectionFooterHeight = 0
        tableView.estimatedSectionHeaderHeight = 0
        tableView.separatorStyle = .none
        tableView.tableFooterView = pagitationSpinner
        
        tableView.register(
            classes: [
                MainScene.ArticleCell.ViewModel.self
            ]
        )
    }
    
    func setupEmptyLabel() {
        emptyLabel.text = Localized(.main_screen_empty_label)
        emptyLabel.font = Theme.Fonts.neutonBold.withSize(20.0)
        emptyLabel.numberOfLines = 0
        emptyLabel.textAlignment = .center
        emptyLabel.backgroundColor = .clear
        emptyLabel.lineBreakMode = .byWordWrapping
        emptyLabel.textColor = Theme.Colors.textGray
    }
    
    func setupRefreshControl() {
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
    }
    
    @objc private func refresh() {
        if pickerFilters != (nil, nil, nil) {
            handleTap(true)
        } else if let text = searchBar.text, !text.isEmpty {
            let request = MainScene.Event.Search.Request(type: .text(text))
            presenter.onSearch(request: request)
        } else {
            refreshControl.endRefreshing()
        }
    }
    
    func setupLayout() {
        view.addSubview(searchBar)
        view.addSubview(categoryButton)
        view.addSubview(countryButton)
        view.addSubview(sourceButton)
        view.addSubview(sortButton)
        view.addSubview(tableView)
        tableView.addSubview(refreshControl)
        tableView.addSubview(emptyLabel)
        tableView.addSubview(loadSpinner)
        view.addSubview(pickerContainerView)
        pickerContainerView.addSubview(pickerView)
        
        var navHeight: CGFloat = .zero
        if let navFrame = navigationController?.navigationBar.frame {
            navHeight = navFrame.maxY + navFrame.height
        }
        
        searchBar.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().inset(10.0)
            make.trailing.equalToSuperview().inset(20.0)
            make.top.equalToSuperview().offset(navHeight + 7.0)
        }
        
        categoryButton.snp.makeConstraints { (make) in
            make.width.equalTo((view.frame.width - 126.0) / 3)
            make.leading.equalToSuperview().inset(20.0)
            make.top.equalTo(searchBar.snp.bottom)
        }
        
        countryButton.snp.makeConstraints { (make) in
            make.size.equalTo(categoryButton)
            make.leading.equalTo(categoryButton.snp.trailing).offset(14.0)
            make.centerY.equalTo(categoryButton.snp.centerY)
        }
        
        sourceButton.snp.makeConstraints { (make) in
            make.size.equalTo(categoryButton)
            make.leading.equalTo(countryButton.snp.trailing).offset(14.0)
            make.centerY.equalTo(categoryButton.snp.centerY)
        }
        
        sortButton.snp.makeConstraints { (make) in
            make.size.equalTo(categoryButton.snp.height)
            make.leading.equalTo(sourceButton.snp.trailing).offset(14.0)
            make.centerY.equalTo(categoryButton.snp.centerY)
        }
        
        pickerContainerView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        pickerView.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
        
        tableView.snp.makeConstraints { (make) in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo(categoryButton.snp.bottom).offset(7.0)
        }
        
        emptyLabel.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
        
        loadSpinner.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
    }
    
    func updateButtons() {
        if pickerFilters.0 == nil { categoryButton.title = Filters.category.rawValue }
        if pickerFilters.1 == nil { countryButton.title = Filters.country.rawValue }
        if pickerFilters.2 == nil { sourceButton.title = Filters.sources.rawValue }
    }
    
    func tableViewCell(for indexPath: IndexPath) -> CellViewAnyModel {
        
        tableViewSection[indexPath.section].cells[indexPath.row]
    }
}

// MARK: MainViewControllerProtocol

extension MainViewController: MainViewControllerProtocol {
    
    func displayUpdateScene(response: Event.UpdateScene.Response) {
        
        pagitation = 10
        tableViewSection = response.sceneModel.tableViewSection
        
        DispatchQueue.main.async {
            
            if self.tableViewSection[0].cells.isEmpty {
                self.emptyLabel.isHidden = false
            } else {
                self.emptyLabel.isHidden = true
            }
            
            self.loadSpinner.stopAnimating()
            self.refreshControl.endRefreshing()
            self.tableView.reloadData()
        }
    }
    
    func displayLoadMore(response: Event.LoadMore.Response) {
        
        pagitationSpinner.stopAnimating()
        tableViewSection = response.sceneModel.tableViewSection
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func displayPickerView(response: Event.SetFilter.Response) {
        pickerContainerView.isHidden = false
        pickerDictaonary = response.pickerData
        pickerDataSource = response.pickerData.map { $0.value }
        pickerView.reloadAllComponents()
    }
}

// MARK: UITableViewDataSource

extension MainViewController: UITableViewDataSource {
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        tableViewSection.count
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableViewSection[section].cells.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(with: self.tableViewCell(for: indexPath), for: indexPath)
        
        if indexPath.row == pagitation - 1 {
            pagitationSpinner.startAnimating()
            pagitation += 10
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                
                let request = MainScene.Event.LoadMore.Request(pagitation: self.pagitation)
                self.presenter.onLoadMore(request: request)
            }
        }
        
        if let articleCell = cell as? MainScene.ArticleCell.View {
            articleCell.onButtonTouchUpInside = { [weak self] isFavorite in
                let request = Event.ButtonCellTap.Request(index: indexPath.row, isFavorite: isFavorite)
                self?.presenter.onButtonCellTap(request: request)
            }
        }
        
        return cell
    }
}

// MARK: UITableViewDelegate

extension MainViewController: UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let tableViewWidth = tableView.bounds.width
        
        guard let height = (tableViewCell(for: indexPath) as? UITableViewCellHeightProvider)?.height(with: tableViewWidth) else {
            return UITableView.automaticDimension
        }
        
        return height
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let request = Event.CellTap.Request(index: indexPath.row)
        presenter.onCellTap(request: request)
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let sectionModel = tableViewSection[section]
        guard let headerModel = sectionModel.header else { return nil }
        let header = tableView.dequeueReusableHeaderFooterView(with: headerModel)
        
        return header
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        let tableViewWidth = tableView.bounds.width
        guard let viewModel = tableViewSection[section].header else { return .leastNormalMagnitude }
        let heightProvider = viewModel as? UITableViewHeaderFooterViewHeightProvider
        guard let height = heightProvider?.height(with: tableViewWidth) else { return UITableView.automaticDimension }
        
        return height
    }
}

// MARK: UIPickerViewDelegate

extension MainViewController: UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let row = pickerDataSource[row]
        
        return row
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let row = pickerDataSource[row]
        if let pickerType = currentPickerType {
                        
            switch pickerType {
            case .category:
                pickerFilters.2 = nil
                pickerFilters.0 = row
                categoryButton.title = row
            case .country:
                pickerFilters.2 = nil
                pickerFilters.1 = row
                countryButton.title = row
            case .sources:
                pickerFilters.0 = nil
                pickerFilters.1 = nil
                pickerFilters.2 = row
                sourceButton.title = row
            }
            updateButtons()
        }
    }
}

// MARK: UIPickerViewDataSource

extension MainViewController: UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerDataSource.count
    }
    
}

// MARK: UISearchBarDelegate

extension MainViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        pickerFilters = (nil, nil, nil)
        updateButtons()
        
        emptyLabel.isHidden = true
        loadSpinner.startAnimating()
        
        let request = MainScene.Event.Search.Request(type: .text(searchBar.text ?? .empty))
        presenter.onSearch(request: request)
        
        searchBar.endEditing(true)
    }
}
