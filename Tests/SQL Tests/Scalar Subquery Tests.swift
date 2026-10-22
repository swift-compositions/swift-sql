import ISO_9075_Foundation
import SQL
import SQL_Macros
import Testing

@Table
private struct Metric {
    let id: Int
    var value: Int?
}

extension Metric {
    @Suite struct `Scalar subquery comparison` {
        @Test func `an optional column equals a selected maximum`() {
            let maximum = Metric.select { $0.value.max() }
            let query = Metric.where { $0.value.eq(maximum) }.select(\.id)
            let sql = Numbered().render(query.query).sql

            #expect(sql.contains(#"("metric"."value") = (("#))
            #expect(sql.contains(#"SELECT max("metric"."value")"#))
        }
    }
}
