extension SQL {

    public struct Query: SQL.Statement, ExpressibleByStringLiteral {
        public let sql: String
        public let bindings: [SQL.Value]

        public init(sql: String, bindings: [SQL.Value] = []) {
            self.sql = sql
            self.bindings = bindings
        }

        public init(stringLiteral value: String) {
            self.init(sql: value, bindings: [])
        }
    }
}
