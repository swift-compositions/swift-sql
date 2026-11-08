public import ISO_9075_Foundation

public struct Seed {
    let table: ObjectIdentifier
    let row: [ISO_9075.Fragment]
    let insert: ([[ISO_9075.Fragment]]) -> SQLQueryExpression<Void>

    init<T: Table>(_ row: T) {
        self.table = ObjectIdentifier(T.self)
        self.row = T.TableColumns.writableColumns.map { $0.render(row) }
        self.insert = { rows in
            SQLQueryExpression(T._insert(columnNames: T.TableColumns.writableColumns.map(\.name), rows: rows))
        }
    }

    init<T: TableDraft>(draft row: T, primaryKeys: Set<String> = []) {
        self.table = ObjectIdentifier(T.self)
        self.row = T.TableColumns.writableColumns.map { $0.rendering(row, primaryKeys: primaryKeys) }
        self.insert = { rows in
            SQLQueryExpression(
                T.SourceTable._insert(columnNames: T.TableColumns.writableColumns.map(\.name), rows: rows)
            )
        }
    }
}
