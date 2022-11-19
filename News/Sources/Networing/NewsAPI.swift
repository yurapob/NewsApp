import UIKit

final class NewsAPI {
    
    static var baseURL = URLComponents(string: "https://newsapi.org")
    static let apiToken = "6f49782947954633a33d7edfcc0e927a "
    
    func search(_ type: RequestType, completion: @escaping (Result<ArticleModel, NetworkError>) -> Void) {
        
        guard let url = createUrl(type: type) else { return completion(.failure(.badURL))}
        
        URLSession.shared.fetchData(for: url) { (result: Result<ArticleModel, Error>) in
            switch result {
            case .success(let success):
                completion(.success(success))
            case .failure(_):
                completion(.failure(.error))
            }
        }
    }
    
    private func createUrl(type: RequestType) -> URL? {
        
        var baseURL = NewsAPI.baseURL
        
        switch type {
            
        case .text(let q):
            baseURL?.path = "/v2/everything"
            baseURL?.queryItems = [URLQueryItem(name: "q", value: q),
                                   URLQueryItem(name: "apiKey", value: NewsAPI.apiToken)]
        case .category(let category):
            baseURL?.path = "/v2/top-headlines"
            baseURL?.queryItems = [URLQueryItem(name: "category", value: category),
                                   URLQueryItem(name: "apiKey", value: NewsAPI.apiToken)]
        case .country(let country):
            baseURL?.path = "/v2/top-headlines"
            baseURL?.queryItems = [URLQueryItem(name: "country", value: country),
                                   URLQueryItem(name: "apiKey", value: NewsAPI.apiToken)]
        case .categoryAndCountry(let category, let country):
            baseURL?.path = "/v2/top-headlines"
            baseURL?.queryItems = [URLQueryItem(name: "country", value: country),
                                   URLQueryItem(name: "category", value: category),
                                   URLQueryItem(name: "apiKey", value: NewsAPI.apiToken)]
        case .sources(let source):
            baseURL?.path = "/v2/top-headlines"
            baseURL?.queryItems = [URLQueryItem(name: "sources", value: source),
                                   URLQueryItem(name: "apiKey", value: NewsAPI.apiToken)]
        }
        
        guard let url = baseURL?.url else { return nil }
        return url
    }
}

enum RequestType {
    
    case text(String)
    case category(String)
    case country(String)
    case categoryAndCountry(String, String)
    case sources(String)
}

enum NetworkError: Error {
    case badURL
    case error
}
