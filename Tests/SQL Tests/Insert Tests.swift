import ISO_9075_Foundation
import SQL
import SQL_Macros
import Testing

enum `Insert Tests` {}

extension `Insert Tests` {
    @Suite struct `An update where without assignments` {
        @Test func `fails when rendered instead of trapping`() {
            let insert = Reminder.insert(
                values: { Reminder.Draft(title: "Groceries") },
                onConflict: { $0.id },
                where: { $0.isCompleted.eq(false) },
                where: { row, _ in row.isCompleted.eq(true) }
            )
            #expect(throws: ISO_9075.Value.Failure.self) { try Numbered().render(insert.query) }
        }

        @Test func `with assignments renders the update where`() throws {
            let insert = Reminder.insert(
                values: { Reminder.Draft(title: "Groceries") },
                onConflict: { $0.id },
                doUpdate: { row, excluded in row.title = excluded.title },
                where: { row, _ in row.isCompleted.eq(true) }
            )
            let rendering = try Numbered().render(insert.query)
            #expect(rendering.sql.contains("DO UPDATE SET"))
            #expect(rendering.sql.contains("\nWHERE "))
        }
    }
}
