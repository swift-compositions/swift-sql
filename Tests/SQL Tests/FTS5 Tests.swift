import ISO_9075_Foundation
import SQL
import SQL_Macros
import Testing

@Table("page")
struct Page {
    let id: Int
    var text: String
}

@Table("pageSearch")
struct PageSearch: FTS5.Table {
    var identifier: Int
    var text: String
}

extension PageSearch {
    @Suite struct FullText {
        @Test func `creation renders columns options tokenizer and external content`() {
            let statement = PageSearch.create(
                ifNotExists: true,
                unindexed: [\PageSearch.identifier],
                tokenizer: .unicode61(
                    diacritics: .complete,
                    tokenCharacters: "_-"
                ),
                content: Page.self,
                rowid: \Page.id
            )

            #expect(
                Numbered().render(statement.query)
                    == ISO_9075.Rendering(
                        sql: """
                            CREATE VIRTUAL TABLE IF NOT EXISTS "pageSearch" USING fts5(\
                            "identifier" UNINDEXED, "text", \
                            tokenize = 'unicode61 remove_diacritics 2 tokenchars ''_-''', \
                            content = 'page', content_rowid = 'id')
                            """,
                        values: []
                    )
            )
        }

        @Test func `insert binds rowid and every column`() {
            let statement = PageSearch.insert(
                rowid: 42,
                PageSearch(identifier: 42, text: "Swift")
            )

            let rendering = Numbered().render(statement.query)

            #expect(rendering.sql.hasPrefix(#"INSERT INTO "pageSearch""#))
            #expect(rendering.sql.contains(#"("rowid", "identifier", "text")"#))
            #expect(rendering.sql.hasSuffix("VALUES\n($1, $2, $3)"))
            #expect(rendering.values == [.int(42), .int(42), .text("Swift")])
        }

        @Test func `delete binds rowid`() {
            let rendering = Numbered().render(PageSearch.delete(rowid: 42).query)

            #expect(rendering.sql.hasPrefix(#"DELETE FROM "pageSearch""#))
            #expect(rendering.sql.hasSuffix(#"WHERE (("pageSearch"."rowid") = ($1))"#))
            #expect(rendering.values == [.int(42)])
        }

        @Test func `match binds table and column patterns`() {
            let table = Numbered().render(PageSearch.where { $0.match("swift OR sqlite") }.query)
            let column = Numbered().render(PageSearch.where { $0.text.match("swift") }.query)

            #expect(table.sql.contains(#"WHERE (("pageSearch" MATCH $1))"#))
            #expect(table.values == [.text("swift OR sqlite")])
            #expect(column.sql.contains(#"WHERE (("pageSearch" MATCH $1))"#))
            #expect(column.values == [.text(#"text:"swift""#)])
        }

        @Test func `trigram exposes only valid option combinations`() {
            let sensitive = Numbered().render(
                PageSearch.create(tokenizer: .trigram(.sensitive)).query
            )
            let insensitive = Numbered().render(
                PageSearch.create(tokenizer: .trigram(.folding)).query
            )

            #expect(sensitive.sql.contains("tokenize = 'trigram case_sensitive 1'"))
            #expect(insensitive.sql.contains("tokenize = 'trigram remove_diacritics 1'"))
        }
    }
}
