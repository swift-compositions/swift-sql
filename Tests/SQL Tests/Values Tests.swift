import InlineSnapshotTesting
import SnapshotTesting
import SQL
import SQL_Macros
import SQL_Test_Support
import Testing

@Suite(.snapshots(record: .missing))
struct `VALUES statements` {
    @Test func `basics`() {
      assertInlineSnapshot(of: Values {
          (1, "Hello", true)
        }, as: .sql) {
          """
          VALUES (1, 'Hello', TRUE)
          """
      }
    }

    @Test func `multiple rows`() {
      assertInlineSnapshot(of: Values {
          (1, "Hello", true)
          (2, "Goodbye", false)
        }, as: .sql) {
          """
          VALUES (1, 'Hello', TRUE), (2, 'Goodbye', FALSE)
          """
      }
    }

    @Test func `control flow`() {
      let includeGoodbye = false
      assertInlineSnapshot(of: Values {
          for n in 1...2 {
            (n, "Hello")
          }
          if includeGoodbye {
            (3, "Goodbye")
          }
        }, as: .sql) {
          """
          VALUES (1, 'Hello'), (2, 'Hello')
          """
      }
    }

    @Test func `single column`() {
      assertInlineSnapshot(of: rows(Values {
          "Hello"
          "Goodbye"
        }), as: .sql) {
          """
          VALUES ('Hello'), ('Goodbye')
          """
      }
    }

    @Test func `union`() {
      assertInlineSnapshot(of: Values {
          (1, "Hello", true)
        }
        .union(
          Values {
            (2, "Goodbye", false)
          }
        ), as: .sql) {
          """
          VALUES (1, 'Hello', TRUE)
            UNION
          VALUES (2, 'Goodbye', FALSE)
          """
      }
    }

    @Test func `select`() {
      assertInlineSnapshot(of: Select(
          Values {
            (1, "Hello", true)
            (2, "Goodbye", false)
          }
        )
        .where(\.2), as: .sql) {
          """
          SELECT "column1", "column2", "column3"
          FROM (
            VALUES (1, 'Hello', TRUE), (2, 'Goodbye', FALSE)
          )
          WHERE ("column3")
          """
      }
    }

    @Test func `select closure`() {
      assertInlineSnapshot(of: Select(
          Values {
            (1, "Hello", true)
            (2, "Goodbye", false)
          }
        )
        .where { $2 }, as: .sql) {
          """
          SELECT "column1", "column2", "column3"
          FROM (
            VALUES (1, 'Hello', TRUE), (2, 'Goodbye', FALSE)
          )
          WHERE ("column3")
          """
      }
    }

    @Test func `select order`() {
      assertInlineSnapshot(of: Select(
          Values {
            (1, "Hello", true)
            (2, "Goodbye", false)
          }
        )
        .order { first, second, _ in (first.desc(), second) }, as: .sql) {
          """
          SELECT "column1", "column2", "column3"
          FROM (
            VALUES (1, 'Hello', TRUE), (2, 'Goodbye', FALSE)
          )
          ORDER BY "column1" DESC, "column2"
          """
      }
    }

    @Test func `select order key path`() {
      assertInlineSnapshot(of: Select(
          Values {
            (2, "Goodbye", false)
            (1, "Hello", true)
          }
        )
        .order(by: \.0), as: .sql) {
          """
          SELECT "column1", "column2", "column3"
          FROM (
            VALUES (2, 'Goodbye', FALSE), (1, 'Hello', TRUE)
          )
          ORDER BY "column1"
          """
      }
    }

    @Test func `select single column`() {
      assertInlineSnapshot(of: Select(
          rows(Values {
            1
            2
          })
        ), as: .sql) {
          """
          SELECT "column1"
          FROM (
            VALUES (1), (2)
          )
          """
      }
    }

    @Test func `selection rows`() {
      assertInlineSnapshot(of: Values {
          HighScore.Columns(score: 100, player: "Blob")
          HighScore.Columns(score: 50, player: "Blob Jr")
        }, as: .sql) {
          """
          VALUES (100, 'Blob'), (50, 'Blob Jr')
          """
      }
    }

    @Test func `select selection rows`() {
      assertInlineSnapshot(of: Select(
          Values {
            HighScore.Columns(score: 100, player: "Blob")
            HighScore.Columns(score: 50, player: "Blob Jr")
          }
        )
        .where { $0.player.eq("Blob") }, as: .sql) {
          """
          SELECT "column1" AS "score", "column2" AS "player"
          FROM (
            VALUES (100, 'Blob'), (50, 'Blob Jr')
          ) AS "highScore"
          WHERE (("player") = ('Blob'))
          """
      }
    }

    @Test func `mixed rows`() {
      assertInlineSnapshot(of: Values {
          (1, HighScore.Columns(score: 100, player: "Blob"), true)
          (2, HighScore.Columns(score: 50, player: "Blob Jr"), false)
        }, as: .sql) {
          """
          VALUES (1, 100, 'Blob', TRUE), (2, 50, 'Blob Jr', FALSE)
          """
      }
    }

    @Test func `select mixed rows`() {
      assertInlineSnapshot(of: Select(
          Values {
            (1, HighScore.Columns(score: 100, player: "Blob"), true)
            (2, HighScore.Columns(score: 50, player: "Blob Jr"), false)
          }
        )
        .where(\.2)
        .order(by: \.1.score), as: .sql) {
          """
          SELECT "column1", "column2" AS "score", "column3" AS "player", "column4"
          FROM (
            VALUES (1, 100, 'Blob', TRUE), (2, 50, 'Blob Jr', FALSE)
          )
          WHERE ("column4")
          ORDER BY "score"
          """
      }
    }

    @Test func `select mixed rows positional`() {
      assertInlineSnapshot(of: Select(
          Values {
            (1, HighScore.Columns(score: 100, player: "Blob"), true)
            (2, HighScore.Columns(score: 50, player: "Blob Jr"), false)
          }
        )
        .where { _, _, flag in flag }
        .order { _, highScore, _ in highScore.player }, as: .sql) {
          """
          SELECT "column1", "column2" AS "score", "column3" AS "player", "column4"
          FROM (
            VALUES (1, 100, 'Blob', TRUE), (2, 50, 'Blob Jr', FALSE)
          )
          WHERE ("column4")
          ORDER BY "player"
          """
      }
    }

    @Test func `select mixed rows multi key order`() {
      assertInlineSnapshot(of: Select(
          Values {
            (1, HighScore.Columns(score: 100, player: "Blob"), true)
            (2, HighScore.Columns(score: 50, player: "Blob Jr"), false)
          }
        )
        .order { _, highScore, _ in highScore }, as: .sql) {
          """
          SELECT "column1", "column2" AS "score", "column3" AS "player", "column4"
          FROM (
            VALUES (1, 100, 'Blob', TRUE), (2, 50, 'Blob Jr', FALSE)
          )
          ORDER BY "score", "player"
          """
      }
    }

    @Test func `select control flow selection rows`() {
      assertInlineSnapshot(of: Select(
          Values {
            for score in [100, 50] {
              HighScore.Columns(score: score, player: "Blob \(score)")
            }
          }
        ), as: .sql) {
          """
          SELECT "column1" AS "score", "column2" AS "player"
          FROM (
            VALUES (100, 'Blob 100'), (50, 'Blob 50')
          ) AS "highScore"
          """
      }
    }

    @Test func `selection common table expression`() {
      assertInlineSnapshot(of: With {
          Select(
            Values {
              HighScore.Columns(score: 100, player: "Blob")
              HighScore.Columns(score: 50, player: "Blob Jr")
            }
          )
        } query: {
          HighScore.all
        }, as: .sql) {
          """
          WITH "highScore" AS (
            SELECT "column1" AS "score", "column2" AS "player"
            FROM (
              VALUES (100, 'Blob'), (50, 'Blob Jr')
            ) AS "highScore"
          )
          SELECT "highScore"."score", "highScore"."player"
          FROM "highScore"
          """
      }
    }

    @Test func `insert select`() {
      assertInlineSnapshot(of: Tag.insert {
          $0.title
        } select: {
          Select(Values { "vacation" })
        }, as: .sql) {
          """
          INSERT INTO "tags"
          ("title")
          SELECT "column1"
          FROM (
            VALUES ('vacation')
          )
          """
      }
    }

    @Test func `select order positional`() {
      assertInlineSnapshot(of: Select(
          Values {
            (2, "Goodbye", false)
            (1, "Hello", true)
          }
        )
        .order { first, _, _ in first }, as: .sql) {
          """
          SELECT "column1", "column2", "column3"
          FROM (
            VALUES (2, 'Goodbye', FALSE), (1, 'Hello', TRUE)
          )
          ORDER BY "column1"
          """
      }
    }
}

@Table
private struct Player {
    var name = ""
    var highScore: HighScore = HighScore(score: 0, player: "")
}

@Selection
private struct HighScore {
    let score: Int
    let player: String
}

@Table("tags")
private struct Tag {
    let id: Int
    var title = ""
}

private func rows<each V: QueryRepresentable, S: Statement<(repeat each V)>>(_ statement: S) -> S {
    statement
}
