import SQL
import SQL_Macros
import Testing

@Table("documents", schema: "main")
private struct Document {
    let id: Int
    var title = ""
    var rating: Double?
}

@Table("documentSearch")
private struct DocumentSearch {
    let rowid: Int
    var title = ""
    var category = ""
}

private struct SchemaDialect: ISO_9075.Dialect {
    func placeholder(_ offset: Int) -> String { "$\(offset)" }
}

extension Schema {
    @Suite struct DDL {
        @Suite struct Unit {}
    }
}

extension Schema.DDL.Unit {
    @Test func `a table declaration renders its complete column definition`() {
        let rendering = SchemaDialect().render(
            Document.create.table(ifNotExists: true, options: [.strict]).query
        )
        #expect(
            rendering.sql
                == """
                CREATE TABLE IF NOT EXISTS "main"."documents" (
                  "id" INTEGER PRIMARY KEY NOT NULL,
                  "title" TEXT NOT NULL,
                  "rating" REAL
                ) STRICT
                """
        )
        #expect(rendering.values.isEmpty)
    }

    @Test func `an index can be unique partial and expression based`() {
        let statement = Document.create.index(
            "documents_title_rating",
            unique: true,
            ifNotExists: true
        ) { columns in
            (columns.title.lower(), columns.rating)
        }
        .where { $0.rating.isNot(nil) }
        let rendering = SchemaDialect().render(statement.query)
        #expect(
            rendering.sql
                == """
                CREATE UNIQUE INDEX IF NOT EXISTS "main"."documents_title_rating" ON "documents" (lower("title"), "rating") WHERE (("rating") IS NOT NULL)
                """
        )
        #expect(rendering.values.isEmpty)
    }

    @Test func `an FTS5 table supports unindexed fields tokenizer options and external content`() {
        let statement = DocumentSearch.create.fts5(
            ifNotExists: true,
            content: Document.self,
            rowid: \.id,
            tokenizer: .trigram()
        ) { columns in
            columns.title
            columns.category.unindexed()
        }
        let rendering = SchemaDialect().render(statement.query)
        #expect(
            rendering.sql
                == """
                CREATE VIRTUAL TABLE IF NOT EXISTS "documentSearch" USING fts5(
                  "title",
                  "category" UNINDEXED,
                  content = 'documents',
                  content_rowid = 'id',
                  tokenize = 'trigram case_sensitive 0 remove_diacritics 0'
                )
                """
        )
        #expect(rendering.values.isEmpty)
    }

    @Test func `drop and add column statements retain typed table identity`() {
        let drop = SchemaDialect().render(Document.drop.table(ifExists: true).query)
        #expect(drop.sql == #"DROP TABLE IF EXISTS "main"."documents""#)

        let add = SchemaDialect().render(Document.alter.add(\.rating).query)
        #expect(add.sql == #"ALTER TABLE "main"."documents" ADD COLUMN "rating" REAL"#)

        let dropIndex = SchemaDialect().render(
            Document.drop.index("documents_title", ifExists: true).query
        )
        #expect(dropIndex.sql == #"DROP INDEX IF EXISTS "main"."documents_title""#)
    }
}
