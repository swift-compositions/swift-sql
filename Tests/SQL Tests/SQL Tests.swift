import ISO_9075_Foundation
import Order
import SQL
import SQL_Macros
import Testing

@Table
struct Reminder {
    let id: Int
    var title = ""
    var isCompleted = false
}

struct Numbered: ISO_9075.Dialect {
    func placeholder(_ offset: Int) -> String { "$\(offset)" }
}

@Suite struct `Rendering statements` {
    @Test func `a filtered select binds its values`() {
        let rendering = Numbered().render(Reminder.where { $0.isCompleted.eq(true) }.select(\.title).query)
        #expect(rendering == ISO_9075.Rendering(
            sql: """
                SELECT "reminder"."title"
                FROM "reminder"
                WHERE (("reminder"."isCompleted") = ($1))
                """,
            values: [.bool(true)]
        ))
    }

    @Test func `an insert binds each given column of its draft`() {
        let rendering = Numbered().render(Reminder.insert { Reminder.Draft(title: "Groceries") }.query)
        #expect(rendering.values == [.text("Groceries"), .bool(false)])
        #expect(rendering.sql.hasPrefix(#"INSERT INTO "reminder""#))
    }
}

@Suite struct `Dialect keywords in statements` {
    @Test func `is renders through the dialect`() {
        let fragment = Reminder.where { $0.title.is(Optional("Taxes")) }.query
        #expect(Numbered().render(fragment).sql.contains(#""reminder"."title") IS NOT DISTINCT FROM ($1)"#))
    }

}

struct Positional: ISO_9075.Dialect {
    func placeholder(_ offset: Int) -> String { "?" }
    var defaultPrimaryKey: String { "NULL" }
}

@Suite struct `An absent primary key` {
    let insert = Reminder.insert {
        Reminder.Draft(id: 1, title: "Groceries")
        Reminder.Draft(title: "Taxes")
    }

    @Test func `renders as the standard DEFAULT`() {
        let rendering = Numbered().render(insert.query)
        #expect(rendering.sql.hasSuffix("VALUES\n($1, $2, $3), (DEFAULT, $4, $5)"))
        #expect(rendering.values == [.int(1), .text("Groceries"), .bool(false), .text("Taxes"), .bool(false)])
    }

    @Test func `renders as the dialect spells it`() {
        #expect(Positional().render(insert.query).sql.hasSuffix("VALUES\n(?, ?, ?), (NULL, ?, ?)"))
    }
}


@Suite struct `Statement modifiers` {
    @Test func `an insert places its modifier after the verb`() {
        let insert = Reminder.insert { Reminder.Draft(title: "Groceries") }._modifying("OR REPLACE")
        #expect(Numbered().render(insert.query).sql.hasPrefix(#"INSERT OR REPLACE INTO "reminder""#))
    }

    @Test func `an update places its modifier after the verb`() {
        let update = Reminder.update { $0.title = #bind("Taxes") }._modifying("OR IGNORE")
        #expect(Numbered().render(update.query).sql.hasPrefix(#"UPDATE OR IGNORE "reminder""#))
    }
}

@Suite struct `JSON encoding` {
    @Test func `a boolean enters JSON through the dialect`() {
        let fragment = Bool._queryFragment(jsonEncoding: "\(quote: "isCompleted")")
        #expect(fragment.debugDescription == #""isCompleted""#)
        #expect(Positional().render(fragment).sql == #""isCompleted""#)
    }

    @Test func `other values enter JSON unchanged`() {
        #expect(String._queryFragment(jsonEncoding: "\(quote: "title")").debugDescription == #""title""#)
    }
}

@Suite struct `Ordering terms` {
    @Test func `a direction and null ordering render after the expression`() {
        let sql = Numbered().render(Reminder.order { $0.title.ordered(.descending, nulls: .last) }.query).sql
        #expect(sql.contains(#"ORDER BY "reminder"."title" DESC NULLS LAST"#))
    }

    @Test func `asc without null ordering renders only the direction`() {
        let sql = Numbered().render(Reminder.order { $0.title.asc() }.query).sql
        #expect(sql.contains(#"ORDER BY "reminder"."title" ASC"#))
        #expect(!sql.contains("NULLS"))
    }
}

struct Unbounded: ISO_9075.Dialect {
    func placeholder(_ offset: Int) -> String { "?" }
    var unboundedLimit: String { "-1" }
    var roundOpen: String { "CAST(" }
    var roundClose: String { " AS DOUBLE PRECISION)" }
    var roundOperandOpen: String { "CAST(" }
    var roundOperandClose: String { " AS NUMERIC)" }
    var roundPrecisionOpen: String { "CAST(" }
    var roundPrecisionClose: String { " AS INTEGER)" }
}

@Suite struct `An offset without a limit` {
    let select = Reminder.offset(10).select(\.title)

    @Test func `renders the standard unbounded limit`() {
        #expect(Numbered().render(select.query).sql.hasSuffix("LIMIT ALL OFFSET $1"))
    }

    @Test func `renders the unbounded limit as the dialect spells it`() {
        #expect(Unbounded().render(select.query).sql.hasSuffix("LIMIT -1 OFFSET ?"))
    }
}

@Suite struct `Rounding` {
    @Test func `renders the standard round`() {
        #expect(Numbered().render(2.5.round().queryFragment) == ISO_9075.Rendering(sql: "round($1)", values: [.double(2.5)]))
        #expect(Numbered().render(2.5.round(1).queryFragment) == ISO_9075.Rendering(sql: "round($1, $2)", values: [.double(2.5), .int(1)]))
    }

    @Test func `asks the dialect to convert the operand, the precision and the result`() {
        #expect(Unbounded().render(2.5.round().queryFragment).sql == "CAST(round(CAST(? AS NUMERIC)) AS DOUBLE PRECISION)")
        #expect(Unbounded().render(2.5.round(1).queryFragment).sql == "CAST(round(CAST(? AS NUMERIC), CAST(? AS INTEGER)) AS DOUBLE PRECISION)")
    }
}
