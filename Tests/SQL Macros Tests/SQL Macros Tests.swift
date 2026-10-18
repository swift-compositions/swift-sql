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
                public static var allColumns: [SQL::Column<QueryValue>] {
                  var allColumns: [SQL::Column<QueryValue>] = []
                  allColumns.append(contentsOf: QueryValue.columns.id._columns)
                  return allColumns
                }
                @_optimize(none)
                public static var writableColumns: [SQL::Column<QueryValue>] {
                  var writableColumns: [SQL::Column<QueryValue>] = []
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

    @Test func `a public draft spells its memberwise initializer publicly`() {
        assertMacro {
            """
            @Table
            public struct Reminder {
              public let id: Int
              public let listID: Int
              public var title: String = "Untitled"
              public var notes: String?
              public var priority: Optional<Int>
              public var isCompleted = false
              public var isOverdue: Bool { false }
              public static let limit = 10
            }
            """
        } expansion: {
            #"""
            public struct Reminder {
              @Column("id", primaryKey: true) @SQL_Macros::ColumnCheck(Int.self)
              public let id: Int
              @Column("listID") @SQL_Macros::ColumnCheck(Int.self)
              public let listID: Int
              @Column("title") @SQL_Macros::ColumnCheck(String.self)
              public var title: String = "Untitled"
              @Column("notes") @SQL_Macros::ColumnCheck(String?.self)
              public var notes: String?
              @Column("priority") @SQL_Macros::ColumnCheck(Optional<Int>.self)
              public var priority: Optional<Int>
              @Column("isCompleted") @SQL_Macros::ColumnCheck(Swift.Bool.self)
              public var isCompleted = false
              public var isOverdue: Bool { false }
              public static let limit = 10

              public nonisolated struct TableColumns: SQL::TableDefinition, SQL::PrimaryKeyedTableDefinition {
                public typealias QueryValue = Reminder
                public typealias PrimaryKey = Int
                @SQL_Macros::_ColumnDefinition public var id = SQL::_TableColumn<QueryValue, Int>.for("id", keyPath: \QueryValue.id)
                @SQL_Macros::_PrimaryKeyDefault public var primaryKey = SQL::_TableColumn<QueryValue, Int>.for("id", keyPath: \QueryValue.id)
                @SQL_Macros::_ColumnDefinition public var listID = SQL::_TableColumn<QueryValue, Int>.for("listID", keyPath: \QueryValue.listID)
                @SQL_Macros::_ColumnDefinition public var title = SQL::_TableColumn<QueryValue, String>.for("title", keyPath: \QueryValue.title, default: "Untitled")
                @SQL_Macros::_ColumnDefinition public var notes = SQL::_TableColumn<QueryValue, String?>.for("notes", keyPath: \QueryValue.notes, default: nil)
                @SQL_Macros::_ColumnDefinition public var priority = SQL::_TableColumn<QueryValue, Optional<Int>>.for("priority", keyPath: \QueryValue.priority, default: nil)
                @SQL_Macros::_ColumnDefinition public var isCompleted = SQL::_TableColumn<QueryValue, Swift.Bool>.for("isCompleted", keyPath: \QueryValue.isCompleted, default: false)
                @_optimize(none)
                public static var allColumns: [SQL::Column<QueryValue>] {
                  var allColumns: [SQL::Column<QueryValue>] = []
                  allColumns.append(contentsOf: QueryValue.columns.id._columns)
                  allColumns.append(contentsOf: QueryValue.columns.listID._columns)
                  allColumns.append(contentsOf: QueryValue.columns.title._columns)
                  allColumns.append(contentsOf: QueryValue.columns.notes._columns)
                  allColumns.append(contentsOf: QueryValue.columns.priority._columns)
                  allColumns.append(contentsOf: QueryValue.columns.isCompleted._columns)
                  return allColumns
                }
                @_optimize(none)
                public static var writableColumns: [SQL::Column<QueryValue>] {
                  var writableColumns: [SQL::Column<QueryValue>] = []
                  writableColumns.append(contentsOf: QueryValue.columns.id._writableColumns)
                  writableColumns.append(contentsOf: QueryValue.columns.listID._writableColumns)
                  writableColumns.append(contentsOf: QueryValue.columns.title._writableColumns)
                  writableColumns.append(contentsOf: QueryValue.columns.notes._writableColumns)
                  writableColumns.append(contentsOf: QueryValue.columns.priority._writableColumns)
                  writableColumns.append(contentsOf: QueryValue.columns.isCompleted._writableColumns)
                  return writableColumns
                }
                public var queryFragment: ISO_9075_Foundation::ISO_9075.Fragment {
                  "\(self.id), \(self.listID), \(self.title), \(self.notes), \(self.priority), \(self.isCompleted)"
                }
              }

              public nonisolated struct Selection: SQL::TableExpression {
                public typealias QueryValue = Reminder
                public let allColumns: [ISO_9075_Foundation::ISO_9075.Fragment]
                public init(
                  id: some SQL::QueryExpression<Int>,
                  listID: some SQL::QueryExpression<Int>,
                  title: some SQL::QueryExpression<String> = String(queryOutput: "Untitled"),
                  notes: some SQL::QueryExpression<String?> = Optional<String>(queryOutput: nil),
                  priority: some SQL::QueryExpression<Optional<Int>> = Optional<Int>(queryOutput: nil),
                  isCompleted: some SQL::QueryExpression<Swift.Bool> = Swift.Bool(queryOutput: false)
                ) {
                  var allColumns: [ISO_9075_Foundation::ISO_9075.Fragment] = []
                  allColumns.append(contentsOf: id._allFragments)
                  allColumns.append(contentsOf: listID._allFragments)
                  allColumns.append(contentsOf: title._allFragments)
                  allColumns.append(contentsOf: notes._allFragments)
                  allColumns.append(contentsOf: priority._allFragments)
                  allColumns.append(contentsOf: isCompleted._allFragments)
                  self.allColumns = allColumns
                }
              }

              @_Draft(Reminder.self)
              public struct Draft: SQL::TableDraft, SQL::PartialSelectStatement {
                public typealias SourceTable = Reminder
                public var id: Int?
                public let listID: Int
                public var title: String = "Untitled"
                public var notes: String?
                public var priority: Optional<Int>
                public var isCompleted = false
                public init(
                  id: Int? = nil,
                  listID: Int,
                  title: String = "Untitled",
                  notes: String? = nil,
                  priority: Optional<Int>,
                  isCompleted: Swift.Bool = false
                ) {
                  self.id = id
                  self.listID = listID
                  self.title = title
                  self.notes = notes
                  self.priority = priority
                  self.isCompleted = isCompleted
                }
              }

              public typealias QueryValue = Self

              public typealias From = Swift.Never

              public nonisolated static var columns: TableColumns {
                TableColumns()
              }

              public nonisolated static var _columnWidth: Swift.Int {
                var columnWidth = 0
                columnWidth += Int._columnWidth
                columnWidth += Int._columnWidth
                columnWidth += String._columnWidth
                columnWidth += Optional<String>._columnWidth
                columnWidth += Optional<Int>._columnWidth
                columnWidth += Swift.Bool._columnWidth
                return columnWidth
              }

              public nonisolated static var tableName: Swift.String {
                "reminder"
              }
            }

            nonisolated extension Reminder: SQL::Table, SQL::PrimaryKeyedTable, SQL::PartialSelectStatement {
              public nonisolated init(decoder: inout some SQL::QueryDecoder) throws(SQL::QueryDecodingError) {
                let id = try decoder.decode(Self.columns.id)
                let listID = try decoder.decode(Self.columns.listID)
                let title = try decoder.decode(Self.columns.title)
                self.notes = try decoder.decode(Self.columns.notes)
                self.priority = try decoder.decode(Self.columns.priority)
                let isCompleted = try decoder.decode(Self.columns.isCompleted)
                guard let id else {
                  throw SQL::QueryDecodingError.missingRequiredColumn
                }
                guard let listID else {
                  throw SQL::QueryDecodingError.missingRequiredColumn
                }
                guard let title else {
                  throw SQL::QueryDecodingError.missingRequiredColumn
                }
                guard let isCompleted else {
                  throw SQL::QueryDecodingError.missingRequiredColumn
                }
                self.id = id
                self.listID = listID
                self.title = title
                self.isCompleted = isCompleted
              }
            }
            """#
        }
    }

    @Test func `an internal draft keeps the implicit memberwise initializer`() {
        assertMacro {
            """
            @Table
            struct Reminder {
              let id: Int
              var title = ""
              var notes: String?
            }
            """
        } expansion: {
            #"""
            struct Reminder {
              @Column("id", primaryKey: true) @SQL_Macros::ColumnCheck(Int.self)
              let id: Int
              @Column("title") @SQL_Macros::ColumnCheck(Swift.String.self)
              var title = ""
              @Column("notes") @SQL_Macros::ColumnCheck(String?.self)
              var notes: String?

              public nonisolated struct TableColumns: SQL::TableDefinition, SQL::PrimaryKeyedTableDefinition {
                public typealias QueryValue = Reminder
                public typealias PrimaryKey = Int
                @SQL_Macros::_ColumnDefinition public var id = SQL::_TableColumn<QueryValue, Int>.for("id", keyPath: \QueryValue.id)
                @SQL_Macros::_PrimaryKeyDefault public var primaryKey = SQL::_TableColumn<QueryValue, Int>.for("id", keyPath: \QueryValue.id)
                @SQL_Macros::_ColumnDefinition public var title = SQL::_TableColumn<QueryValue, Swift.String>.for("title", keyPath: \QueryValue.title, default: "")
                @SQL_Macros::_ColumnDefinition public var notes = SQL::_TableColumn<QueryValue, String?>.for("notes", keyPath: \QueryValue.notes, default: nil)
                @_optimize(none)
                public static var allColumns: [SQL::Column<QueryValue>] {
                  var allColumns: [SQL::Column<QueryValue>] = []
                  allColumns.append(contentsOf: QueryValue.columns.id._columns)
                  allColumns.append(contentsOf: QueryValue.columns.title._columns)
                  allColumns.append(contentsOf: QueryValue.columns.notes._columns)
                  return allColumns
                }
                @_optimize(none)
                public static var writableColumns: [SQL::Column<QueryValue>] {
                  var writableColumns: [SQL::Column<QueryValue>] = []
                  writableColumns.append(contentsOf: QueryValue.columns.id._writableColumns)
                  writableColumns.append(contentsOf: QueryValue.columns.title._writableColumns)
                  writableColumns.append(contentsOf: QueryValue.columns.notes._writableColumns)
                  return writableColumns
                }
                public var queryFragment: ISO_9075_Foundation::ISO_9075.Fragment {
                  "\(self.id), \(self.title), \(self.notes)"
                }
              }

              public nonisolated struct Selection: SQL::TableExpression {
                public typealias QueryValue = Reminder
                public let allColumns: [ISO_9075_Foundation::ISO_9075.Fragment]
                public init(
                  id: some SQL::QueryExpression<Int>,
                  title: some SQL::QueryExpression<Swift.String> = Swift.String(queryOutput: ""),
                  notes: some SQL::QueryExpression<String?> = Optional<String>(queryOutput: nil)
                ) {
                  var allColumns: [ISO_9075_Foundation::ISO_9075.Fragment] = []
                  allColumns.append(contentsOf: id._allFragments)
                  allColumns.append(contentsOf: title._allFragments)
                  allColumns.append(contentsOf: notes._allFragments)
                  self.allColumns = allColumns
                }
              }

              @_Draft(Reminder.self)
              struct Draft: SQL::TableDraft, SQL::PartialSelectStatement {
                public typealias SourceTable = Reminder
                var id: Int?
                var title = ""
                var notes: String?
              }

              public typealias QueryValue = Self

              public typealias From = Swift.Never

              public nonisolated static var columns: TableColumns {
                TableColumns()
              }

              public nonisolated static var _columnWidth: Swift.Int {
                var columnWidth = 0
                columnWidth += Int._columnWidth
                columnWidth += Swift.String._columnWidth
                columnWidth += Optional<String>._columnWidth
                return columnWidth
              }

              public nonisolated static var tableName: Swift.String {
                "reminder"
              }
            }

            nonisolated extension Reminder: SQL::Table, SQL::PrimaryKeyedTable, SQL::PartialSelectStatement {
              public nonisolated init(decoder: inout some SQL::QueryDecoder) throws(SQL::QueryDecodingError) {
                let id = try decoder.decode(Self.columns.id)
                let title = try decoder.decode(Self.columns.title)
                self.notes = try decoder.decode(Self.columns.notes)
                guard let id else {
                  throw SQL::QueryDecodingError.missingRequiredColumn
                }
                guard let title else {
                  throw SQL::QueryDecodingError.missingRequiredColumn
                }
                self.id = id
                self.title = title
              }
            }
            """#
        }
    }

    @Test func `a package draft infers literal and optional literal types`() {
        assertMacro {
            """
            @Table
            package struct Counter {
              package var id = 1
              package var label = "count"
              package var ratio = 0.5
              package var isActive = true
            }
            """
        } expansion: {
            #"""
            package struct Counter {
              @Column("id", primaryKey: true) @SQL_Macros::ColumnCheck(Swift.Int.self)
              package var id = 1
              @Column("label") @SQL_Macros::ColumnCheck(Swift.String.self)
              package var label = "count"
              @Column("ratio") @SQL_Macros::ColumnCheck(Swift.Double.self)
              package var ratio = 0.5
              @Column("isActive") @SQL_Macros::ColumnCheck(Swift.Bool.self)
              package var isActive = true

              public nonisolated struct TableColumns: SQL::TableDefinition, SQL::PrimaryKeyedTableDefinition {
                public typealias QueryValue = Counter
                public typealias PrimaryKey = Swift.Int
                @SQL_Macros::_ColumnDefinition public var id = SQL::_TableColumn<QueryValue, Swift.Int>.for("id", keyPath: \QueryValue.id, default: 1)
                @SQL_Macros::_PrimaryKeyDefault public var primaryKey = SQL::_TableColumn<QueryValue, Swift.Int>.for("id", keyPath: \QueryValue.id, default: 1)
                @SQL_Macros::_ColumnDefinition public var label = SQL::_TableColumn<QueryValue, Swift.String>.for("label", keyPath: \QueryValue.label, default: "count")
                @SQL_Macros::_ColumnDefinition public var ratio = SQL::_TableColumn<QueryValue, Swift.Double>.for("ratio", keyPath: \QueryValue.ratio, default: 0.5)
                @SQL_Macros::_ColumnDefinition public var isActive = SQL::_TableColumn<QueryValue, Swift.Bool>.for("isActive", keyPath: \QueryValue.isActive, default: true)
                @_optimize(none)
                public static var allColumns: [SQL::Column<QueryValue>] {
                  var allColumns: [SQL::Column<QueryValue>] = []
                  allColumns.append(contentsOf: QueryValue.columns.id._columns)
                  allColumns.append(contentsOf: QueryValue.columns.label._columns)
                  allColumns.append(contentsOf: QueryValue.columns.ratio._columns)
                  allColumns.append(contentsOf: QueryValue.columns.isActive._columns)
                  return allColumns
                }
                @_optimize(none)
                public static var writableColumns: [SQL::Column<QueryValue>] {
                  var writableColumns: [SQL::Column<QueryValue>] = []
                  writableColumns.append(contentsOf: QueryValue.columns.id._writableColumns)
                  writableColumns.append(contentsOf: QueryValue.columns.label._writableColumns)
                  writableColumns.append(contentsOf: QueryValue.columns.ratio._writableColumns)
                  writableColumns.append(contentsOf: QueryValue.columns.isActive._writableColumns)
                  return writableColumns
                }
                public var queryFragment: ISO_9075_Foundation::ISO_9075.Fragment {
                  "\(self.id), \(self.label), \(self.ratio), \(self.isActive)"
                }
              }

              public nonisolated struct Selection: SQL::TableExpression {
                public typealias QueryValue = Counter
                public let allColumns: [ISO_9075_Foundation::ISO_9075.Fragment]
                public init(
                  id: some SQL::QueryExpression<Swift.Int> = Swift.Int(queryOutput: 1),
                  label: some SQL::QueryExpression<Swift.String> = Swift.String(queryOutput: "count"),
                  ratio: some SQL::QueryExpression<Swift.Double> = Swift.Double(queryOutput: 0.5),
                  isActive: some SQL::QueryExpression<Swift.Bool> = Swift.Bool(queryOutput: true)
                ) {
                  var allColumns: [ISO_9075_Foundation::ISO_9075.Fragment] = []
                  allColumns.append(contentsOf: id._allFragments)
                  allColumns.append(contentsOf: label._allFragments)
                  allColumns.append(contentsOf: ratio._allFragments)
                  allColumns.append(contentsOf: isActive._allFragments)
                  self.allColumns = allColumns
                }
              }

              @_Draft(Counter.self)
              package struct Draft: SQL::TableDraft, SQL::PartialSelectStatement {
                public typealias SourceTable = Counter
                package var id = Optional(1)
                package var label = "count"
                package var ratio = 0.5
                package var isActive = true
                package init(
                  id: Swift.Optional<Swift.Int> = Optional(1),
                  label: Swift.String = "count",
                  ratio: Swift.Double = 0.5,
                  isActive: Swift.Bool = true
                ) {
                  self.id = id
                  self.label = label
                  self.ratio = ratio
                  self.isActive = isActive
                }
              }

              public typealias QueryValue = Self

              public typealias From = Swift.Never

              public nonisolated static var columns: TableColumns {
                TableColumns()
              }

              public nonisolated static var _columnWidth: Swift.Int {
                var columnWidth = 0
                columnWidth += Swift.Int._columnWidth
                columnWidth += Swift.String._columnWidth
                columnWidth += Swift.Double._columnWidth
                columnWidth += Swift.Bool._columnWidth
                return columnWidth
              }

              public nonisolated static var tableName: Swift.String {
                "counter"
              }
            }

            nonisolated extension Counter: SQL::Table, SQL::PrimaryKeyedTable, SQL::PartialSelectStatement {
              public nonisolated init(decoder: inout some SQL::QueryDecoder) throws(SQL::QueryDecodingError) {
                let id = try decoder.decode(Self.columns.id)
                let label = try decoder.decode(Self.columns.label)
                let ratio = try decoder.decode(Self.columns.ratio)
                let isActive = try decoder.decode(Self.columns.isActive)
                guard let id else {
                  throw SQL::QueryDecodingError.missingRequiredColumn
                }
                guard let label else {
                  throw SQL::QueryDecodingError.missingRequiredColumn
                }
                guard let ratio else {
                  throw SQL::QueryDecodingError.missingRequiredColumn
                }
                guard let isActive else {
                  throw SQL::QueryDecodingError.missingRequiredColumn
                }
                self.id = id
                self.label = label
                self.ratio = ratio
                self.isActive = isActive
              }
            }
            """#
        }
    }

    @Test func `a draft with an unspellable property type keeps the implicit initializer`() {
        assertMacro {
            """
            @Table
            public struct Reminder {
              public let id: Int
              public var title = String(repeating: "a", count: 2)
            }
            """
        } expansion: {
            #"""
            public struct Reminder {
              @Column("id", primaryKey: true) @SQL_Macros::ColumnCheck(Int.self)
              public let id: Int
              @Column("title") @SQL_Macros::ColumnCheck(String(repeating: "a", count: 2))
              public var title = String(repeating: "a", count: 2)

              public protocol _$ColumnTypes {
                associatedtype title
                static var titleDefault: title {
                  get
                }
              }

              public nonisolated enum _$ColumnWitness: _$ColumnTypes {
                @SQL_Macros::_ColumnDefault
                public static var titleDefault = String(repeating: "a", count: 2)
              }

              public nonisolated struct TableColumns: SQL::TableDefinition, SQL::PrimaryKeyedTableDefinition {
                public typealias QueryValue = Reminder
                public typealias PrimaryKey = Int
                @SQL_Macros::_ColumnDefinition public var id = SQL::_TableColumn<QueryValue, Int>.for("id", keyPath: \QueryValue.id)
                @SQL_Macros::_PrimaryKeyDefault public var primaryKey = SQL::_TableColumn<QueryValue, Int>.for("id", keyPath: \QueryValue.id)
                @SQL_Macros::_ColumnDefinition public var title = SQL::_TableColumn<QueryValue, _>.for("title", keyPath: \QueryValue.title, default: String(repeating: "a", count: 2))
                @_optimize(none)
                public static var allColumns: [SQL::Column<QueryValue>] {
                  var allColumns: [SQL::Column<QueryValue>] = []
                  allColumns.append(contentsOf: QueryValue.columns.id._columns)
                  allColumns.append(contentsOf: QueryValue.columns.title._columns)
                  return allColumns
                }
                @_optimize(none)
                public static var writableColumns: [SQL::Column<QueryValue>] {
                  var writableColumns: [SQL::Column<QueryValue>] = []
                  writableColumns.append(contentsOf: QueryValue.columns.id._writableColumns)
                  writableColumns.append(contentsOf: QueryValue.columns.title._writableColumns)
                  return writableColumns
                }
                public var queryFragment: ISO_9075_Foundation::ISO_9075.Fragment {
                  "\(self.id), \(self.title)"
                }
              }

              public nonisolated struct Selection: SQL::TableExpression {
                public typealias QueryValue = Reminder
                public let allColumns: [ISO_9075_Foundation::ISO_9075.Fragment]
                public init(
                  id: some SQL::QueryExpression<Int>,
                  title: some SQL::QueryExpression<_$ColumnWitness.title> = _$ColumnWitness.title(queryOutput: String(repeating: "a", count: 2))
                ) {
                  var allColumns: [ISO_9075_Foundation::ISO_9075.Fragment] = []
                  allColumns.append(contentsOf: id._allFragments)
                  allColumns.append(contentsOf: title._allFragments)
                  self.allColumns = allColumns
                }
              }

              @_Draft(Reminder.self)
              public struct Draft: SQL::TableDraft, SQL::PartialSelectStatement {
                public typealias SourceTable = Reminder
                public var id: Int?
                public var title = String(repeating: "a", count: 2)
              }

              public typealias QueryValue = Self

              public typealias From = Swift.Never

              public nonisolated static var columns: TableColumns {
                TableColumns()
              }

              public nonisolated static var _columnWidth: Swift.Int {
                var columnWidth = 0
                columnWidth += Int._columnWidth
                columnWidth += SQL::_columnWidth(\QueryValue.title)
                return columnWidth
              }

              public nonisolated static var tableName: Swift.String {
                "reminder"
              }
            }

            nonisolated extension Reminder: SQL::Table, SQL::PrimaryKeyedTable, SQL::PartialSelectStatement {
              public nonisolated init(decoder: inout some SQL::QueryDecoder) throws(SQL::QueryDecodingError) {
                let id = try decoder.decode(Self.columns.id)
                let title = try decoder.decode(Self.columns.title)
                guard let id else {
                  throw SQL::QueryDecodingError.missingRequiredColumn
                }
                guard let title else {
                  throw SQL::QueryDecodingError.missingRequiredColumn
                }
                self.id = id
                self.title = title
              }
            }
            """#
        }
    }

    @Test func `a public draft with an internal property keeps the implicit initializer`() {
        assertMacro {
            """
            @Table
            public struct Reminder {
              public let id: Int
              var title = ""
            }
            """
        } expansion: {
            #"""
            public struct Reminder {
              @Column("id", primaryKey: true) @SQL_Macros::ColumnCheck(Int.self)
              public let id: Int
              @Column("title") @SQL_Macros::ColumnCheck(Swift.String.self)
              var title = ""

              public nonisolated struct TableColumns: SQL::TableDefinition, SQL::PrimaryKeyedTableDefinition {
                public typealias QueryValue = Reminder
                public typealias PrimaryKey = Int
                @SQL_Macros::_ColumnDefinition public var id = SQL::_TableColumn<QueryValue, Int>.for("id", keyPath: \QueryValue.id)
                @SQL_Macros::_PrimaryKeyDefault public var primaryKey = SQL::_TableColumn<QueryValue, Int>.for("id", keyPath: \QueryValue.id)
                @SQL_Macros::_ColumnDefinition public var title = SQL::_TableColumn<QueryValue, Swift.String>.for("title", keyPath: \QueryValue.title, default: "")
                @_optimize(none)
                public static var allColumns: [SQL::Column<QueryValue>] {
                  var allColumns: [SQL::Column<QueryValue>] = []
                  allColumns.append(contentsOf: QueryValue.columns.id._columns)
                  allColumns.append(contentsOf: QueryValue.columns.title._columns)
                  return allColumns
                }
                @_optimize(none)
                public static var writableColumns: [SQL::Column<QueryValue>] {
                  var writableColumns: [SQL::Column<QueryValue>] = []
                  writableColumns.append(contentsOf: QueryValue.columns.id._writableColumns)
                  writableColumns.append(contentsOf: QueryValue.columns.title._writableColumns)
                  return writableColumns
                }
                public var queryFragment: ISO_9075_Foundation::ISO_9075.Fragment {
                  "\(self.id), \(self.title)"
                }
              }

              public nonisolated struct Selection: SQL::TableExpression {
                public typealias QueryValue = Reminder
                public let allColumns: [ISO_9075_Foundation::ISO_9075.Fragment]
                public init(
                  id: some SQL::QueryExpression<Int>,
                  title: some SQL::QueryExpression<Swift.String> = Swift.String(queryOutput: "")
                ) {
                  var allColumns: [ISO_9075_Foundation::ISO_9075.Fragment] = []
                  allColumns.append(contentsOf: id._allFragments)
                  allColumns.append(contentsOf: title._allFragments)
                  self.allColumns = allColumns
                }
              }

              @_Draft(Reminder.self)
              public struct Draft: SQL::TableDraft, SQL::PartialSelectStatement {
                public typealias SourceTable = Reminder
                public var id: Int?
                var title = ""
              }

              public typealias QueryValue = Self

              public typealias From = Swift.Never

              public nonisolated static var columns: TableColumns {
                TableColumns()
              }

              public nonisolated static var _columnWidth: Swift.Int {
                var columnWidth = 0
                columnWidth += Int._columnWidth
                columnWidth += Swift.String._columnWidth
                return columnWidth
              }

              public nonisolated static var tableName: Swift.String {
                "reminder"
              }
            }

            nonisolated extension Reminder: SQL::Table, SQL::PrimaryKeyedTable, SQL::PartialSelectStatement {
              public nonisolated init(decoder: inout some SQL::QueryDecoder) throws(SQL::QueryDecodingError) {
                let id = try decoder.decode(Self.columns.id)
                let title = try decoder.decode(Self.columns.title)
                guard let id else {
                  throw SQL::QueryDecodingError.missingRequiredColumn
                }
                guard let title else {
                  throw SQL::QueryDecodingError.missingRequiredColumn
                }
                self.id = id
                self.title = title
              }
            }
            """#
        }
    }
}
