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
    /// The seam a connection runs: a prepared SQL string plus its positional bindings.
    ///
    /// This is the deliberate quarantine point for the Structured Queries DSL coupling. The DSL's
    /// `Statement.query.prepare { "$\($0)" }` produces exactly a `(sql, bindings)` pair; the DSL
    /// bridge lowering a DSL statement into a ``SQL/Query`` is a thin, removable adapter. Because
    /// the seam itself depends on nothing but the standard library and institute vocabulary, the
    /// execution interface builds with or without the DSL package present.
    public protocol Statement: Sendable {
        /// The SQL text with `$1`, `$2`, … positional placeholders.
        var sql: String { get }
        /// The positional bindings, in `$1…$n` order.
        var bindings: [SQL.Value] { get }
    }
}
