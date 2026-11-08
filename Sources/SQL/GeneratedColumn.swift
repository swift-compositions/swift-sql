public import ISO_9075_Foundation

public struct GeneratedColumn<Root: Table, Value: QueryRepresentable & QueryBindable>:
    TableColumnExpression
{
    public let name: String

    @usableFromInline
    let _defaultValue: () -> Value.QueryOutput?

    @usableFromInline
    let _keyPath: () -> KeyPath<Root, Value.QueryOutput>

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
}
