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

/// The engine-free SQL execution interface.
///
/// `SQL` is the namespace for a database-agnostic execution surface: a statement seam
/// (``SQL/Statement`` / ``SQL/Query``), a binding vocabulary (``SQL/Value``), a decoded-row
/// protocol (``SQL/Row``), and the execution handles (``SQL/Connection``, ``SQL/Reader``,
/// ``SQL/Database``). It carries no engine dependency — a live engine (e.g. PostgresNIO behind
/// an institute membrane) conforms to these protocols, and the DSL bridge lowers a Structured
/// Queries statement into a ``SQL/Query``. Because the seam depends on nothing but institute
/// L1/L2 vocabulary, consumers compile and test against it with no database present.
public enum SQL {}
