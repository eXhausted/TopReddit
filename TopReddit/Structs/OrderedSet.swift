import Foundation

struct OrderedSet<E: Hashable> {
    
    private var array: [E]
    private var set: Set<E>
    
    init() {
        array = .init()
        set = .init()
    }
    
    var first: E? { array.first }
    var count: Int { array.count }
    
    @discardableResult
    mutating
    func dropFirst() -> E? {
        guard array.count > 0 else { return nil }
        let element = array.remove(at: 0)
        set.remove(element)
        return element
    }
    
    mutating
    func append(_ element: E) {
        self[array.count] = element
    }
}

extension OrderedSet {
    
    subscript(_ i: Int) -> E {
        get {
            return array[i]
        }
        
        set {
            guard set.insert(newValue).inserted else { return }
            array.append(newValue)
        }
    }
}
