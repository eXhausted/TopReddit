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
}
