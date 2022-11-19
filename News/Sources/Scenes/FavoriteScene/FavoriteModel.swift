import UIKit
import DifferenceKit

public enum FavoriteScene {
    
    public enum Model {}
    public enum Event {}
}

// MARK: - Models

extension FavoriteScene.Model {
    
    struct TableViewSection: SectionViewModel {
        let id: String
        let header: HeaderFooterViewAnyModel?
        let cells: [CellViewAnyModel]
    }
    
    struct SceneViewModel {
        let tableViewSection: [TableViewSection]
    }
}

// MARK: - Events

extension FavoriteScene.Event {
    
    public typealias Model = FavoriteScene.Model
    
    // MARK: -
    
    public enum ViewDidLoad {
        public struct Request { }
        public struct Response {
            let sceneModel: Model.SceneViewModel
        }
    }
    
    public enum LoadMore {
        public struct Request {
            let pagitation: Int
        }
        public struct Response {
            let sceneModel: Model.SceneViewModel
        }
    }
    
    public enum CellTap {
        public struct Request {
            let index: Int
        }
    }
    
    public enum ButtonCellTap {
        public struct Request {
            let index: Int
            let isFavorite: Bool
        }
    }
}

extension FavoriteScene.Model.TableViewSection: DifferentiableSection {
    
    var differenceIdentifier: String {
        id
    }
    
    func isContentEqual(to source: FavoriteScene.Model.TableViewSection) -> Bool {
        header.equalsTo(another: source.header)
    }
    
    init(source: FavoriteScene.Model.TableViewSection,
         elements: [CellViewAnyModel]) {
        
        self.id = source.id
        self.header = source.header
        self.cells = elements
    }
}
