import MacroTesting
import SnapshotTesting
import SQL_Macros_Implementation
import Testing

@Suite(.macros([TableMacro.self], record: .missing))
struct `Table macro` {
    @Test func `a table names its columns through SQL module selectors`() {
        assertMacro {
            """
            @Table
            struct Reminder {
              let id: Int
            }
            """
        } expansion: {
            #"""
            struct Reminder {
              @Column("id", primaryKey: true) @SQL_Macros::ColumnCheck(Int.self)
              let id: Int

              public nonisolated struct TableColumns: SQL::TableDefinition, SQL::PrimaryKeyedTableDefinition {
                public typealias QueryValue = Reminder
                public typealias PrimaryKey = Int
                @SQL_Macros::_ColumnDefinition public var id = SQL::_TableColumn<QueryValue, Int>.for("id", keyPath: \QueryValue.id)
                @SQL_Macros::_PrimaryKeyDefault public var primaryKey = SQL::_TableColumn<QueryValue, Int>.for("id", keyPath: \QueryValue.id)
                @_optimize(none)
                public static var allColumns: [any SQL::TableColumnExpression] {
                  var allColumns: [any SQL::TableColumnExpression] = []
                  allColumns.append(contentsOf: QueryValue.columns.id._allColumns)
                  return allColumns
                }
                @_optimize(none)
                public static var writableColumns: [any SQL::WritableTableColumnExpression] {
                  var writableColumns: [any SQL::WritableTableColumnExpression] = []
                  writableColumns.append(contentsOf: QueryValue.columns.id._writableColumns)
                  return writableColumns
                }
                public var queryFragment: ISO_9075_Foundation::ISO_9075.Fragment {
                  "\(self.id)"
                }
              }

              public nonisolated struct Selection: SQL::TableExpression {
                public typealias QueryValue = Reminder
                public let allColumns: [ISO_9075_Foundation::ISO_9075.Fragment]
                public init(
                  id: some SQL::QueryExpression<Int>
                ) {
                  var allColumns: [ISO_9075_Foundation::ISO_9075.Fragment] = []
                  allColumns.append(contentsOf: id._allFragments)
                  self.allColumns = allColumns
                }
              }

              @_Draft(Reminder.self)
              struct Draft: SQL::TableDraft, SQL::PartialSelectStatement {
                public typealias SourceTable = Reminder
                var id: Int?
              }

              public typealias QueryValue = Self

              public typealias From = Swift.Never

              public nonisolated static var columns: TableColumns {
                TableColumns()
              }

              public nonisolated static var _columnWidth: Swift.Int {
                var columnWidth = 0
                columnWidth += Int._columnWidth
                return columnWidth
              }

              public nonisolated static var tableName: Swift.String {
                "reminder"
              }
            }

            nonisolated extension Reminder: SQL::Table, SQL::PrimaryKeyedTable, SQL::PartialSelectStatement {
              public nonisolated init(decoder: inout some SQL::QueryDecoder) throws(SQL::QueryDecodingError) {
                let id = try decoder.decode(Self.columns.id)
                guard let id else {
                  throw SQL::QueryDecodingError.missingRequiredColumn
                }
                self.id = id
              }
            }
            """#
        }
    }
}
