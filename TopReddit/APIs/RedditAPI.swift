import Foundation
import Combine

extension String: Error {}

class RedditAPI {
    let urlSesstion: URLSession = .shared
    
    func getTop(before: String? = nil, after: String? = nil, limit: Int = 10)  -> AnyPublisher<Top, Error> {
        let urlString = [
            "https://www.reddit.com/top.json",
            [
                before.map {"before=" + $0 },
                after.map { "after=" + $0 },
                "limit=\(limit)"
            ]
            .compactMap { $0 }
            .joined(separator: "&")
        ]
        .joined(separator: "?")
        
        return URL(string: urlString)
            .map { URLRequest(url: $0) }
            .map(urlSesstion.dataTaskPublisher(for:))!
            .tryMap { output -> Data in
                guard let response = output.response as? HTTPURLResponse else { throw "Not HTTP response" }
                guard response.statusCode == 200 else { throw "HTTP status code: \(response.statusCode)" }
                return output.data
            }
            .decode(type: Top.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
}
