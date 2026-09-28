public import ISO_9075_Foundation

public protocol _TableColumnExpression<Root, Value>: QueryExpression where Value == QueryValue {
    associatedtype Root: Table
    associatedtype Value: QueryRepresentable

    var _names: [String] { get }

    var defaultValue: Value.QueryOutput? { get }

    var keyPath: KeyPath<Root, Value.QueryOutput> { get }
}

public protocol TableColumnExpression<Root, Value>: _TableColumnExpression
where Value: QueryBindable {
    var name: String { get }

}

extension TableColumnExpression {
    public var _names: [String] { [name] }

    package var returningFragment: ISO_9075.Fragment {
        Value.queryFragment(decoding: "\(quote: name)")
    }
}

public protocol WritableTableColumnExpression<Root, Value>: TableColumnExpression {}

public struct TableColumn<Root: Table, Value: QueryRepresentable & QueryBindable>:
    WritableTableColumnExpression
{
    public typealias QueryValue = Value

    public let name: String

    @usableFromInline
    let _defaultValue: () -> Value.QueryOutput?

    @usableFromInline
    let _keyPath: () -> KeyPath<Root, Value.QueryOutput>

    public var defaultValue: Value.QueryOutput? { _defaultValue() }

    public var keyPath: KeyPath<Root, Value.QueryOutput> { _keyPath() }

    @inlinable
    public init(
        _ name: String,
        keyPath: @autoclosure @escaping () -> KeyPath<Root, Value.QueryOutput>,
        default defaultValue: @autoclosure @escaping () -> Value.QueryOutput? = nil
    ) {
        self.name = name
        self._defaultValue = defaultValue
        self._keyPath = keyPath
    }

    @inlinable
    public init(
        _ name: String,
        keyPath: @autoclosure @escaping () -> KeyPath<Root, Value>,
        default defaultValue: @autoclosure @escaping () -> Value? = nil
    ) where Value == Value.QueryOutput {
        self.name = name
        self._defaultValue = defaultValue
        self._keyPath = keyPath
    }

    public var queryFragment: ISO_9075.Fragment {
        let column: ISO_9075.Fragment = "\(Root.self).\(quote: name)"
        return _isSelecting ? Value.queryFragment(decoding: column) : column
    }

    public var _columns: [Column<Root>] {
        [Column(name: name, isWritable: true, keyPath: keyPath, as: Value.self)]
    }

    public var _writableColumns: [Column<Root>] { _columns }
}

public enum _TableColumn<Root: Table, Value: QueryRepresentable> {
    @inlinable
    public static func `for`(
        _ name: String,
        keyPath: @autoclosure @escaping () -> KeyPath<Root, Value.QueryOutput>,
        default defaultValue: @autoclosure @escaping () -> Value.QueryOutput? = nil
    ) -> TableColumn<Root, Value>
    where Value: QueryBindable {
        TableColumn(name, keyPath: keyPath(), default: defaultValue())
    }

    @inlinable
    public static func `for`(
        _ name: String,
        keyPath: @autoclosure @escaping () -> KeyPath<Root, Value>,
        default defaultValue: @autoclosure @escaping () -> Value? = nil
    ) -> TableColumn<Root, Value>
    where Value: QueryBindable, Value == Value.QueryOutput {
        TableColumn(name, keyPath: keyPath(), default: defaultValue())
    }

    @_disfavoredOverload
    public static func `for`(
        _ name: String,
        keyPath: @autoclosure @escaping () -> KeyPath<Root, Value.QueryOutput>,
        default defaultValue: @autoclosure @escaping () -> Value.QueryOutput? = nil
    ) -> ColumnGroup<Root, Value>
    where Value: Table, Value.QueryOutput: Table {
        ColumnGroup(name, keyPath: keyPath(), default: defaultValue())
    }

    @_disfavoredOverload
    public static func `for`(
        _ name: String,
        keyPath: KeyPath<Root, Value>,
        default defaultValue: Value? = nil
    ) -> ColumnGroup<Root, Value>
    where Value: Table, Value == Value.QueryOutput {
        ColumnGroup(name, keyPath: keyPath, default: defaultValue)
    }

    public static func `for`<Wrapped>(
        _ name: String,
        keyPath: @autoclosure @escaping () -> KeyPath<Root, Value.QueryOutput>,
        default defaultValue: @autoclosure @escaping () -> Value.QueryOutput? = nil
    ) -> OptionalColumnGroup<Root, Wrapped>
    where Value == Wrapped?, Wrapped: Table, Wrapped.QueryOutput: Table {
        OptionalColumnGroup(base: ColumnGroup(name, keyPath: keyPath(), default: defaultValue()))
    }
}

public enum GeneratedColumnStorage {
    case virtual, stored
}

public struct GeneratedColumn<Root: Table, Value: QueryRepresentable & QueryBindable>:
    TableColumnExpression
{
    public typealias QueryValue = Value

    public let name: String

    @usableFromInline
    let _defaultValue: () -> Value.QueryOutput?

    @usableFromInline
    let _keyPath: () -> KeyPath<Root, Value.QueryOutput>

    public var defaultValue: Value.QueryOutput? { _defaultValue() }

    public var keyPath: KeyPath<Root, Value.QueryOutput> { _keyPath() }

    @inlinable
    public init(
        _ name: String,
        keyPath: @autoclosure @escaping () -> KeyPath<Root, Value.QueryOutput>,
        default defaultValue: @autoclosure @escaping () -> Value.QueryOutput? = nil
    ) {
        self.name = name
        self._defaultValue = defaultValue
        self._keyPath = keyPath
    }

    @inlinable
    public init(
        _ name: String,
        keyPath: @autoclosure @escaping () -> KeyPath<Root, Value.QueryOutput>,
        default defaultValue: @autoclosure @escaping () -> Value? = nil
    ) where Value == Value.QueryOutput {
        self.name = name
        self._defaultValue = defaultValue
        self._keyPath = keyPath
    }

    public var queryFragment: ISO_9075.Fragment {
        let column: ISO_9075.Fragment = "\(Root.self).\(quote: name)"
        return _isSelecting ? Value.queryFragment(decoding: column) : column
    }

    public var _columns: [Column<Root>] {
        [Column(name: name, isWritable: false, keyPath: keyPath, as: Value.self)]
    }
}
