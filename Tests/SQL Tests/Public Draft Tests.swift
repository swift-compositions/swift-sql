public import SQL
public import SQL_Macros
import Testing

@Table
public struct Note {
    public let id: Int
    public var title: String = "Untitled"
    public var body: String?
    public var isPinned = false
}

@Suite struct `A public draft` {
    @Test func `takes its memberwise defaults`() {
        let draft = Note.Draft(title: "Groceries")
        #expect(draft.id == nil)
        #expect(draft.title == "Groceries")
        #expect(draft.body == nil)
        #expect(draft.isPinned == false)
    }

    @Test func `takes every column by label`() {
        let draft = Note.Draft(id: 1, title: "Taxes", body: "Q3", isPinned: true)
        let rendering = Numbered().render(Note.insert { draft }.query)
        #expect(rendering.values == [.int(1), .text("Taxes"), .text("Q3"), .bool(true)])
    }
}
