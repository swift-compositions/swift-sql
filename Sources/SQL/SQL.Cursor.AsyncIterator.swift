// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-sql open source project
//
// Copyright (c) 2026 Coen ten Thije Boonkkamp and the swift-sql project authors
// Licensed under Apache License v2.0
//
// ===----------------------------------------------------------------------===//

extension SQL.Cursor {
    /// The cursor's serialized, shared-stream iterator.
    public struct AsyncIterator: AsyncIteratorProtocol {
        private let storage: Storage

        init(storage: Storage) {
            self.storage = storage
        }

        /// Fetches and decodes one further row, or ends the stream and releases its resources.
        public mutating func next() async throws(SQL.Error) -> Element? {
            try await storage.next()
        }
    }
}
