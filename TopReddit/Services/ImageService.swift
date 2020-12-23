import Foundation
import UIKit
import Combine

class ImageService {
    let urlSession: URLSession = .shared
    private var cache: NSCache<NSURL, UIImage> = .init()
    private var publishers: [URL: AnyPublisher<UIImage?, Never>] = .init()
    
    func loadImage(url: URL) -> AnyPublisher<UIImage?, Never> {
        let fileURL = self.fileURL(from: url)
        
        if let image = cache.object(forKey: fileURL as NSURL) {
            return Just(image)
                .eraseToAnyPublisher()
        }
        
        if FileManager.default.fileExists(atPath: fileURL.path) {
            return Just(fileURL.path)
                .subscribe(on: DispatchQueue.global())
                .compactMap { UIImage(contentsOfFile: $0) }
                .map { [weak self] image -> UIImage in
                    self?.cache.setObject(image, forKey: fileURL as NSURL)
                    return image
                }
                .eraseToAnyPublisher()
        }
        
        if publishers[fileURL] == nil {
            let publisher = urlSession
                .dataTaskPublisher(for: url)
                .map(\.data)
                .map { [weak self] in
                    try? self?.persist(data: $0, url: fileURL)
                    return $0
                }
                .compactMap { UIImage(data: $0) }
                .map { [weak self] image -> UIImage in
                    self?.cache.setObject(image, forKey: fileURL as NSURL)
                    return image
                }
                .replaceError(with: nil)
                .share()
                
            publishers[fileURL] = publisher.eraseToAnyPublisher()
        }
        
        return publishers[fileURL]!
    }
    
    private func persist(data: Data, url: URL) throws {
        try data.write(to: url)
    }
    
    private func fileURL(from url: URL) -> URL {
        FileManager
            .default
            .imagesFolderURL
            .appendingPathComponent(url.lastPathComponent)
    }
}
