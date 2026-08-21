extension SQL {

    public protocol Statement: Sendable {

        var sql: String { get }

        var bindings: [SQL.Value] { get }
    }
}
