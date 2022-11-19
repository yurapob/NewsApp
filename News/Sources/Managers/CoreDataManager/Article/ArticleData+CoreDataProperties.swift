import Foundation
import CoreData


extension ArticleData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ArticleData> {
        return NSFetchRequest<ArticleData>(entityName: "ArticleData")
    }

    @NSManaged public var source: String?
    @NSManaged public var author: String?
    @NSManaged public var title: String?
    @NSManaged public var descript: String?
    @NSManaged public var url: String?
    @NSManaged public var urlToImage: String?
    @NSManaged public var publishedAt: String?
    @NSManaged public var content: String?

}
