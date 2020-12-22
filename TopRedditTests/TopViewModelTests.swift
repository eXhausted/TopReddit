import XCTest
import Combine
@testable import TopReddit

let post = Post(kind: "post", data: nil, height: nil)

class RedditServiceMock: RedditServiceProtocol {
    
    func getTop(before: String?, after: String?, limit: Int) -> AnyPublisher<[Post], Never> {
        return Just([post])
            .subscribe(on: DispatchQueue.global())
            .receive(on: DispatchQueue.global())
            .eraseToAnyPublisher()
    }
    
    func loadState() -> StateRestoration? { nil }
    func persist(items: [Post], from post: Post, heights: [String : Double], limit: Int) {}
    
}

class TopViewModelTests: XCTestCase {
    
    var viewModel: TopViewModel = .init(redditService: RedditServiceMock())

    func testGetTop() throws {
        let expectation = XCTestExpectation(description: "Waiting for posts")
        
        _ = viewModel
            .$models
            .sink { (posts) in
                XCTAssertEqual(posts, [post])
                expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 20)
    }
}
