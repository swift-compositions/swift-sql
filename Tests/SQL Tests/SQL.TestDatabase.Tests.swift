import SQL
import SQL_Test_Support
import Testing

@Test func `database scripts fetch all through test row`() async throws {
    let database = SQL.TestDatabase()
    await database.script(rows: [["name": .text("alice")], ["name": .text("bob")]])

    let names = try await database.read {
        (connection: any SQL.Connection) throws(SQL.Error) -> [String] in
        try await connection.fetchAll(SQL.Query(sql: "SELECT name FROM users")) {
            row throws(SQL.Error) in
            try row.string("name")
        }
    }

    #expect(names == ["alice", "bob"])
    let executed = await database.executed
    #expect(executed.count == 1)
    #expect(executed[0].sql == "SELECT name FROM users")
}

@Test func `database fetch all defaults empty`() async throws {
    let database = SQL.TestDatabase()
    let rows = try await database.read {
        (connection: any SQL.Connection) throws(SQL.Error) -> [Int] in
        try await connection.fetchAll(SQL.Query(sql: "SELECT 1")) { _ in 0 }
    }
    #expect(rows.isEmpty)
}

@Test func `database fetch one scripts first row`() async throws {
    let database = SQL.TestDatabase()
    await database.script(rows: [["n": .int64(42)]])
    let value = try await database.read {
        (connection: any SQL.Connection) throws(SQL.Error) -> Int64? in
        try await connection.fetchOne(SQL.Query(sql: "SELECT n")) { row throws(SQL.Error) in
            try row.int64("n")
        }
    }
    #expect(value == 42)
}

@Test func `database execute records and returns zero`() async throws {
    let database = SQL.TestDatabase()
    let count = try await database.execute("CREATE TABLE t (id INT)")
    #expect(count == 0)
    let executed = await database.executed
    #expect(executed.count == 1)
    #expect(executed[0].sql == "CREATE TABLE t (id INT)")
    #expect(executed[0].bindings.isEmpty)
}

@Test func `database with rollback runs body`() async throws {
    let database = SQL.TestDatabase()
    let count = try await database.withRollback {
        (connection: any SQL.Connection) throws(SQL.Error) -> Int in
        try await connection.execute(
            SQL.Query(sql: "INSERT INTO t (id) VALUES ($1)", bindings: [.int(1)])
        )
    }
    #expect(count == 0)
    let executed = await database.executed
    #expect(executed.count == 1)
    #expect(executed[0].bindings == [.int(1)])
}
