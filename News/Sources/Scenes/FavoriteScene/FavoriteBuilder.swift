import UIKit

final class FavoriteBuilder {
    
    public static func build() -> FavoriteViewController {
        let view = FavoriteViewController()
        let router = FavoriteRouter(view: view)
        let presenter = FavoritePresenter(view: view, router: router)
        
        view.presenter = presenter
        
        return view
    }
    
}
