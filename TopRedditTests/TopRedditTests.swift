import XCTest
@testable import TopReddit

extension TableViewDataSource {
    func apply(patch: TableViewDataSource.Patch) {
        self.items = patch.result
    }
}

class TopRedditTests: XCTestCase {

    func testDataSource() throws {
        let tableView = UITableView()
        let dataSource = TableViewDataSource<Int>(tableView: tableView, cellProvider: { _,_,_  in return nil })
        
        [
            [1, 2, 3, 4],
            [2, 3, 4],
            [2, 3, 4, 5, 6, 7],
            [3, 4, 6],
            [1, 3, 6, 7],
            [3, 1, 6, 8, 9, 7]
        ]
        .forEach { (items) in
            let patch = dataSource.patch(from: items)
            let prev = dataSource.items
            dataSource.apply(patch: patch)
            XCTAssertEqual(dataSource.items, items)
            XCTAssertNotEqual(dataSource.items, prev)
        }
    }
    
    func testOrderedSet() throws {
        enum HashableEnum: Hashable {
            case one
            case two
            case some(Int)
        }
        
        var set = OrderedSet<HashableEnum>()
        
        XCTAssertEqual(set.count, 0)
        
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
}
