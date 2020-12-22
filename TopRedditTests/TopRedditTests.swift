import XCTest
@testable import TopReddit

extension TableViewDataSource {
    func apply(patch: TableViewDataSource.Patch) {
        self.items = patch.result
    }
}
