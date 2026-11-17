import SQL
import SQL_Macros
import SQL_Test_Support
import Testing
import Tests_Apple_Testing_Bridge
import Tests_Inline_Snapshot

private struct Failure: Swift.Error, CustomStringConvertible {
    var description: String { "no such table" }
}

enum `Rows Strategy Tests` {}

extension `Rows Strategy Tests` {
    @Table
    struct Row {
        var id: Int
        var title: String
        var note: String?
    }

    @Suite(.snapshots(record: .never))
    struct `The rows strategy` {
        @Test func `draws a tuple row with one column per element`() {
            snapshot(as: .rows { _ in [(1, "One", Int?.none), (22, "Two", Int?.some(3))] }) {
                Row.all
            } matches: {
                """
                ┌────┬───────┬─────┐
                │ 1  │ "One" │ nil │
                │ 22 │ "Two" │ 3   │
                └────┴───────┴─────┘
                """
            }
        }

        @Test func `draws a struct row with one line per stored property`() {
            snapshot(as: .rows { _ in [Row(id: 1, title: "One", note: nil)] }) {
                Row.all
            } matches: {
                """
                ┌─────────────────┐
                │ Row(            │
                │   id: 1,        │
                │   title: "One", │
                │   note: nil     │
                │ )               │
                └─────────────────┘
                """
            }
        }

        @Test func `draws no rows as no results`() {
            snapshot(as: .rows { _ in [Int]() }) {
                Row.all
            } matches: {
                """
                (No results)
                """
            }
        }

        @Test func `draws a thrown error as its description`() {
            snapshot(as: .rows { _ -> [Int] in throw Failure() }) {
                Row.all
            } matches: {
                """
                no such table
                """
            }
        }
    }
}
