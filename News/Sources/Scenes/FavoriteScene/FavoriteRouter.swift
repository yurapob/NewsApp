import UIKit

protocol FavoriteRouterProtocol {
    
    init(view: FavoriteViewController)
    
    func showWebScene(_ url: URL)
}

final class FavoriteRouter: FavoriteRouterProtocol {
    
    private weak var view: FavoriteViewController?
    
    init(view: FavoriteViewController) {
        self.view = view
    }
    
    func showWebScene(_ url: URL) {
        let webViewController = WebViewController(url: url)
        view?.navigationController?.pushViewController(webViewController, animated: true)
    }
}
