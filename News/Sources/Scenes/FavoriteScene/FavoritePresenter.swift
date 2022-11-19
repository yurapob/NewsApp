import UIKit

protocol FavoritePresenterProtocol: AnyObject {
    
    init(view: FavoriteViewControllerProtocol, router: FavoriteRouterProtocol)
    
    typealias Event = FavoriteScene.Event
    
    func onViewDidLoad(request: Event.ViewDidLoad.Request)
    func onLoadMore(request: Event.LoadMore.Request)
    func onCellTap(request: Event.CellTap.Request)
    func onButtonCellTap(request: Event.ButtonCellTap.Request)
}

final class FavoritePresenter: FavoritePresenterProtocol {
    
    private weak var view: FavoriteViewControllerProtocol?
    private var router: FavoriteRouterProtocol
    
    private var pagitation: Int = 10
    private var data: [ArticleData] = [] {
        didSet {
            updateScene()
        }
    }
    
    init(view: FavoriteViewControllerProtocol, router: FavoriteRouterProtocol) {
        self.view = view
        self.router = router
    }
    
    func onViewDidLoad(request: Event.ViewDidLoad.Request) {
        data = CoreDataManager.sharedManager.fetchAllArticles() ?? []
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
    
    func onCellTap(request: Event.CellTap.Request) {
        let url = URL(string: data[request.index].url ?? .empty)!
        router.showWebScene(url)
    }
    
    func onButtonCellTap(request: Event.ButtonCellTap.Request) {
        let article = data[request.index]
        
        if request.isFavorite {
            CoreDataManager.sharedManager.delete(url: article.url ?? .empty)
            data = data.filter() { $0 != article }
        } else {
            CoreDataManager.sharedManager.insert(source: article.source ?? .empty,
                                                 author: article.author ?? .empty,
                                                 title: article.title ?? .empty,
                                                 descript: article.descript ?? .empty,
                                                 url: article.url ?? .empty,
                                                 urlToImage: article.urlToImage ?? .empty,
                                                 publishedAt: article.publishedAt ?? .empty,
                                                 content: article.content ?? .empty)
        }
        
        updateScene()
    }
}

private extension FavoritePresenter {
    
    func mapToCells() -> [FavoriteScene.Model.TableViewSection] {
        
        var tableViewSections: [FavoriteScene.Model.TableViewSection] = []
        var cells: [CellViewAnyModel] = []
        
        var i: Int = .zero
        for item in data {
            if i >= pagitation { break }
            
            cells.append(
                MainScene.ArticleCell.ViewModel(
                    id: "\(i)",
                    source: item.source ?? .empty,
                    author: item.author ?? .empty,
                    title: item.title ?? .empty,
                    descript: item.descript ?? .empty,
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
        
        let response = Event.ViewDidLoad.Response(sceneModel:
                .init(
                    tableViewSection: mapToCells()
                )
        )
        view?.displayViewDidLoad(response: response)
    }
}
