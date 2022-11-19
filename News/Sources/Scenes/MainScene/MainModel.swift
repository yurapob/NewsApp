import UIKit
import DifferenceKit

public enum MainScene {
    
    public enum Model {}
    public enum Event {}
}

// MARK: - Models

extension MainScene.Model {
    
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

extension MainScene.Event {
    
    public typealias Model = MainScene.Model
    
    // MARK: -
    
    public enum UpdateScene {
        public struct Request { }
        public struct Response {
            let sceneModel: Model.SceneViewModel
        }
    }
    
    public enum Search {
        public struct Request {
            var type: RequestType
        }
        public struct Response { }
    }
    
    public enum LoadMore {
        public struct Request {
            let pagitation: Int
        }
        public struct Response {
            let sceneModel: Model.SceneViewModel
        }
    }
    
    public enum SetFilter {
        public struct Request {
            let pickerType: Filters
        }
        public struct Response {
            var pickerData: [String : String]
        }
    }
    
    public enum Sort {
        public struct Request { }
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

extension MainScene.Model.TableViewSection: DifferentiableSection {
    
    var differenceIdentifier: String {
        id
    }
    
    func isContentEqual(to source: MainScene.Model.TableViewSection) -> Bool {
        header.equalsTo(another: source.header)
    }
    
    init(source: MainScene.Model.TableViewSection,
         elements: [CellViewAnyModel]) {
        
        self.id = source.id
        self.header = source.header
        self.cells = elements
    }
}

enum Filters: String {
    
    case category = "category"
    case country = "country"
    case sources = "sources"
}
