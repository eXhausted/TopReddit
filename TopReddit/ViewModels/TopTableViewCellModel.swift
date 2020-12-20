import Foundation
import UIKit
import Combine

class TopTableViewCellModel {
    
    private let post: Post
    private let imageService: ImageService
    private let resizedImage: ResizedImage?
    private let scale: CGFloat
    
    private var subscriptions: Set<AnyCancellable> = .init()
    
    @Published var title: String? = ""
    @Published var author: String? = ""
    @Published var numberOfComments: String? = ""
    @Published var image: UIImage?
    
    var imageSize: CGSize {
        guard let resizedImage = resizedImage else {
            return .zero
        }
        
        return CGSize(
            width: (CGFloat(resizedImage.width) / scale).rounded(),
            height: (CGFloat(resizedImage.height) / scale).rounded()
        )
    }
    
    init(model: Post, imageService: ImageService) {
        self.post = model
        self.imageService = imageService
        let scale = CGFloat(1/*UIScreen.main.scale*/)
        let resolutions = post
            .data
            .preview?
            .images
            .first?
            .resolutions
            .filter{ CGFloat($0.width) < (UIScreen.main.bounds.width - 16) / scale }
            .sorted(by: { $0.size < $1.size })
        
        self.scale = scale
        self.resizedImage = resolutions?.last
        
        title = post.data.title
        author = post.data.subreddit_name_prefixed
        numberOfComments = String(post.data.num_comments)
        
        resizedImage
            .map(\.url)
            .map(imageService.loadImage(url:))?
            .sink(receiveValue: { [weak self] (image) in
                self?.image = image
            })
            .store(in: &subscriptions)
    }
    
    
}

extension TopTableViewCellModel: Hashable {
    static func == (lhs: TopTableViewCellModel, rhs: TopTableViewCellModel) -> Bool {
        lhs.post == rhs.post
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(post)
    }
}
