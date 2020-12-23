import UIKit
import Combine

class ImageViewModel {
    
    private var subscriptions: Set<AnyCancellable> = .init()
    
    let imageData: ResizedImage
    let imageSerivce: ImageService
    
    @Published var image: UIImage?
    
    init(imageData: ResizedImage, imageService: ImageService) {
        self.imageData = imageData
        self.imageSerivce = imageService
        
        imageSerivce
            .loadImage(url: imageData.url)
            .assign(to: \.image, on: self)
            .store(in: &subscriptions)
    }
}

