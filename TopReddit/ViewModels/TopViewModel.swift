import Foundation
import Combine

class TopViewModel {
    private var subscriptions: Set<AnyCancellable> = .init()
    let imageService = ImageService()
    
    @Published var models: [Post] = .init()
    
    let limit = 10
    
    init() {
        prepare()
    }
    
    private func prepare() {
        next(limit: limit * 2)
    }
    
    func nextPage() {
        next(limit: limit, after: models.last?.data.name)
    }
    
    private func next(limit: Int, after: String? = nil) {
        RedditAPI()
            .getTop(after: after, limit: limit)
            .receive(on: DispatchQueue.main)
            .sink { (completion) in
                if case .failure(let err) = completion {
                    print(err)
                }
            } receiveValue: { [unowned self] (top) in
                self.models
                    .append(contentsOf: top.data.children)
            }
            .store(in: &subscriptions)
    }
}
