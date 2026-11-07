public import ISO_9075_Foundation

public protocol TableColumnExpression<Root, Value>: _TableColumnExpression
where Value: QueryBindable {
    var name: String { get }

}
