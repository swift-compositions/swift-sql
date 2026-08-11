// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-sql open source project
//
// Copyright (c) 2026 Coen ten Thije Boonkkamp and the swift-sql project authors
// Licensed under Apache License v2.0
//
// ===----------------------------------------------------------------------===//

extension SQL.Cursor {
    /// A provider close that preserves the uniquely owned context until disposition.
    public enum Close<Context: ~Copyable>: ~Copyable {
        /// The provider cursor closed successfully and the context may be reused.
        case success(Context)

        /// Closing failed and the context must be invalidated.
        case failure(SQL.Error, Context)
    }
}
