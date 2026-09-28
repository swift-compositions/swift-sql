import ISO_9075_Foundation
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

    @Test func `an insert binds each given column of its draft and leaves out an absent primary key`() {
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
