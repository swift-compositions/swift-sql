// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-sql open source project
//
// Copyright (c) 2026 Coen ten Thije Boonkkamp and the swift-sql project authors
// Licensed under Apache License v2.0
//
// ===----------------------------------------------------------------------===//

extension SQL {
    /// A connection-scoped, pull-driven stream of decoded rows.
    ///
    /// A cursor uniquely owns its provider context. It is deliberately noncopyable and
    /// non-Sendable: each call to ``next()`` consumes the cursor and either returns one element
    /// with the only continuation or reaches a terminal outcome.
    ///
    /// Exhaustion and a successful ``close()`` resolve the context as reusable. Iteration failure,
    /// close failure, and cancellation resolve it as invalid. Dropping a live cursor invokes its
    /// synchronous abandonment operation; a pool handle can therefore take its own invalid/drop
    /// fallback without starting cleanup work in another task.
    public struct Cursor<Element: Sendable>: ~Copyable {
        @usableFromInline
        let storage: Storage

        @usableFromInline
        init(storage: Storage) {
            self.storage = storage
        }

        /// Creates a cursor that uniquely owns `context` across each advance.
        ///
        /// The operation closures are reusable witnesses and must not capture `context`:
        ///
        /// - `next` returns the context in every element, exhaustion, and failure branch.
        /// - `close` returns the context in both success and failure branches.
        /// - `reuse` and `invalidate` consume an explicit terminal disposition asynchronously.
        /// - `abandon` consumes a dropped live context synchronously.
        ///
        /// A provider maps every engine failure to ``SQL/Error`` before returning an outcome.
        public init<Context: ~Copyable>(
            context: consuming sending Context,
            next: @escaping (consuming Context) async -> Advance<Context>,
            close: @escaping (consuming Context) async -> Close<Context>,
            reuse: @escaping (consuming Context) async -> Void,
            invalidate: @escaping (consuming Context) async -> Void,
            abandon: @escaping (consuming Context) -> Void
        ) {
            storage = Storage.Context(
                context: context,
                next: next,
                close: close,
                reuse: reuse,
                invalidate: invalidate,
                abandon: abandon
            )
        }
    }
}

extension SQL.Cursor {
    /// Fetches and decodes at most one row, returning the only continuation on success.
    nonisolated(nonsending)
    public consuming func next() async -> Next {
        await storage.next()
    }

    /// Ends iteration early and resolves the provider context exactly once.
    nonisolated(nonsending)
    public consuming func close() async -> Result<Void, SQL.Error> {
        await storage.close()
    }
}
