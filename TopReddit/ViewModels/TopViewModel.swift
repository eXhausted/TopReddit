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
    
    let redditService: RedditServiceProtocol
    
    @Published private var state: State
    @Published private var actions: OrderedSet<Action>
    @Published var models: [Post] = .init()
    @Published var scrollTo: Int = NSNotFound
    
    private var subscriptions: Set<AnyCancellable> = .init()
    private var heights: [String: Double] = .init()
    
    let limit = 10
    private let queue = DispatchQueue(label: "TopViewModel")
    
    init(redditService: RedditServiceProtocol) {
        self.state = .idle
        self.actions = .init()
        self.redditService = redditService
        
        $state
            .combineLatest($actions)
            .receive(on: queue)
            .filter{ $0.0 == .idle && $0.1.count > 0 }
            .sink { [weak self] (s) in
                self?.handleNextAction()
            }
            .store(in: &subscriptions)

        actions.append(.initialize)
    }
    
    func handleNextAction() {
        guard let action = actions.first else { return }
        
        state = .busy
        print(action)
        
        var publisher: AnyPublisher<[Post], Never>
        
        switch action {
        case .initialize:
            if let restore = redditService.loadState() {
                heights = restore.heights
                scrollTo = restore.index
                publisher = Just(restore.posts)
                    .eraseToAnyPublisher()
            } else {
                publisher = next(limit: limit * 2)
            }
            
            
        case .loadPage(let before, let after, let limit):
            publisher = next(before: before, after: after, limit: limit)
        }
        
        publisher
            .receive(on: queue)
            .sink { [weak self] (posts) in
                self?.models.append(contentsOf: posts)
                self?.actions.dropFirst()
                self?.state = .idle
            }
            .store(in: &subscriptions)
    }
    
    func prevPage() {
        actions.append(.loadPage(before: models.first?.data.name, limit: limit))
    }
    
    func nextPage() {
        actions.append(.loadPage(after: models.last?.data.name, limit: limit))
    }
    
    private func next(before: String? = nil, after: String? = nil, limit: Int) -> AnyPublisher<[Post], Never> {
        redditService.getTop(before: before, after: after, limit: limit)
    }
    
    func chaos() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            self.models.shuffle()
            self.chaos()
        }
    }
}

extension TopViewModel {
    
    func height(at index: Int) -> Double? {
        guard models.indices.contains(index) else { return nil }
        let model = models[index]
        return heights[model.data.name]
    }
    
    func handle(height: Double, index: Int) {
        guard models.indices.contains(index) else { return }
        let model = models[index]
        heights[model.data.name] = height
    }
}

extension TopViewModel {
    
    func persist(from post: Post) {
        redditService.persist(
            items: models,
            from: post,
            heights: heights,
            limit: limit
        )
    }
}
