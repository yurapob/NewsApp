import UIKit

protocol MainPresenterProtocol: AnyObject {
    
    init(view: MainViewControllerProtocol, router: MainRouterProtocol, api: NewsAPI)
    
    typealias Event = MainScene.Event
    
    func onUpdateScene(request: Event.UpdateScene.Request)
    func onSearch(request: Event.Search.Request)
    func onLoadMore(request: Event.LoadMore.Request)
    func onPickerView(request: Event.SetFilter.Request)
    func onSort(request: Event.Sort.Request)
    func onCellTap(request: Event.CellTap.Request)
    func onButtonCellTap(request: Event.ButtonCellTap.Request)
}

final class MainPresenter: MainPresenterProtocol {
            
    private weak var view: MainViewControllerProtocol?
    private var router: MainRouterProtocol
    private var api: NewsAPI
    
    private var pagitation: Int = 10
    private var data: ArticleModel = .init(status: nil, totalResults: nil, articles: []) {
        didSet {
            updateScene()
        }
    }
    
    init(view: MainViewControllerProtocol, router: MainRouterProtocol, api: NewsAPI) {
        self.view = view
        self.router = router
        self.api = api
    }
    
    func onSearch(request: Event.Search.Request) {
        
        self.pagitation = 10
        
        api.search(request.type) { (result: Result<ArticleModel, NetworkError>) in
            switch result {
                
            case .success(let success):
                self.data = success
            case .failure(let failure):
                print(failure.localizedDescription)
            }
        }
    }
    
    func onLoadMore(request: Event.LoadMore.Request) {
        
        pagitation = request.pagitation
        
        let response = Event.LoadMore.Response(sceneModel:
                .init(
                    tableViewSection: mapToCells()
                )
        )
        view?.displayLoadMore(response: response)
    }
    
    func onPickerView(request: Event.SetFilter.Request) {
        
        var response = Event.SetFilter.Response(pickerData: [:])
        
        switch request.pickerType {
        case .category:
            response.pickerData = ["business" : "Business",
                                   "entertainment" : "Entertainment",
                                   "general" : "General",
                                   "health" : "Health",
                                   "science" : "Science",
                                   "sports" : "Sports",
                                   "technology" : "Technology"]
        case .country:
            response.pickerData = ["ae" : "United Arab Emirates",
                                   "ar" : "Austria",
                                   "be" : "Belgium",
                                   "bg" : "Bulgaria",
                                   "fr" : "France",
                                   "de" : "Germany",
                                   "lv" : "Latvia",
                                   "ua" : "Ukraine"]
        case .sources:
            response.pickerData = ["bbc-news" : "BBC",
                                   "fox-news" : "FOX",
                                   "cnn" : "CNN",
                                   "google-news" : "Google",
                                   "the-washington-post" : "The Washington Post",
                                   "usa-today" : "USA Today",
                                   "buzzfeed" : "Buzzfeed",
                                   "bleacher-report" : "Bleacher Report"]
        }
        
        view?.displayPickerView(response: response)
    }
    
    func onSort(request: Event.Sort.Request) {
        let sortedArticles = data.articles.sorted { $0.publishedAt ?? .empty < $1.publishedAt ?? .empty }
        data.articles = sortedArticles
    }
    
    func onCellTap(request: Event.CellTap.Request) {
        let url = URL(string: data.articles[request.index].url ?? .empty)!
        router.showWebScene(url)
    }
    
    func onButtonCellTap(request: Event.ButtonCellTap.Request) {
        
        let article = data.articles[request.index]
        
        if request.isFavorite {
            CoreDataManager.sharedManager.delete(url: article.url ?? .empty)
        } else {
            CoreDataManager.sharedManager.insert(source: article.source.name ?? .empty,
                                                 author: article.author ?? .empty,
                                                 title: article.title ?? .empty,
                                                 descript: article.description ?? .empty,
                                                 url: article.url ?? .empty,
                                                 urlToImage: article.urlToImage ?? .empty,
                                                 publishedAt: article.publishedAt ?? .empty,
                                                 content: article.content ?? .empty)
        }
        
        updateScene()
    }
    
    func onUpdateScene(request: Event.UpdateScene.Request) {
        updateScene()
    }
}

private extension MainPresenter {
    
    func mapToCells() -> [MainScene.Model.TableViewSection] {
        
        var tableViewSections: [MainScene.Model.TableViewSection] = []
        var cells: [CellViewAnyModel] = []
        
        var i: Int = .zero
        for item in data.articles {
            if i >= pagitation { break }
            
            cells.append(
                MainScene.ArticleCell.ViewModel(
                    id: "\(i)",
                    source: item.source.name ?? .empty,
                    author: item.author ?? .empty,
                    title: item.title ?? .empty,
                    descript: item.description ?? .empty,
                    image: item.urlToImage ?? .empty,
                    isFavorite: CoreDataManager.sharedManager.checkIfExists(url: item.url ?? .empty)
                )
            )
            i += 1
        }
        
        tableViewSections.append(
            .init(
                id: "0",
                header: nil,
                cells: cells
            )
        )
        
        return tableViewSections
    }
    
    func updateScene() {
        
        let response = Event.UpdateScene.Response(sceneModel:
                .init(
                    tableViewSection: mapToCells()
                )
        )
        view?.displayUpdateScene(response: response)
    }
}
