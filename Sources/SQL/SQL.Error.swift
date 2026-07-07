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

extension SQL {
    /// The typed error domain thrown across the execution interface.
    public enum Error: Swift.Error, Sendable {
        /// Connecting to or acquiring a connection from the database failed.
        case connection(String)
        /// A statement failed to execute; the string carries the engine's description.
        case execution(String)
        /// A column could not be decoded into the requested type.
        case decoding(String)
        /// A transaction could not be run or completed.
        case transaction(String)
        /// A migration failed; the string names the migration.
        case migration(String)
        /// A statement binding could not be represented as a ``SQL/Value`` — raised by the DSL
        /// bridge when a source binding has no counterpart in the v0 seam.
        case binding(String)
    }
}
