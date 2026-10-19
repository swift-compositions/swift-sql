import ISO_9075_Foundation
public import SQL
public import SnapshotTesting

extension Snapshotting where Value: Statement {
    public static var sql: Snapshotting<Value, String> {
        SimplySnapshotting.lines.pullback(\.query.debugDescription)
    }
}

extension Snapshotting where Value: QueryExpression {
    public static var sql: Snapshotting<Value, String> {
        SimplySnapshotting.lines.pullback(\.queryFragment.debugDescription)
    }
}
