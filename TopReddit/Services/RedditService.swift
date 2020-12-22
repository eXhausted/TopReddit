import Foundation
import Combine

extension String: Error {}

struct StateRestoration: Codable {
    let posts: [Post]
    let heights: [String: Double]
    let index: Int
}

protocol RedditServiceProtocol {
    func getTop(before: String?, after: String?, limit: Int)  -> AnyPublisher<[Post], Never>
    func loadState() -> StateRestoration?
    func persist(items: [Post], from post: Post, heights: [String: Double], limit: Int)
}

class RedditService: RedditServiceProtocol {
    
    let urlSession: URLSession = .shared
    
    func getTop(before: String? = nil, after: String? = nil, limit: Int = 10)  -> AnyPublisher<[Post], Never> {
        let urlString = [
            "https://www.reddit.com/top.json",
            [
                before.map {"before=" + $0 },
                after.map { "after=" + $0 },
                "limit=\(limit)",
                "raw_json=1"
            ]
            .compactMap { $0 }
            .joined(separator: "&")
        ]
        .joined(separator: "?")
        
        return URL(string: urlString)
            .map { URLRequest(url: $0) }
            .map(urlSession.dataTaskPublisher(for:))!
            .map(\.data)
            .decode(type: Top.self, decoder: JSONDecoder())
            .map { $0.data.children }
            .replaceError(with: .init())
            .eraseToAnyPublisher()
    }
}

extension RedditService {
    
    func loadState() -> StateRestoration? {
        let jsonDecoder = JSONDecoder()
        guard let data = try? Data(contentsOf: FileManager.default.stateFileURL) else { return nil }
        return try? jsonDecoder.decode(StateRestoration.self, from: data)
    }
    
    func persist(items: [Post], from post: Post, heights: [String: Double], limit: Int) {
        guard var index = items.firstIndex(of: post) else { return }
        let start = max(0, index - limit / 2)
        let end = min(items.count, start + limit * 2)
        let posts = items[start..<end]
        index = posts.firstIndex(of: post)! - posts.startIndex
        
        let heights = zip(posts, posts.compactMap { heights[$0.data.name] })
            .reduce(into: [String: Double]()) { (result, element) in
                result[element.0.data.name] = element.1
        }
        
        let json = JSONEncoder()
        guard let data = try? json.encode(StateRestoration(posts: .init(posts), heights: heights, index: index)) else { return }
        try! data.write(to: FileManager.default.stateFileURL)
    }
}
