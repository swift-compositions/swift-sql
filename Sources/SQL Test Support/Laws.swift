import Byte
public import ISO_9075_Call_Level_Interface
import RFC_4122
public import SQL
import SQL_Macros
import Time

public enum Laws {
    @Table("sql_execution_laws_samples")
    struct Sample: Equatable, Sendable {
        let id: Int
        var name: String
        var ratio: Double
        var flag: Bool
        var note: String?
        var bytes: [Byte]
        var at: Time.Instant
        var reference: RFC_4122.UUID
    }

    @Table("sql_execution_laws_tags")
    struct Tag: Equatable, Sendable {
        let id: Int
        var sample: Int
        var label: String
    }

    static let schema: [ISO_9075.Fragment] = [
        #"CREATE TABLE "sql_execution_laws_samples" ("id" INTEGER PRIMARY KEY, "name" TEXT NOT NULL, "ratio" DOUBLE PRECISION NOT NULL, "flag" BOOLEAN NOT NULL, "note" TEXT, "bytes" \#(ISO_9075.Keyword.binaryLargeObject) NOT NULL, "at" TIMESTAMP WITH TIME ZONE NOT NULL, "reference" UUID NOT NULL)"#,
        #"CREATE TABLE "sql_execution_laws_tags" ("id" INTEGER PRIMARY KEY, "sample" INTEGER NOT NULL, "label" TEXT NOT NULL)"#,
    ]

    static let samples = [
        Sample(id: 1, name: "ada", ratio: 0.5, flag: true, note: nil, bytes: [], at: instant(0), reference: uuid("00000000-0000-4000-8000-000000000001")),
        Sample(
            id: 2,
            name: "grace",
            ratio: 2,
            flag: false,
            note: "compiler",
            bytes: [0x00, 0x7F, 0xFF].map(Byte.init(bitPattern:)),
            at: instant(1_767_225_600),
            reference: uuid("0190b8a4-8a4e-7d2e-9f1c-3b2a1d0e4f5a")
        ),
        Sample(
            id: 3,
            name: "edsger",
            ratio: -1.25,
            flag: true,
            note: "",
            bytes: Array(repeating: Byte(bitPattern: 0x2A), count: 4096),
            at: instant(-86_400),
            reference: uuid("ffffffff-ffff-4fff-bfff-ffffffffffff")
        ),
    ]

    static func instant(_ seconds: Int64) -> Time.Instant {
        Time.Instant(secondsSinceUnixEpoch: seconds)
    }

    static func uuid(_ text: String) -> RFC_4122.UUID {
        do throws(RFC_4122.UUID.Error) {
            return try RFC_4122.UUID(text)
        } catch {
            preconditionFailure("\(text) is a UUID: \(error)")
        }
    }

    static let tags = [
        Tag(id: 1, sample: 1, label: "engine"),
        Tag(id: 2, sample: 2, label: "cobol"),
        Tag(id: 3, sample: 2, label: "navy"),
    ]

    public static func violations(of database: some ISO_9075.Database) async throws(ISO_9075.Error) -> [Violation] {
        try await database.withRollback { connection throws(ISO_9075.Error) in try Self.violations(on: connection) }
            + Self.rollbacks(of: database)
    }

    struct Refusal: Swift.Error, Equatable {
        var statement: ISO_9075.Error?
    }

    static func rollbacks(of database: some ISO_9075.Database) async throws(ISO_9075.Error) -> [Violation] {
        var violations: [Violation] = []
        func expect<Value: Equatable>(_ law: String, _ actual: Value, _ expected: Value) {
            if actual != expected { violations.append(Violation(law: law, expected: "\(expected)", actual: "\(actual)")) }
        }
        func count() async throws(ISO_9075.Error) -> ISO_9075.Value? {
            try await database.read { connection throws(ISO_9075.Error) in
                try connection.fetchOne(#"SELECT COUNT(*) FROM "sql_execution_laws_rollbacks""#) { row throws(ISO_9075.Error) in
                    try row.value(at: 0)
                }
            }
        }
        let insert: ISO_9075.Fragment = #"INSERT INTO "sql_execution_laws_rollbacks" ("id") VALUES (1)"#

        _ = try await database.execute(#"CREATE TABLE "sql_execution_laws_rollbacks" ("id" INTEGER PRIMARY KEY)"#)
        do throws(ISO_9075.Failure<Refusal>) {
            try await database.write { connection throws(Refusal) in
                do throws(ISO_9075.Error) {
                    _ = try connection.execute(insert)
                } catch {
                    throw Refusal(statement: error)
                }
                throw Refusal(statement: nil)
            }
            violations.append(Violation(law: "a write whose body throws its own error fails with it", expected: "the body's error", actual: "a commit"))
        } catch {
            expect("a write whose body throws its own error fails with it", error, .body(Refusal(statement: nil)))
        }
        expect("a write whose body throws its own error rolls back every statement it ran", try await count(), .int(0))

        do throws(ISO_9075.Error) {
            try await database.write { connection throws(ISO_9075.Error) in
                _ = try connection.execute(insert)
                _ = try connection.execute(#"SELECT "missing" FROM "sql_execution_laws_rollbacks""#)
            }
            violations.append(Violation(law: "a write whose second statement fails fails", expected: "an error", actual: "a commit"))
        } catch {}
        expect("a write whose second statement fails rolls back the first", try await count(), .int(0))
        _ = try await database.execute(#"DROP TABLE "sql_execution_laws_rollbacks""#)
        return violations
    }

    static func violations(on connection: some ISO_9075.Connection) throws(ISO_9075.Error) -> [Violation] {
        for statement in schema { _ = try connection.execute(statement) }
        var violations: [Violation] = []
        func expect<Value: Equatable>(_ law: String, _ actual: Value, _ expected: Value) {
            if actual != expected { violations.append(Violation(law: law, expected: "\(expected)", actual: "\(actual)")) }
        }

        try Sample.insert { samples }.execute(connection)
        try Tag.insert { tags }.execute(connection)

        expect("a table counts its rows", try Sample.fetchCount(connection), 3)
        expect("a table fetches every row it holds", try Sample.order(by: \.id).fetchAll(connection), samples)
        expect("a filtered select fetches its one row", try Sample.where { $0.id.eq(2) }.fetchOne(connection), samples[1])
        expect("a select with no row fetches none", try Sample.where { $0.id.eq(9) }.fetchOne(connection), nil)
        expect("a filtered select counts its rows", try Sample.where { $0.flag }.fetchCount(connection), 2)
        expect(
            "a select of columns decodes each column, null included",
            try Sample.order(by: \.id).select { ($0.name, $0.note) }.fetchAll(connection).map { Pair(name: $0, note: $1) },
            samples.map { Pair(name: $0.name, note: $0.note) }
        )
        expect(
            "a select of one column fetches one value",
            try Sample.where { $0.id.eq(3) }.select { $0.ratio }.fetchOne(connection),
            -1.25
        )
        expect(
            "a join fetches each pair of rows",
            try Sample.join(Tag.all) { $0.id.eq($1.sample) }.order { $1.id }.fetchAll(connection).map { Joined(sample: $0.id, tag: $1.label) },
            [Joined(sample: 1, tag: "engine"), Joined(sample: 2, tag: "cobol"), Joined(sample: 2, tag: "navy")]
        )
        expect(
            "an update returns what it changed",
            try Sample.where { $0.id.eq(1) }.update { $0.name = "lovelace" }.returning { $0.name }.fetchAll(connection),
            ["lovelace"]
        )
        expect(
            "a delete returns what it removed",
            try Tag.where { $0.sample.eq(2) }.delete().returning { $0.label }.fetchAll(connection).sorted(),
            ["cobol", "navy"]
        )
        expect("a delete leaves the other rows", try Tag.fetchCount(connection), 1)
        expect("an execute reports the rows it changed", try connection.execute(Sample.where { $0.flag }.update { $0.ratio = 0 }.query), 2)
        expect("an empty table fetches no row", try Tag.where { $0.id.eq(9) }.fetchAll(connection), [])
        expect(
            "a blob, an instant and a UUID come back as they were written",
            try Sample.order(by: \.id).select { ($0.bytes, $0.at, $0.reference) }.fetchAll(connection).map { Typed(bytes: $0, at: $1, reference: $2) },
            samples.map { Typed(bytes: $0.bytes, at: $0.at, reference: $0.reference) }
        )
        do throws(ISO_9075.Error) {
            try Sample.insert { samples[0] }.execute(connection)
            violations.append(Violation(law: "a duplicate key is refused", expected: "an error", actual: "the row was inserted"))
        } catch {
            expect("a duplicate key is refused as an integrity constraint violation", error.state?.class, ISO_9075.Diagnostic.State.integrityConstraintViolation.class)
        }
        return violations
    }

    struct Pair: Equatable {
        let name: String
        let note: String?
    }

    struct Typed: Equatable {
        let bytes: [Byte]
        let at: Time.Instant
        let reference: RFC_4122.UUID
    }

    struct Joined: Equatable {
        let sample: Int
        let tag: String
    }
}

extension Laws {
    public struct Violation: Hashable, Sendable, CustomStringConvertible {
        public let law: String
        public let expected: String
        public let actual: String

        public var description: String { "\(law): expected \(expected), found \(actual)" }
    }
}
