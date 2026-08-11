// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-sql open source project
//
// Copyright (c) 2026 Coen ten Thije Boonkkamp and the swift-sql project authors
// Licensed under Apache License v2.0
//
// ===----------------------------------------------------------------------===//

extension SQL.Cursor {
    /// A provider advance that preserves the uniquely owned context in every branch.
    public enum Advance<Context: ~Copyable>: ~Copyable {
        /// One decoded element and the context that can advance again.
        case element(Element, Context)

        /// Natural exhaustion and the context to resolve as reusable.
        case exhausted(Context)

        /// An iteration failure and the context to resolve as invalid.
        case failure(SQL.Error, Context)
    }
}
