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
    
    struct StateRestoration: Codable {
        let posts: [Post]
        let heights: [String: Double]
        let index: Int
    }
    
    private var subscriptions: Set<AnyCancellable> = .init()
    
    @Published private var state: State
    @Published private var actions: OrderedSet<Action>
    
    let imageService = ImageService()
    
    @Published var models: [Post] = .init()
    @Published var scrollTo: Int = NSNotFound
    
    private var heights: [String: Double] = .init()
    
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
            guard let restore = loadState() else {
                next(limit: limit * 2)
                return
            }
            heights = restore.heights
            models = restore.posts
            scrollTo = restore.index
            state = .idle
            
            
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
    
    func loadState() -> StateRestoration? {
        let jsonDecoder = JSONDecoder()
        guard let data = try? Data(contentsOf: FileManager.default.stateFileURL) else { return nil }
        return try? jsonDecoder.decode(StateRestoration.self, from: data)
    }
    
    func persist(from post: Post) {
        guard var index = models.firstIndex(of: post) else { return }
        let start = max(0, index - limit / 2)
        let end = min(models.count, start + limit * 2)
        let posts = models[start..<end]
        index = posts.firstIndex(of: post)! - posts.startIndex
        
        let heights = zip(posts, posts.compactMap { self.heights[$0.data.name] })
            .reduce(into: [String: Double]()) { (result, element) in
                result[element.0.data.name] = element.1
        }
        
        let json = JSONEncoder()
        guard let data = try? json.encode(StateRestoration(posts: .init(posts), heights: heights, index: index)) else { return }
        try! data.write(to: FileManager.default.stateFileURL)
    }
}
