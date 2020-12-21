import Foundation
import UIKit
import Combine

class TopTableViewCellModel {
    
    let post: Post
    private let imageService: ImageService
    private(set) var sourceImage: ResizedImage? = nil
    private var resizedImage: ResizedImage? = nil
    private let bounds = UIScreen.main.bounds
    
    private var imageSubscription: AnyCancellable?
    
    @Published var title: String? = ""
    @Published var author: String? = ""
    @Published var numberOfComments: String? = ""
    @Published var image: UIImage?
    var id: String { post.data.name }
    
    var imageSize: CGSize {
        guard let resizedImage = resizedImage else {
            return .zero
        }
        
        var multiplier: CGFloat
        if bounds.height > bounds.width {
            multiplier = bounds.width / CGFloat(resizedImage.width)
        } else {
            multiplier = bounds.height / CGFloat(resizedImage.height)
        }
        
        return CGSize(
            width: (CGFloat(resizedImage.width) * multiplier).rounded(.up),
            height: (CGFloat(resizedImage.height) * multiplier).rounded(.up)
        )
    }
    
    init(model: Post, imageService: ImageService) {
        self.post = model
        self.imageService = imageService
        let image = post
            .data
            .preview?
            .images
            .first
        
        let resolutions = image?
            .resolutions
            .filter{ CGFloat($0.width) < self.bounds.width }
            .sorted(by: { $0.width < $1.width })
        
        self.sourceImage = image?.source
        self.resizedImage = resolutions?.last
        
        title = post.data.title
        author = post.data.author
        numberOfComments = String(post.data.num_comments)
        
        imageSubscription = resizedImage
            .map(\.url)
            .map(imageService.loadImage(url:))?
            .assign(to: \.image, on: self)
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
