import XCTest
@testable import TopReddit

enum HashableEnum: Hashable {
    case one
    case two
    case some(Int)
}

class OrderedSetTests: XCTestCase {
    
    var set = OrderedSet<HashableEnum>()

    func testInitCount() {
        XCTAssertEqual(set.count, 0)
    }
    
    func testAppend() throws {
        set.append(.one)
        XCTAssertEqual(set.count, 1)
        
        set.append(.one)
        XCTAssertEqual(set.count, 1)
        
        set.append(.two)
        XCTAssertEqual(set.count, 2)
        
        set.append(.some(1))
        XCTAssertEqual(set.count, 3)

        set.append(.some(1))
        XCTAssertEqual(set.count, 3)
        
        set.append(.some(2))
        XCTAssertEqual(set.count, 4)
    }
    
    func testDropFirst() throws {
        let first = set.first
        let count = set.count
        
        let dropFirst = set.dropFirst()
        XCTAssertEqual(first, dropFirst)
        XCTAssertEqual(count, max(set.count - 1, 0))
    }
}
