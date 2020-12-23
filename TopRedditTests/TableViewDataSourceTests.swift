import XCTest
@testable import TopReddit

class TableViewDataSourceTests: XCTestCase {
    var dataSource: TableViewDataSource<Int>!

    override func setUpWithError() throws {
        if dataSource == nil {
            let tableView = UITableView()
            dataSource = TableViewDataSource<Int>(tableView: tableView, cellProvider: { _,_,_  in return nil })
        }
    }

    func testAddElements() throws {
        let items = [1, 2, 3, 4, 5]
        let patch = dataSource.patch(from: items)
        let prev = dataSource.items
        dataSource.apply(patch: patch)
        XCTAssertEqual(dataSource.items, items)
        XCTAssertNotEqual(dataSource.items, prev)
    }
    
    func testDeleteElements() throws {
        let items = [1, 2, 3]
        let patch = dataSource.patch(from: items)
        let prev = dataSource.items
        dataSource.apply(patch: patch)
        XCTAssertEqual(dataSource.items, items)
        XCTAssertNotEqual(dataSource.items, prev)
    }
    
    func testMoveElements() throws {
        let items = [2, 3, 1]
        let patch = dataSource.patch(from: items)
        let prev = dataSource.items
        dataSource.apply(patch: patch)
        XCTAssertEqual(dataSource.items, items)
        XCTAssertNotEqual(dataSource.items, prev)
    }
    
    func testAddDeleteMoveElements() throws {
        let items = [1, 5, 2, 7]
        let patch = dataSource.patch(from: items)
        let prev = dataSource.items
        dataSource.apply(patch: patch)
        XCTAssertEqual(dataSource.items, items)
        XCTAssertNotEqual(dataSource.items, prev)
    }
}
