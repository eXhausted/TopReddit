import Foundation

class DependencyContainer {
    private let formatter = RelativeDateTimeFormatter()
    
    private let imageService = ImageService()
    private let redditService = RedditService()
    
    static let container: DependencyContainer = .init()
    
    private init() {}
    
    func resolve() -> TopViewModel {
        return .init(redditService: redditService)
    }

    func resolve(with model: Post) -> TopTableViewCellModel {
        return .init(model: model, imageService: imageService, formatter: formatter)
    }
    
    func resolve(with model: ResizedImage) -> ImageViewModel {
        return .init(imageData: model, imageService: imageService)
    }
}
