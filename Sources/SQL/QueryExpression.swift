public import ISO_9075_Foundation

public protocol QueryExpression<QueryValue> {
    associatedtype QueryValue

    var queryFragment: ISO_9075.Fragment { get }

    static var _columnWidth: Int { get }

    var _allFragments: [ISO_9075.Fragment] { get }
}

extension QueryExpression {
    public static var _columnWidth: Int {
        1
    }

    public var _allFragments: [ISO_9075.Fragment] {
        [queryFragment]
    }
}

public func _columnWidth<Root, Value: QueryExpression>(_ keyPath: KeyPath<Root, Value>) -> Int {
    Value._columnWidth
}
