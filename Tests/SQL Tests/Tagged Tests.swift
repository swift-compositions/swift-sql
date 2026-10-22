#if Tagged
    import ISO_9075_Foundation
    import SQL
    import SQL_Macros
    import Testing

    private enum Identifier {}

    @Table
    private struct Record {
        let id: Tagged<Identifier, Int>
        let legacyID: Int
    }

    @Suite struct `Tagged expressions` {
        @Test func `untag compares a tagged column with a raw column`() {
            let query = Record.where { $0.id.untag.eq($0.legacyID) }

            #expect(
                Numbered().render(query.query).sql.contains(
                    #"(("record"."id") = ("record"."legacyID"))"#
                )
            )
        }

        @Test func `untag compares a tagged column with a raw value`() {
            let query = Record.where { $0.id.untag.eq(42) }
            let rendering = Numbered().render(query.query)

            #expect(rendering.sql.contains(#"(("record"."id") = ($1))"#))
            #expect(rendering.values == [.int(42)])
        }
    }
#endif
