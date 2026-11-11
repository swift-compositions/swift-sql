import Cardinal
import ISO_9075_Call_Level_Interface
import SQL
import SQL_Macros
import SQL_Test_Support
import Testing

@Suite struct `Fetching Tests` {
    @Suite struct Unit {}
    @Suite struct `Edge Case` {}

    @Table("fetching_samples")
    struct Sample {
        let id: Int
    }
}

extension `Fetching Tests`.Unit {
    @Test func `a table's count is the cardinal its engine reports`() async throws {
        let database = TestDatabase()
        database.script([TestDatabase.Row(["count": .int(3)])])
        let count = try await database.read { connection throws(ISO_9075.Error) in
            try `Fetching Tests`.Sample.fetch.count(connection)
        }
        #expect(count == 3)
    }
}

extension `Fetching Tests`.`Edge Case` {
    @Test func `a negative count is the statement's decoding error, not a cardinal`() async {
        let database = TestDatabase()
        database.script([TestDatabase.Row(["count": .int(-1)])])
        let error = await #expect(throws: ISO_9075.Error.self) {
            try await database.read { connection throws(ISO_9075.Error) in
                try `Fetching Tests`.Sample.fetch.count(connection)
            }
        }
        #expect(error.map(Self.decoding) == true)
    }

    static func decoding(_ error: ISO_9075.Error) -> Bool {
        guard case .decoding = error else { return false }
        return true
    }
}
