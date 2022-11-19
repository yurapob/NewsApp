import Foundation
import CoreData
import UIKit

class CoreDataManager {
    
    static let sharedManager = CoreDataManager()
    private init() {}
    
    lazy var persistentContainer: NSPersistentContainer = {
        
        let container = NSPersistentContainer(name: "News")
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    func saveContext () {
        
        let context = CoreDataManager.sharedManager.persistentContainer.viewContext
        
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func insert(source: String,
                author: String,
                title: String,
                descript: String,
                url: String,
                urlToImage: String,
                publishedAt : String,
                content: String) {
        
        let managedContext = CoreDataManager.sharedManager.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "ArticleData", in: managedContext)!
        let article = NSManagedObject(entity: entity, insertInto: managedContext)
        
        article.setValue(source, forKeyPath: "source")
        article.setValue(author, forKeyPath: "author")
        article.setValue(title, forKeyPath: "title")
        article.setValue(descript, forKeyPath: "descript")
        article.setValue(url, forKeyPath: "url")
        article.setValue(urlToImage, forKeyPath: "urlToImage")
        article.setValue(publishedAt, forKeyPath: "publishedAt")
        article.setValue(content, forKeyPath: "content")
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func update(source: String,
                author: String,
                title: String,
                descript: String,
                url: String,
                urlToImage: String,
                publishedAt : String,
                content: String,
                article: ArticleData) {
        
        let context = CoreDataManager.sharedManager.persistentContainer.viewContext
        
        article.setValue(source, forKeyPath: "source")
        article.setValue(author, forKeyPath: "author")
        article.setValue(title, forKeyPath: "title")
        article.setValue(descript, forKeyPath: "descript")
        article.setValue(url, forKeyPath: "url")
        article.setValue(urlToImage, forKeyPath: "urlToImage")
        article.setValue(publishedAt, forKeyPath: "publishedAt")
        article.setValue(content, forKeyPath: "content")
        
        do {
            try context.save()
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
        
    }
    
    func deleteAll() {
        let managedContext = CoreDataManager.sharedManager.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "ArticleData")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try managedContext.execute(deleteRequest)
        } catch _ as NSError { }
    }
    
    func fetchAllArticles() -> [ArticleData]? {
        
        let managedContext = CoreDataManager.sharedManager.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "ArticleData")
        
        do {
            let articles = try managedContext.fetch(fetchRequest)
            return articles as? [ArticleData]
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            return nil
        }
    }
    
    func delete(url: String) {
        
        let managedContext = CoreDataManager.sharedManager.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "ArticleData")
        
        fetchRequest.predicate = NSPredicate(format: "url == %@" , url)
        do {
            let item = try managedContext.fetch(fetchRequest)
            var arrRemovedArticles = [ArticleData]()
            
            for i in item {
                managedContext.delete(i)
                try managedContext.save()
                arrRemovedArticles.append(i as! ArticleData)
            }
            
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
    }
    
    func checkIfExists(url: String) -> Bool {
        
        let managedContext = CoreDataManager.sharedManager.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "ArticleData")
        
        fetchRequest.predicate = NSPredicate(format: "url == %@" , url)
        
        var results: [NSManagedObject] = []
        
        do {
            results = try managedContext.fetch(fetchRequest)
            
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        return results.count > 0
    }
}
