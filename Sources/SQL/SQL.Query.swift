// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-sql open source project
//
// Copyright (c) 2026 Coen ten Thije Boonkkamp and the swift-sql project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

extension SQL {
    /// A concrete ad-hoc statement: raw SQL with positional bindings. The value-form conformer of
    /// ``SQL/Statement`` for callers not going through the DSL bridge.
    ///
    /// Conforms to `ExpressibleByStringLiteral`, so a bindings-free statement can be written as a
    /// plain string literal at the call site — e.g. `db.execute("CREATE TABLE …")`.
    public struct Query: SQL.Statement, ExpressibleByStringLiteral {
        public let sql: String
        public let bindings: [SQL.Value]

        public init(sql: String, bindings: [SQL.Value] = []) {
            self.sql = sql
            self.bindings = bindings
        }

        /// Builds a bindings-free query from a string literal.
        public init(stringLiteral value: String) {
            self.init(sql: value, bindings: [])
        }
    }
}
