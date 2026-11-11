import ISO_9075_Call_Level_Interface
import RFC_4122
import SQL
import SQL_Test_Support
import Testing
import Time

@Suite struct `QueryRowDecoder Tests` {
    @Suite struct `Edge Case` {}
}

extension `QueryRowDecoder Tests`.`Edge Case` {
    @Test func `a text column that is no instant is corrupted data, not a type mismatch`() {
        var decoder = QueryRowDecoder(row: TestDatabase.Row(["at": .text("not an instant")]))
        #expect(Self.corrupted { () throws(QueryDecodingError) in _ = try decoder.decode(Time.Instant.self) })
    }

    @Test func `a text column that is no UUID is corrupted data, not a type mismatch`() {
        var decoder = QueryRowDecoder(row: TestDatabase.Row(["reference": .text("not a UUID")]))
        #expect(Self.corrupted { () throws(QueryDecodingError) in _ = try decoder.decode(RFC_4122.UUID.self) })
    }

    static func corrupted(_ body: () throws(QueryDecodingError) -> Void) -> Bool {
        do throws(QueryDecodingError) {
            try body()
            return false
        } catch {
            guard case .dataCorrupted = error else { return false }
            return true
        }
    }
}
