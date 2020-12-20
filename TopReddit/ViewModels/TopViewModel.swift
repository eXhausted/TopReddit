import Foundation
import Combine

class TopViewModel {
    private var subscriptions: Set<AnyCancellable> = .init()
    private let imageService = ImageService()
    
    @Published var viewModels: [TopTableViewCellModel] = .init()
    
    init() {
        prepare()
    }
    
    private func prepare() {
        RedditAPI()
            .getTop(limit: 50)
            .receive(on: DispatchQueue.main)
            .sink { (completion) in
                if case .failure(let err) = completion {
                    print(err)
                }
            } receiveValue: { (top) in
                self.viewModels.append(contentsOf: top.data.children.map { .init(model: $0, imageService: self.imageService) })
            }
            .store(in: &subscriptions)
    }
}
