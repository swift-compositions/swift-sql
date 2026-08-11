// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-sql open source project
//
// Copyright (c) 2026 Coen ten Thije Boonkkamp and the swift-sql project authors
// Licensed under Apache License v2.0
//
// ===----------------------------------------------------------------------===//

extension SQL {
    /// A connection-scoped, pull-driven sequence of decoded rows.
    ///
    /// A cursor does not collect result rows. Each call to ``AsyncIterator/next()`` asks its
    /// provider for at most one further value. A cursor has one shared consumer: copies and
    /// iterators advance the same stream, so callers must not iterate it concurrently.
    ///
    /// Its connection remains leased until the stream reaches `nil`, an iteration error occurs,
    /// ``close()`` is called, or the consuming task is cancelled. Providers receive `close` once
    /// at that terminal transition and must release the server-side cursor and its connection-local
    /// resources there. A provider maps every engine failure to ``SQL/Error`` before exposing it.
    public struct Cursor<Element: Sendable>: AsyncSequence, Sendable {
        public typealias Failure = SQL.Error

        private let storage: Storage

        /// Creates a pull-driven cursor around one provider-owned row source.
        ///
        /// `next` must fetch and decode no more than one row per invocation. `close` releases the
        /// provider resource and is invoked exactly once by the cursor's terminal transition.
        public init(
            next: @escaping @Sendable () async throws(SQL.Error) -> Element?,
            close: @escaping @Sendable () async -> Void
        ) {
            storage = Storage(next: next, close: close)
        }

        /// Makes an iterator over the cursor's one shared stream.
        public func makeAsyncIterator() -> AsyncIterator {
            AsyncIterator(storage: storage)
        }

        /// Ends iteration early and releases the provider cursor.
        public func close() async {
            await storage.close()
        }
    }
}
