import UIKit

protocol FavoriteViewControllerProtocol: AnyObject {
    
    typealias Event = FavoriteScene.Event
    
    func displayViewDidLoad(response: Event.ViewDidLoad.Response)
    func displayLoadMore(response: Event.LoadMore.Response)
}

final class FavoriteViewController: UIViewController {
    
    public var presenter: FavoritePresenterProtocol!
    
    // MARK: - Private properties
    
    private let spinner = UIActivityIndicatorView(style: .large)
    
    private let tableView: UITableView = .init()
    private let emptyLabel: UILabel = .init()
    private var tableViewSection: [FavoriteScene.Model.TableViewSection] = []
    private var pagitation: Int = 10
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let request = Event.ViewDidLoad.Request()
        presenter.onViewDidLoad(request: request)
    }
}

private extension FavoriteViewController {
    
    func setup() {
        setupView()
        setupTableView()
        setupEmptyLabel()
        setupLayout()
    }
    
    func setupView() {
        self.hideKeyboardWhenTappedAround()
        view.backgroundColor = Theme.Colors.white
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
        tableView.tableFooterView = spinner
        
        tableView.register(
            classes: [
                MainScene.ArticleCell.ViewModel.self
            ]
        )
    }
    
    func setupEmptyLabel() {
        emptyLabel.text = Localized(.favorite_screen_empty_label)
        emptyLabel.font = Theme.Fonts.neutonBold.withSize(20.0)
        emptyLabel.numberOfLines = 0
        emptyLabel.textAlignment = .center
        emptyLabel.backgroundColor = .clear
        emptyLabel.lineBreakMode = .byWordWrapping
        emptyLabel.textColor = Theme.Colors.textGray
    }
    
    func setupLayout() {
        view.addSubview(tableView)
        tableView.addSubview(emptyLabel)
        
        var navHeight: CGFloat = .zero
        if let navFrame = navigationController?.navigationBar.frame {
            navHeight = navFrame.maxY + navFrame.height
        }
        
        tableView.snp.makeConstraints { (make) in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalToSuperview().offset(navHeight + 7.0)
        }
        
        emptyLabel.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
    }
    
    func tableViewCell(for indexPath: IndexPath) -> CellViewAnyModel {
        
        tableViewSection[indexPath.section].cells[indexPath.row]
    }
}

// MARK: FavoriteViewControllerProtocol

extension FavoriteViewController: FavoriteViewControllerProtocol {
    
    func displayViewDidLoad(response: Event.ViewDidLoad.Response) {
        
        tableViewSection = response.sceneModel.tableViewSection
        
        DispatchQueue.main.async {
            
            if self.tableViewSection[0].cells.isEmpty {
                self.emptyLabel.isHidden = false
            } else {
                self.emptyLabel.isHidden = true
            }
            
            self.tableView.reloadData()
        }
    }
    
    func displayLoadMore(response: Event.LoadMore.Response) {
        
        spinner.stopAnimating()
        
        tableViewSection = response.sceneModel.tableViewSection
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}

// MARK: UITableViewDataSource

extension FavoriteViewController: UITableViewDataSource {
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        tableViewSection.count
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableViewSection[section].cells.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(with: self.tableViewCell(for: indexPath), for: indexPath)
        
        if indexPath.row == pagitation - 1 {
            spinner.startAnimating()
            pagitation += 10
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                
                let request = FavoriteScene.Event.LoadMore.Request(pagitation: self.pagitation)
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

extension FavoriteViewController: UITableViewDelegate {
    
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
