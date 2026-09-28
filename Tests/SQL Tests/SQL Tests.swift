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
                SELECT "reminders"."title"
                FROM "reminders"
                WHERE (("reminders"."isCompleted") = ($1))
                """,
            values: [.bool(true)]
        ))
    }

    @Test func `an insert binds each given column of its draft and leaves out an absent primary key`() {
        let rendering = Numbered().render(Reminder.insert { Reminder.Draft(title: "Groceries") }.query)
        #expect(rendering.values == [.text("Groceries"), .bool(false)])
        #expect(rendering.sql.hasPrefix(#"INSERT INTO "reminders""#))
    }
}
