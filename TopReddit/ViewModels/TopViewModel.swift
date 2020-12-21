import Foundation
import Combine

class TopViewModel {
    enum State: Hashable {
        case busy
        case idle
    }
    
    enum Action: Hashable {
        case initialize
        case loadPage(before: String? = nil, after: String? = nil, limit: Int)
    }
    
    private var subscriptions: Set<AnyCancellable> = .init()
    
    @Published private var state: State
    @Published private var actions: OrderedSet<Action>
    
    let imageService = ImageService()
    
    @Published var models: [Post] = .init()
    
    let limit = 10
    
    init() {
        state = .idle
        actions = .init()
        
        $state
            .combineLatest($actions)
            .receive(on: DispatchQueue.global())
            .filter{ $0.0 == .idle && $0.1.count > 0 }
            .sink { [weak self] (s) in
                self?.handleNextAction()
            }
            .store(in: &subscriptions)

        actions.append(.initialize)
    }
    
    func handleNextAction() {
        guard let action = actions.dropFirst() else { return }
        
        state = .busy
        print(action)
        
        switch action {
        case .initialize:
            next(limit: limit * 2)
        case .loadPage(let before, let after, let limit):
            next(before: before, after: after, limit: limit)
        }
    }
    
    func nextPage() {
        actions.append(.loadPage(after: models.last?.data.name, limit: limit))
    }
    
    private func next(before: String? = nil, after: String? = nil, limit: Int) {
        RedditAPI()
            .getTop(after: after, limit: limit)
            .receive(on: DispatchQueue.main)
            .sink { (completion) in
                if case .failure(let err) = completion {
                    print(err)
                }
            } receiveValue: { [unowned self] (top) in
                self.models.append(contentsOf: top.data.children)
                self.state = .idle
            }
            .store(in: &subscriptions)
    }
}
