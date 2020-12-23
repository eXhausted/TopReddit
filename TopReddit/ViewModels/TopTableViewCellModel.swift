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
    private let formatter: RelativeDateTimeFormatter
    
    var title: String = ""
    var author: String = ""
    var when: String { formatter.localizedString(for: Date(timeIntervalSince1970: post.data.created), relativeTo: .init()) }
    var numberOfComments: String = ""
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
    
    init(model: Post, imageService: ImageService, formatter: RelativeDateTimeFormatter) {
        self.post = model
        self.imageService = imageService
        self.formatter = formatter
        
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
        author = post.data.author + " 🕚 " + when
        numberOfComments = String(post.data.num_comments)
        
        imageSubscription = resizedImage
            .map(\.url)
            .map(imageService.loadImage(url:))?
            .receive(on: DispatchQueue.main)
            .assign(to: \.image, on: self)
    }
}
