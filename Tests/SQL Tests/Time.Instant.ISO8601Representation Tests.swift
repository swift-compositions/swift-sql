import Byte
import RFC_4122
import SQL
import Testing
import Time

@Suite struct `Time.Instant.ISO8601Representation` {
    /// One text column, as a store hands it back.
    struct Text: QueryDecoder {
        var text: String?

        mutating func decode(_ columnType: String.Type) throws(QueryDecodingError) -> String? { text }
        mutating func decode(_ columnType: [Byte].Type) throws(QueryDecodingError) -> [Byte]? { throw .typeMismatch(expected: "text") }
        mutating func decode(_ columnType: Double.Type) throws(QueryDecodingError) -> Double? { throw .typeMismatch(expected: "text") }
        mutating func decode(_ columnType: Int64.Type) throws(QueryDecodingError) -> Int64? { throw .typeMismatch(expected: "text") }
        mutating func decode(_ columnType: UInt64.Type) throws(QueryDecodingError) -> UInt64? { throw .typeMismatch(expected: "text") }
        mutating func decode(_ columnType: Bool.Type) throws(QueryDecodingError) -> Bool? { throw .typeMismatch(expected: "text") }
        mutating func decode(_ columnType: Int.Type) throws(QueryDecodingError) -> Int? { throw .typeMismatch(expected: "text") }
        mutating func decode(_ columnType: Time.Instant.Type) throws(QueryDecodingError) -> Time.Instant? { throw .typeMismatch(expected: "text") }
        mutating func decode(_ columnType: RFC_4122.UUID.Type) throws(QueryDecodingError) -> RFC_4122.UUID? { throw .typeMismatch(expected: "text") }
    }

    static let instant = Time.Instant(_unchecked: (), secondsSinceUnixEpoch: 1_792_108_800, nanosecondFraction: 123_000_000)

    @Test func `it binds as the text a timestamp binding writes`() throws {
        let literal = try ISO_9075.Literal.timestamp(Self.instant)
        #expect(literal == "2026-10-16 00:00:00.123")
        #expect(Time.Instant.ISO8601Representation(queryOutput: Self.instant).queryBinding == .text(literal))
    }

    @Test func `stored text decodes to the instant it was written from`() throws {
        var decoder = Text(text: "2026-10-16 00:00:00.123")
        #expect(try Time.Instant.ISO8601Representation(decoder: &decoder).queryOutput == Self.instant)
    }

    @Test func `text that is not a timestamp is refused, and a missing value is missing`() {
        var corrupt = Text(text: "yesterday")
        #expect(throws: QueryDecodingError.self) { try Time.Instant.ISO8601Representation(decoder: &corrupt) }
        var missing = Text(text: nil)
        #expect(throws: QueryDecodingError.self) { try Time.Instant.ISO8601Representation(decoder: &missing) }
    }
}
