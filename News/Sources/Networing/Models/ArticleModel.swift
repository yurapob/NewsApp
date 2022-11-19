import Foundation

struct ArticleModel: Decodable {
    
    let status: String?
    let totalResults: Int?
    var articles: [ArticleInfo]
}

struct ArticleInfo: Decodable {
    let source: Source
    let author: String?
    let title: String?
    let description: String?
    let url: String?
    let urlToImage: String?
    let publishedAt: String?
    let content: String?
}

struct Source: Decodable {
    let id: String?
    let name: String?
}
