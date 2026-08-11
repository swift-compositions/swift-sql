// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-sql open source project
//
// Copyright (c) 2026 Coen ten Thije Boonkkamp and the swift-sql project authors
// Licensed under Apache License v2.0
//
// ===----------------------------------------------------------------------===//

import Pool_Primitives
import SQL
import Synchronization

// These existential types are requirements of swift-sql's own public protocols.
// swiftlint:disable no_any_protocol_existential
extension `Cursor Tests`.Integration {
    actor PoolDatabase: SQL.Database {
        let pool: Pool.Bounded<Session>

        init(dropped: Mutex<Int>) {
            pool = Pool.Bounded(
                capacity: 1,
                drop: { _ in dropped.withLock { $0 += 1 } },
                destroy: { _ in }
            )
        }

        func fill() async throws(Pool.Lifecycle.Error) {
            try await pool.fill(Session(remaining: 1))
        }

        var outstanding: Int { pool.metrics.outstanding.current }

        func shutdown() async {
            await pool.shutdown()
        }

        func cursor<Value: Sendable>(
            _ statement: some SQL.Statement,
            decode: sending @escaping (any SQL.Row) throws(SQL.Error) -> Value
        ) async throws(SQL.Error) -> sending SQL.Cursor<Value> {
            _ = statement.sql
            let handle: Pool.Bounded<Session>.Handle
            do throws(Pool.Lifecycle.Error) {
                handle = try await pool.checkout()
            } catch {
                switch error {
                case .cancelled: throw .cancelled
                case .shutdown: throw .connection("database is shut down")
                case .creationFailed: throw .connection("connection creation failed")
                }
            }

            return SQL.Cursor<Value>(
                context: Context(handle: handle, decode: decode),
                next: { context in .exhausted(context) },
                close: { context in .success(context) },
                reuse: { context in _ = await context.handle.resolve(.reusable(())) },
                invalidate: { context in _ = await context.handle.resolve(.invalid(())) },
                abandon: { context in discard context }
            )
        }

        func read<Value: Sendable>(
            _ body: @Sendable (any SQL.Connection) async throws(SQL.Error) -> Value
        ) async throws(SQL.Error) -> Value {
            _ = body
            throw .connection("unsupported PoolDatabase read scope")
        }

        func write<Value: Sendable>(
            _ body: @Sendable (any SQL.Connection) async throws(SQL.Error) -> Value
        ) async throws(SQL.Error) -> Value {
            _ = body
            throw .connection("unsupported PoolDatabase write scope")
        }

        func withRollback<Value: Sendable>(
            _ body: @Sendable (any SQL.Connection) async throws(SQL.Error) -> Value
        ) async throws(SQL.Error) -> Value {
            _ = body
            throw .connection("unsupported PoolDatabase rollback scope")
        }
    }
}
// swiftlint:enable no_any_protocol_existential
