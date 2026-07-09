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

import RFC_4122
import SQL
import Testing
import Time_Primitive

@Test func `value equatable`() {
    #expect(SQL.Value.int(1) == .int(1))
    #expect(SQL.Value.null == .null)
    #expect(SQL.Value.text("a") != .text("b"))
    #expect(SQL.Value.int(1) != .int64(1))
}

@Test func `uuid value equatable and hashable`() throws {
    let uuid = try RFC_4122.UUID("550e8400-e29b-41d4-a716-446655440000")
    let other = try RFC_4122.UUID("550e8400-e29b-41d4-a716-446655440001")
    #expect(SQL.Value.uuid(uuid) == .uuid(uuid))
    #expect(SQL.Value.uuid(uuid) != .uuid(other))
    var set: Set<SQL.Value> = []
    set.insert(.uuid(uuid))
    set.insert(.uuid(uuid))
    #expect(set.count == 1)
}

@Test func `timestamp value equatable`() {
    let instant = Instant(secondsSinceUnixEpoch: 1_700_000_000)
    let later = Instant(secondsSinceUnixEpoch: 1_700_000_001)
    #expect(SQL.Value.timestamp(instant) == .timestamp(instant))
    #expect(SQL.Value.timestamp(instant) != .timestamp(later))
}

@Test func `jsonb and blob value equatable`() {
    #expect(SQL.Value.jsonb([0x7b, 0x7d]) == .jsonb([0x7b, 0x7d]))
    #expect(SQL.Value.jsonb([0x7b, 0x7d]) != .blob([0x7b, 0x7d]))
    #expect(SQL.Value.blob([1, 2, 3]) == .blob([1, 2, 3]))
    var set: Set<SQL.Value> = [.jsonb([1]), .blob([1]), .jsonb([1])]
    #expect(set.count == 2)
    set.insert(.jsonb([2]))
    #expect(set.count == 3)
}
