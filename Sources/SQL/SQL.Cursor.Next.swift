// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-sql open source project
//
// Copyright (c) 2026 Coen ten Thije Boonkkamp and the swift-sql project authors
// Licensed under Apache License v2.0
//
// ===----------------------------------------------------------------------===//

extension SQL.Cursor {
    /// The result of consuming one cursor advance.
    public enum Next: ~Copyable {
        /// One decoded element and the only cursor that may continue iteration.
        case element(Element, SQL.Cursor<Element>)

        /// The provider reached natural exhaustion and its context was resolved reusable.
        case exhausted

        /// Iteration failed or was cancelled and the context was resolved invalid.
        case failure(SQL.Error)
    }
}
