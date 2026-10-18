#if CasePaths
    import Byte
    import CasePaths
    import RFC_4122
    import SQL
    import SQL_Macros
    import Testing
    import Time

    @Table
    enum Attachment: Equatable {
        case link(String)
        case note(String)
    }

    struct RenderedValues: QueryDecoder {
        var values: [ISO_9075.Value]

        mutating func next() -> ISO_9075.Value {
            values.isEmpty ? .null : values.removeFirst()
        }

        mutating func decode(_ columnType: [Byte].Type) throws(QueryDecodingError) -> [Byte]? {
            switch next() {
            case .null: nil
            case .blob(let bytes): bytes
            default: throw .typeMismatch(expected: "blob")
            }
        }

        mutating func decode(_ columnType: Double.Type) throws(QueryDecodingError) -> Double? {
            switch next() {
            case .null: nil
            case .double(let double): double
            default: throw .typeMismatch(expected: "double")
            }
        }

        mutating func decode(_ columnType: Int64.Type) throws(QueryDecodingError) -> Int64? {
            switch next() {
            case .null: nil
            case .int(let int): int
            default: throw .typeMismatch(expected: "int")
            }
        }

        mutating func decode(_ columnType: UInt64.Type) throws(QueryDecodingError) -> UInt64? {
            try decode(Int64.self).map(UInt64.init)
        }

        mutating func decode(_ columnType: String.Type) throws(QueryDecodingError) -> String? {
            switch next() {
            case .null: nil
            case .text(let text): text
            default: throw .typeMismatch(expected: "text")
            }
        }

        mutating func decode(_ columnType: Bool.Type) throws(QueryDecodingError) -> Bool? {
            switch next() {
            case .null: nil
            case .bool(let bool): bool
            default: throw .typeMismatch(expected: "bool")
            }
        }

        mutating func decode(_ columnType: Int.Type) throws(QueryDecodingError) -> Int? {
            try decode(Int64.self).map(Int.init)
        }

        mutating func decode(_ columnType: Time.Instant.Type) throws(QueryDecodingError) -> Time.Instant? {
            switch next() {
            case .null: nil
            case .timestamp(let instant): instant
            default: throw .typeMismatch(expected: "timestamp")
            }
        }

        mutating func decode(_ columnType: RFC_4122.UUID.Type) throws(QueryDecodingError) -> RFC_4122.UUID? {
            switch next() {
            case .null: nil
            case .uuid(let uuid): uuid
            default: throw .typeMismatch(expected: "uuid")
            }
        }
    }

    struct Dollar: ISO_9075.Dialect {
        func placeholder(_ offset: Int) -> String { "$\(offset)" }
    }

    @Suite struct `An enum table` {
        @Test func `binds the active case and nulls the others`() {
            let rendering = Dollar().render(Attachment.insert { Attachment.note("Groceries") }.query)
            #expect(rendering.sql.hasPrefix(#"INSERT INTO "attachment""#))
            #expect(rendering.sql.hasSuffix("(\"link\", \"note\")\nVALUES\n(NULL, $1)"))
            #expect(rendering.values == [.text("Groceries")])
        }

        @Test func `decodes the case whose column is set`() throws {
            var note = RenderedValues(values: [.null, .text("Groceries")])
            #expect(try Attachment(decoder: &note) == .note("Groceries"))
            var link = RenderedValues(values: [.text("https://example.com"), .null])
            #expect(try Attachment(decoder: &link) == .link("https://example.com"))
        }

        @Test func `filters on a case`() {
            let rendering = Dollar().render(Attachment.where { $0.note.isNot(nil) }.query)
            #expect(rendering.sql.contains(#""attachment"."note""#))
        }
    }
#endif
