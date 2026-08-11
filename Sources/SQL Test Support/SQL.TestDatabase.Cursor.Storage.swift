// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-sql open source project
//
// Copyright (c) 2026 Coen ten Thije Boonkkamp and the swift-sql project authors
// Licensed under Apache License v2.0
//
// ===----------------------------------------------------------------------===//

internal import Synchronization

extension SQL.TestDatabase.Cursor {
    final class Storage: Sendable {
        let state = Mutex(State())
    }
}

extension SQL.TestDatabase.Cursor.Storage {
    var closed: Int {
        state.withLock { $0.releases }
    }

    func open(_ rows: [[String: SQL.Value]]) -> Int {
        state.withLock { state in
            let identifier = state.identifier
            state.identifier += 1
            state.rows[identifier] = rows
            return identifier
        }
    }

    func next(_ identifier: Int) -> [String: SQL.Value]? {
        state.withLock { state in
            guard var rows = state.rows[identifier], !rows.isEmpty else { return nil }
            let row = rows.removeFirst()
            state.rows[identifier] = rows
            return row
        }
    }

    func close(_ identifier: Int) {
        state.withLock { state in
            guard state.rows.removeValue(forKey: identifier) != nil else { return }
            state.releases += 1
        }
    }
}
