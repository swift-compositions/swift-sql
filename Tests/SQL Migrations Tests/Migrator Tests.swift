import ISO_9075_Call_Level_Interface
import SQL_Migrations
import SQL_Test_Support
import Testing

@Suite struct `Registering migrations` {
    @Test func `migrations keep their registration order`() {
        var migrator = Migrator<TestDatabase>()
        migrator.register("v1") { _ in }
        migrator.register(Migration(name: "v2") { _ in })
        #expect(migrator.names == ["v1", "v2"])
    }

    @Test func `pending leaves out the applied ones, in order`() {
        let migrator = Migrator<TestDatabase>(["a", "b", "c", "d"].map { name in Migration(name: name) { _ in } })
        #expect(migrator.pending(applied: ["a", "c"]).map(\.name) == ["b", "d"])
    }
}

@Suite struct `Migrating a database` {
    @Test func `the bookkeeping table comes first, then each migration is recorded`() async throws {
        let database = TestDatabase()
        try await Migrator<TestDatabase>(["v1", "v2"].map { name in Migration(name: name) { _ in } }).migrate(database)
        let executed = await database.executed
        #expect(executed.first?.sql.hasPrefix(#"CREATE TABLE IF NOT EXISTS "_sql_migrations""#) == true)
        #expect(executed.dropFirst().first?.sql == #"SELECT "name" FROM "_sql_migrations""#)
        #expect(executed.dropFirst(2).map(\.values) == [[.text("v1")], [.text("v2")]])
        #expect(await database.scopes == [.write, .read, .write, .write])
    }

    @Test func `applied migrations are skipped`() async throws {
        let database = TestDatabase()
        await database.script([])
        await database.script([TestDatabase.Row(["name": .text("v1")])])
        try await Migrator<TestDatabase>(["v1", "v2"].map { name in Migration(name: name) { _ in } }).migrate(database)
        #expect(await database.executed.dropFirst(2).map(\.values) == [[.text("v2")]])
    }

    @Test func `a failing migration names itself and is not recorded`() async {
        let database = TestDatabase()
        let migrator = Migrator<TestDatabase>([Migration(name: "v1") { _ throws(ISO_9075.Error) in throw .execution("boom") }])
        await #expect(throws: Migrator<TestDatabase>.Error.migration(name: "v1", .execution("boom"))) {
            try await migrator.migrate(database)
        }
        #expect(await database.executed.count == 2)
    }
}
