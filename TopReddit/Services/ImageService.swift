import Foundation
import UIKit
import Combine

class ImageService {
    let urlSession: URLSession = .shared
    private var cache: NSCache<NSURL, UIImage> = .init()
    private var publishers: [URL: AnyPublisher<UIImage?, Never>] = .init()
    
    init() {
        prepare()
    }
    
    func loadImage(url: URL) -> AnyPublisher<UIImage?, Never> {
        let fileURL = self.fileURL(from: url)
        
        if let image = cache.object(forKey: fileURL as NSURL) {
            return Just(image)
                .eraseToAnyPublisher()
        }
        
        if publishers[fileURL] == nil {
            publishers[fileURL] = urlSession
                .dataTaskPublisher(for: fileURL)
                .tryCatch { (error: URLError) -> URLSession.DataTaskPublisher in
                    guard error.code.rawValue == -1100 else { throw "Unexpected" }
                    return URLSession.shared.dataTaskPublisher(for: url)
                }
                .tryMap { (data, response) -> UIImage in
                    guard let image = UIImage(data: data) else { throw "Cant parse data into image" }
                    try self.persist(data: data, url: fileURL)
                    self.cache.setObject(image, forKey: fileURL as NSURL)
                    return image
                }
                .replaceError(with: nil)
                .eraseToAnyPublisher()
        }
        
        return publishers[fileURL]!
    }
    
    private func prepare() {
        var isDirectory = ObjCBool(true)
        let exists = FileManager.default.fileExists(atPath: folderPath, isDirectory: &isDirectory)
        if !exists {
            try! FileManager.default.createDirectory(atPath: folderPath, withIntermediateDirectories: true, attributes: nil)
        }
    }
    
    private func persist(data: Data, url: URL) throws {
        try data.write(to: url)
    }
    
    private lazy var folderURL: URL = {
        FileManager
            .default
            .urls(for: .libraryDirectory, in: .userDomainMask)
            .first!
            .appendingPathComponent("Images")
    }()
    
    private lazy var folderPath: String = {
        folderURL.path
    }()
    
    private func fileURL(from url: URL) -> URL {
        folderURL.appendingPathComponent(url.lastPathComponent)
    }
}
