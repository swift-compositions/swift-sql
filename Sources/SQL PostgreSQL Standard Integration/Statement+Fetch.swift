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

#if PostgreSQLStandardIntegration

    public import PostgreSQL_Standard
    public import SQL

    // The statement-first row-decoding sugar: `statement.fetchAll(db)` / `statement.fetchOne(db)`.
    // It lowers the DSL statement into a ``SQL/Query``, runs it, and drives ``SQL/RowDecoder`` over
    // each returned `any SQL.Row` to produce decoded `QueryOutput` values.
    //
    // Scope routing — every fetch runs through ``SQL/Database/write(_:)``, NOT `read`. A DSL statement
    // carries no engine-free marker distinguishing a pure `SELECT` from a fetch-with-effects
    // (`INSERT … RETURNING`, `UPDATE … RETURNING`), and the app calls `.fetchOne(db)` on exactly those
    // `RETURNING` mutations. Routing a mutation through `read` would run a write inside a read scope;
    // routing a plain `SELECT` through `write` merely runs a harmless read inside a (committed) write
    // transaction. Since only one of those is a correctness bug, all fetch sugar takes the
    // write-capable scope. If the DSL later exposes a clean mutation-vs-select discriminator at the
    // `Statement` seam, the pure-`SELECT` overloads can be split back onto `read`.

    // `any SQL.Connection` / `any SQL.Row` / `any SQL.Database` existentials are the
    // deliberate engine-free membrane design: conformers are engine-specific and
    // heterogeneous; generics would leak the engine type into consumer signatures.
    // swiftlint:disable no_any_protocol_existential
    extension Statement where QueryValue: QueryRepresentable, QueryValue.QueryOutput: Sendable {
        /// Runs this single-value DSL statement on `database` and decodes every row.
        ///
        /// The statement's `QueryValue` is a single ``QueryRepresentable`` (a column value or a
        /// `@Table` record); each row decodes to one `QueryValue.QueryOutput`.
        public func fetchAll(
            _ database: any SQL.Database
        ) async throws(SQL.Error) -> [QueryValue.QueryOutput] {
            let query = try SQL.Query(self)
            return try await database.write { connection throws(SQL.Error) in
                try await connection.fetchAll(query) {
                    (row: any SQL.Row) throws(SQL.Error) -> QueryValue.QueryOutput in
                    var decoder = SQL.RowDecoder(row: row)
                    do {
                        return try QueryValue(decoder: &decoder).queryOutput
                    } catch let error as SQL.Error {
                        throw error
                    } catch {
                        throw SQL.Error.decoding("\(error)")
                    }
                }
            }
        }

        /// Runs this single-value DSL statement on `database` and decodes the first row, or `nil`.
        public func fetchOne(
            _ database: any SQL.Database
        ) async throws(SQL.Error) -> QueryValue.QueryOutput? {
            let query = try SQL.Query(self)
            return try await database.write { connection throws(SQL.Error) in
                try await connection.fetchOne(query) {
                    (row: any SQL.Row) throws(SQL.Error) -> QueryValue.QueryOutput in
                    var decoder = SQL.RowDecoder(row: row)
                    do {
                        return try QueryValue(decoder: &decoder).queryOutput
                    } catch let error as SQL.Error {
                        throw error
                    } catch {
                        throw SQL.Error.decoding("\(error)")
                    }
                }
            }
        }
    }

    extension Statement
    where QueryValue == (), Joins == (), From: Sendable, From.QueryOutput: Sendable {
        /// Runs this whole-row DSL statement on `database` and decodes every row into a `From` record.
        ///
        /// The whole-row shape: a statement with no `.select` narrowing — a bare `Table.all` /
        /// `.where { … }` chain — carries `QueryValue == ()` with the selection being all of `From`'s
        /// columns (the DSL's own spelling for this case: `S.QueryValue == (), S.Joins == ()` with the
        /// effective selection `S.From`, see `CTE.With`). Each row decodes through the `@Table`-
        /// generated `From.init(decoder:)`. `Joins == ()` keeps a join-without-select statement (whose
        /// rows span multiple tables) from silently decoding just the first table — that shape must go
        /// through `.select`/`.selectStar()` onto the tuple overloads.
        public func fetchAll(
            _ database: any SQL.Database
        ) async throws(SQL.Error) -> [From.QueryOutput] {
            let query = try SQL.Query(self)
            return try await database.write { connection throws(SQL.Error) in
                try await connection.fetchAll(query) {
                    (row: any SQL.Row) throws(SQL.Error) -> From.QueryOutput in
                    var decoder = SQL.RowDecoder(row: row)
                    do {
                        return try From(decoder: &decoder).queryOutput
                    } catch let error as SQL.Error {
                        throw error
                    } catch {
                        throw SQL.Error.decoding("\(error)")
                    }
                }
            }
        }

        /// Runs this whole-row DSL statement on `database` and decodes the first row, or `nil`.
        public func fetchOne(
            _ database: any SQL.Database
        ) async throws(SQL.Error) -> From.QueryOutput? {
            let query = try SQL.Query(self)
            return try await database.write { connection throws(SQL.Error) in
                try await connection.fetchOne(query) {
                    (row: any SQL.Row) throws(SQL.Error) -> From.QueryOutput in
                    var decoder = SQL.RowDecoder(row: row)
                    do {
                        return try From(decoder: &decoder).queryOutput
                    } catch let error as SQL.Error {
                        throw error
                    } catch {
                        throw SQL.Error.decoding("\(error)")
                    }
                }
            }
        }
    }

    extension Statement {
        /// Runs this join-shaped DSL statement on `database` and decodes every row into a tuple.
        ///
        /// The pack overload covers statements whose `QueryValue` is a tuple `(repeat each C)` — the
        /// shape a multi-table join's selection produces, which is not a single ``QueryRepresentable``.
        /// Each row decodes column-groups left to right via `decodeColumns`. Marked
        /// `@_disfavoredOverload` so a single-value statement (whose `QueryValue` also unifies with a
        /// length-one pack) still resolves to the `QueryValue: QueryRepresentable` overload above.
        @_disfavoredOverload
        public func fetchAll<each C: QueryRepresentable>(
            _ database: any SQL.Database
        ) async throws(SQL.Error) -> [(repeat (each C).QueryOutput)]
        where
            QueryValue == (repeat each C), repeat each C: Sendable,
            repeat (each C).QueryOutput: Sendable
        {
            let query = try SQL.Query(self)
            return try await database.write { connection throws(SQL.Error) in
                try await connection.fetchAll(query) {
                    (row: any SQL.Row) throws(SQL.Error) -> (repeat (each C).QueryOutput) in
                    var decoder = SQL.RowDecoder(row: row)
                    do {
                        return try decoder.decodeColumns((repeat each C).self)
                    } catch let error as SQL.Error {
                        throw error
                    } catch {
                        throw SQL.Error.decoding("\(error)")
                    }
                }
            }
        }

        /// Runs this join-shaped DSL statement on `database` and decodes the first row, or `nil`.
        @_disfavoredOverload
        public func fetchOne<each C: QueryRepresentable>(
            _ database: any SQL.Database
        ) async throws(SQL.Error) -> (repeat (each C).QueryOutput)?
        where
            QueryValue == (repeat each C), repeat each C: Sendable,
            repeat (each C).QueryOutput: Sendable
        {
            let query = try SQL.Query(self)
            return try await database.write { connection throws(SQL.Error) in
                try await connection.fetchOne(query) {
                    (row: any SQL.Row) throws(SQL.Error) -> (repeat (each C).QueryOutput) in
                    var decoder = SQL.RowDecoder(row: row)
                    do {
                        return try decoder.decodeColumns((repeat each C).self)
                    } catch let error as SQL.Error {
                        throw error
                    } catch {
                        throw SQL.Error.decoding("\(error)")
                    }
                }
            }
        }
    }
// swiftlint:enable no_any_protocol_existential

#endif  // PostgreSQLStandardIntegration
