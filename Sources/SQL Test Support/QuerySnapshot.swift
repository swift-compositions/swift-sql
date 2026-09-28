public import SnapshotTesting
public import SQL
import ISO_9075_Foundation

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
