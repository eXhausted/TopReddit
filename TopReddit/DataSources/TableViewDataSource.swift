import Foundation
import UIKit
import Combine

public class TableViewDataSource<T: Hashable>: NSObject, UITableViewDataSource {
    
    public typealias CellProvider = (UITableView, IndexPath, T) -> UITableViewCell?
    
    public struct Changes {
        let insert: [Int]
        let delete: [Int]
        let move: [(from: Int, to: Int)]
    }
    
    public struct Patch {
        public let changes: TableViewDataSource.Changes
        public let result: [T]
    }
    
    private let queue = DispatchQueue(label: "TableViewDataSource")
    let tableView: UITableView
    let cellProvider: CellProvider
    
    public var items: [T]
    
    public init(tableView: UITableView, cellProvider: @escaping CellProvider) {
        self.tableView = tableView
        self.cellProvider = cellProvider
        self.items = .init()
        super.init()
        tableView.dataSource = self
    }
    
    func item(at indexPath: IndexPath) -> T { items[indexPath.row] }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = cellProvider(tableView, indexPath, items[indexPath.row])
        return cell!
    }
}

extension TableViewDataSource {
    public func patch(from input: [T]) -> TableViewDataSource.Patch {
        var items = self.items
        
        // Delete
        var delete = items
            .enumerated()
            .reduce(into: [T: Int]()) { (result, item) in result[item.element] = item.offset }
        delete = input.reduce(into: delete) { (result, item) in result[item] = nil }
        
        let deleteMap = delete.sorted(by: { $0.value > $1.value })
        for (_, index) in deleteMap {
            items.remove(at: index)
        }
        
        // Insert
        var insert = input
            .enumerated()
            .reduce(into: [T: Int]()) { (result, item) in result[item.element] = item.offset }
        insert = items.reduce(into: insert) { (result, item) in result[item] = nil }
        
        let insertMap = insert.sorted(by: { $0.value < $1.value })
        for (item, index) in insertMap {
            items.insert(item, at: index)
        }
        
        print(input.count, "==", items.count)
        assert(input.count == items.count)
        
        // Move
        let before = items
            .enumerated()
            .reduce(into: [T: Int]()) { (result, item) in result[item.element] = item.offset }
        let after = input
            .enumerated()
            .reduce(into: [T: Int]()) { (result, item) in result[item.element] = item.offset }
        
        var moveMap = [T: (from: Int, to: Int)]()
        for (key, oldValue) in before {
            if let newValue = after[key], newValue != oldValue {
                moveMap[key] = (from: oldValue, to: newValue)
            }
        }
        items.sort(by: { after[$0]! < after[$1]! })
        
        return .init(
            changes: .init(insert: insertMap.map{ $0.value }, delete: deleteMap.map { $0.value }, move: moveMap.map { $1 }),
            result: items
        )
    }
}

extension TableViewDataSource: Subscriber {
    
    public typealias Input = [T]
    public typealias Failure = Never
    
    public func receive(subscription: Subscription) {
        subscription.request(.unlimited)
    }
    
    public func receive(_ input: [T]) -> Subscribers.Demand {
        
        queue.sync { [unowned self] in
            let patch = self.patch(from: input)
            
            DispatchQueue.main.async { [weak self] in
                guard let weakSelf = self else { return }
                let count = weakSelf.items.count
                let offset = weakSelf.tableView.contentOffset.y
                UIView.performWithoutAnimation {
                    weakSelf.tableView.beginUpdates()
                    weakSelf.items = patch.result
                    weakSelf.tableView.deleteRows(at: patch.changes.delete.map{ IndexPath(row: $0, section: 0) }, with: .none)
                    weakSelf.tableView.insertRows(at: patch.changes.insert.map{ IndexPath(row: $0, section: 0) }, with: .none)
                    weakSelf.tableView.reloadRows(at: patch.changes.move.map(\.to).map{ IndexPath(row: $0, section: 0) }, with: .none)
                    weakSelf.tableView.endUpdates()
                    
                    let topInsertMap = patch.changes.insert.filter({ $0 < count })
                    if topInsertMap.count > 0 {
                        weakSelf.tableView.scrollToRow(at: IndexPath(row: topInsertMap.count, section: 0), at: .top, animated: false)
                        let newOffset = weakSelf.tableView.contentOffset.y
                        weakSelf.tableView.setContentOffset(CGPoint(x: 0, y: offset + newOffset), animated: false)
                    }
                }
            }
        }
        
        return .unlimited
    }
    
    public func receive(completion: Subscribers.Completion<Never>) {}
}
