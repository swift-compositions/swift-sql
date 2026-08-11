// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-sql open source project
//
// Copyright (c) 2026 Coen ten Thije Boonkkamp and the swift-sql project authors
// Licensed under Apache License v2.0
//
// ===----------------------------------------------------------------------===//

internal import SQL

// `any SQL.Row` is the parameter type in swift-sql's own `SQL.Reader` requirement.
// swiftlint:disable no_any_protocol_existential
extension SQL.TestDatabase.Cursor {
    /// A scripted cursor's uniquely owned continuation state.
    struct Context<Value: Sendable>: ~Copyable {
        let database: SQL.TestDatabase
        let identifier: Int
        let decode: (any SQL.Row) throws(SQL.Error) -> Value
    }
}
// swiftlint:enable no_any_protocol_existential
