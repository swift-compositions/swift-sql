// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-sql open source project
//
// Copyright (c) 2026 Coen ten Thije Boonkkamp and the swift-sql project authors
// Licensed under Apache License v2.0
//
// ===----------------------------------------------------------------------===//

extension SQL.Cursor {
    @usableFromInline
    class Storage {
        @usableFromInline
        init() {}
    }
}

extension SQL.Cursor.Storage {
    @usableFromInline
    nonisolated(nonsending)
    func next() async -> SQL.Cursor<Element>.Next {
        preconditionFailure("SQL.Cursor.Storage.next must be overridden")
    }

    @usableFromInline
    nonisolated(nonsending)
    func close() async -> Result<Void, SQL.Error> {
        preconditionFailure("SQL.Cursor.Storage.close must be overridden")
    }
}
