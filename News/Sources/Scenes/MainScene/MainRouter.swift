import UIKit

protocol MainRouterProtocol {
    init(view: MainViewController)
    
    func showWebScene(_ url: URL)
}

final class MainRouter: MainRouterProtocol {
    
    private weak var view: MainViewController?
    
    init(view: MainViewController) {
        self.view = view
    }
    
    func showWebScene(_ url: URL) {
        let webViewController = WebViewController(url: url)
        view?.navigationController?.pushViewController(webViewController, animated: true)
    }
}
