import UIKit

final class MainBuilder {
    
    public static func build() -> MainViewController {
        let view = MainViewController()
        let router = MainRouter(view: view)
        let api = NewsAPI()
        let presenter = MainPresenter(view: view, router: router, api: api)
        
        view.presenter = presenter
        
        return view
    }
    
}
