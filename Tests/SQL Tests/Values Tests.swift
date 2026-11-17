import SQL
import SQL_Macros
import SQL_Test_Support
import Testing
import Tests_Apple_Testing_Bridge
import Tests_Inline_Snapshot

enum `Values Tests` {}

extension `Values Tests` {
    @Suite(.snapshots(record: .missing))
    struct `VALUES statements` {
        @Test func `basics`() {
            snapshot(as: .sql) {
                Values {
                    (1, "Hello", true)
                }
            } matches: {
                """
                VALUES (1, 'Hello', TRUE)
                """
            }
        }

        @Test func `multiple rows`() {
            snapshot(as: .sql) {
                Values {
                    (1, "Hello", true)
                    (2, "Goodbye", false)
                }
            } matches: {
                """
                VALUES (1, 'Hello', TRUE), (2, 'Goodbye', FALSE)
                """
            }
        }

        @Test func `control flow`() {
            let includeGoodbye = false
            snapshot(as: .sql) {
                Values {
                    for n in 1...2 {
                        (n, "Hello")
                    }
                    if includeGoodbye {
                        (3, "Goodbye")
                    }
                }
            } matches: {
                """
                VALUES (1, 'Hello'), (2, 'Hello')
                """
            }
        }

        @Test func `single column`() {
            snapshot(as: .sql) {
                rows(
                    Values {
                        "Hello"
                        "Goodbye"
                    }
                )
            } matches: {
                """
                VALUES ('Hello'), ('Goodbye')
                """
            }
        }

        @Test func `union`() {
            snapshot(as: .sql) {
                Values {
                    (1, "Hello", true)
                }
                .union(
                    Values {
                        (2, "Goodbye", false)
                    }
                )
            } matches: {
                """
                VALUES (1, 'Hello', TRUE)
                  UNION
                VALUES (2, 'Goodbye', FALSE)
                """
            }
        }

        @Test func `select`() {
            snapshot(as: .sql) {
                Select(
                    Values {
                        (1, "Hello", true)
                        (2, "Goodbye", false)
                    }
                )
                .where(\.2)
            } matches: {
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
            snapshot(as: .sql) {
                Select(
                    Values {
                        (1, "Hello", true)
                        (2, "Goodbye", false)
                    }
                )
                .where { $2 }
            } matches: {
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
            snapshot(as: .sql) {
                Select(
                    Values {
                        (1, "Hello", true)
                        (2, "Goodbye", false)
                    }
                )
                .order { first, second, _ in (first.desc(), second) }
            } matches: {
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
            snapshot(as: .sql) {
                Select(
                    Values {
                        (2, "Goodbye", false)
                        (1, "Hello", true)
                    }
                )
                .order(by: \.0)
            } matches: {
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
            snapshot(as: .sql) {
                Select(
                    rows(
                        Values {
                            1
                            2
                        }
                    )
                )
            } matches: {
                """
                SELECT "column1"
                FROM (
                  VALUES (1), (2)
                )
                """
            }
        }

        @Test func `selection rows`() {
            snapshot(as: .sql) {
                Values {
                    HighScore.Columns(score: 100, player: "Blob")
                    HighScore.Columns(score: 50, player: "Blob Jr")
                }
            } matches: {
                """
                VALUES (100, 'Blob'), (50, 'Blob Jr')
                """
            }
        }

        @Test func `select selection rows`() {
            snapshot(as: .sql) {
                Select(
                    Values {
                        HighScore.Columns(score: 100, player: "Blob")
                        HighScore.Columns(score: 50, player: "Blob Jr")
                    }
                )
                .where { $0.player.eq("Blob") }
            } matches: {
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
            snapshot(as: .sql) {
                Values {
                    (1, HighScore.Columns(score: 100, player: "Blob"), true)
                    (2, HighScore.Columns(score: 50, player: "Blob Jr"), false)
                }
            } matches: {
                """
                VALUES (1, 100, 'Blob', TRUE), (2, 50, 'Blob Jr', FALSE)
                """
            }
        }

        @Test func `select mixed rows`() {
            snapshot(as: .sql) {
                Select(
                    Values {
                        (1, HighScore.Columns(score: 100, player: "Blob"), true)
                        (2, HighScore.Columns(score: 50, player: "Blob Jr"), false)
                    }
                )
                .where(\.2)
                .order(by: \.1.score)
            } matches: {
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
            snapshot(as: .sql) {
                Select(
                    Values {
                        (1, HighScore.Columns(score: 100, player: "Blob"), true)
                        (2, HighScore.Columns(score: 50, player: "Blob Jr"), false)
                    }
                )
                .where { _, _, flag in flag }
                .order { _, highScore, _ in highScore.player }
            } matches: {
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
            snapshot(as: .sql) {
                Select(
                    Values {
                        (1, HighScore.Columns(score: 100, player: "Blob"), true)
                        (2, HighScore.Columns(score: 50, player: "Blob Jr"), false)
                    }
                )
                .order { _, highScore, _ in highScore }
            } matches: {
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
            snapshot(as: .sql) {
                Select(
                    Values {
                        for score in [100, 50] {
                            HighScore.Columns(score: score, player: "Blob \(score)")
                        }
                    }
                )
            } matches: {
                """
                SELECT "column1" AS "score", "column2" AS "player"
                FROM (
                  VALUES (100, 'Blob 100'), (50, 'Blob 50')
                ) AS "highScore"
                """
            }
        }

        @Test func `selection common table expression`() {
            snapshot(as: .sql) {
                With {
                    Select(
                        Values {
                            HighScore.Columns(score: 100, player: "Blob")
                            HighScore.Columns(score: 50, player: "Blob Jr")
                        }
                    )
                } query: {
                    HighScore.all
                }
            } matches: {
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
            snapshot(as: .sql) {
                Tag.insert {
                    $0.title
                } select: {
                    Select(Values { "vacation" })
                }
            } matches: {
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
            snapshot(as: .sql) {
                Select(
                    Values {
                        (2, "Goodbye", false)
                        (1, "Hello", true)
                    }
                )
                .order { first, _, _ in first }
            } matches: {
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
