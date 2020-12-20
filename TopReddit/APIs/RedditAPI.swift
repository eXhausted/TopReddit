import Foundation
import Combine

extension String: Error {}

class RedditAPI {
    let urlSession: URLSession = .shared
    
    func getTop(before: String? = nil, after: String? = nil, limit: Int = 10)  -> AnyPublisher<Top, Error> {
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
            .eraseToAnyPublisher()
    }
}
