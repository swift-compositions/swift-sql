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

public import Dependencies
public import SQL

/// The dependency key backing ``Dependency/Values/defaultDatabase``. Both the live and test
/// values are ``SQL/Unconfigured`` so an un-wired graph fails loudly at first use.
private enum DefaultDatabaseKey: Dependency.Key {
    static let liveValue: any SQL.Database = SQL.Unconfigured()
    static let testValue: any SQL.Database = SQL.Unconfigured()
}

extension Dependency.Values {
    /// The ambient ``SQL/Database``. Defaults to ``SQL/Unconfigured``; wire a live database at
    /// boot with `withDependencies { $0.defaultDatabase = … }`.
    public var defaultDatabase: any SQL.Database {
        get { self[DefaultDatabaseKey.self] }
        set { self[DefaultDatabaseKey.self] = newValue }
    }
}
