public import Byte
public import ISO_9075_Foundation

public protocol _OptionalProtocol<Wrapped> {
    associatedtype Wrapped
    var _wrapped: Wrapped? { get }
    static var _none: Self { get }
    static func _some(_ wrapped: Wrapped) -> Self
}

extension Optional: _OptionalProtocol {
    public var _wrapped: Wrapped? { self }
    public static var _none: Self { .none }
    public static func _some(_ wrapped: Wrapped) -> Self { .some(wrapped) }
}

public protocol _OptionalPromotable<_Optionalized> {
    associatedtype _Optionalized: _OptionalProtocol = Self?
}

extension Optional: _OptionalPromotable {
    public typealias _Optionalized = Self
}

extension [Byte]: _OptionalPromotable {}

extension Optional: QueryBindable where Wrapped: QueryBindable {
    public typealias QueryValue = Wrapped.QueryValue?

    public var queryBinding: ISO_9075.Value {
        self?.queryBinding ?? .null
    }
}

extension Optional: QueryDecodable where Wrapped: QueryDecodable {
    @inlinable
    public init(decoder: inout some QueryDecoder) throws(QueryDecodingError) {
        do {
            self = try Wrapped(decoder: &decoder)
        } catch QueryDecodingError.missingRequiredColumn {
            self = nil
        }
    }
}

extension Optional: QueryExpression where Wrapped: QueryExpression {
    public typealias QueryValue = Wrapped.QueryValue?

    public var queryFragment: ISO_9075.Fragment {
        _allFragments.joined(separator: ", ")
    }

    public static var _columnWidth: Int {
        Wrapped._columnWidth
    }

    public var _allFragments: [ISO_9075.Fragment] {
        self?._allFragments ?? Array(repeating: "NULL", count: Self._columnWidth)
    }
}

extension Optional: QueryRepresentable where Wrapped: QueryRepresentable {
    public typealias QueryOutput = Wrapped.QueryOutput?

    @inlinable
    public init(queryOutput: Wrapped.QueryOutput?) {
        if let queryOutput {
            self = Wrapped(queryOutput: queryOutput)
        } else {
            self = nil
        }
    }

    @inlinable
    public var queryOutput: Wrapped.QueryOutput? {
        self?.queryOutput
    }

    @inlinable
    public static func queryFragment(decoding queryFragment: ISO_9075.Fragment) -> ISO_9075.Fragment {
        Wrapped.queryFragment(decoding: queryFragment)
    }

    public static func _queryFragment(jsonEncoding queryFragment: ISO_9075.Fragment) -> ISO_9075.Fragment {
        Wrapped._queryFragment(jsonEncoding: queryFragment)
    }

    public static func _queryFragment(jsonDecoding queryFragment: ISO_9075.Fragment) -> ISO_9075.Fragment {
        Wrapped._queryFragment(jsonDecoding: queryFragment)
    }


}

extension Optional: Table, PartialSelectStatement, Statement where Wrapped: Table {
    public typealias Draft = Wrapped.Draft?

    public static var tableName: String {
        Wrapped.tableName
    }

    public static var tableAlias: String? {
        Wrapped.tableAlias
    }

    public static var columns: TableColumns {
        TableColumns()
    }

    subscript<Member: QueryRepresentable>(
        member _: KeyPath<Member, Member>,
        column keyPath: KeyPath<Wrapped, Member.QueryOutput>
    ) -> Member.QueryOutput? {
        self?[keyPath: keyPath]
    }

    @dynamicMemberLookup
    public struct TableColumns: TableDefinition {
        public typealias QueryValue = Optional

        public static var allColumns: [Column<Optional>] {
            Wrapped.TableColumns.allColumns.map(\.optional)
        }

        public static var writableColumns: [Column<Optional>] {
            Wrapped.TableColumns.writableColumns.map(\.optional)
        }

        public subscript<Member>(
            dynamicMember keyPath: KeyPath<Wrapped.TableColumns, TableColumn<Wrapped, Member>>
        ) -> TableColumn<Optional, Member?> {
            let column = Wrapped.columns[keyPath: keyPath]
            return TableColumn<Optional, Member?>(
                column.name,
                keyPath: \.[member: \Member.self, column: column.keyPath]
            )
        }

        public subscript<Member>(
            dynamicMember keyPath: KeyPath<Wrapped.TableColumns, GeneratedColumn<Wrapped, Member>>
        ) -> GeneratedColumn<Optional, Member?> {
            let column = Wrapped.columns[keyPath: keyPath]
            return GeneratedColumn<Optional, Member?>(
                column.name,
                keyPath: \.[member: \Member.self, column: column.keyPath]
            )
        }

        public subscript<Member>(
            dynamicMember keyPath: KeyPath<Wrapped.TableColumns, ColumnGroup<Wrapped, Member>>
        ) -> OptionalColumnGroup<Optional, Member> {
            let column = Wrapped.columns[keyPath: keyPath]
            return OptionalColumnGroup(
                base: ColumnGroup<Optional, Member?>(
                    column.groupName,
                    keyPath: \.[member: \Member.self, column: column.keyPath]
                )
            )
        }

        public subscript<Member>(
            dynamicMember keyPath: KeyPath<
                Wrapped.TableColumns, OptionalColumnGroup<Wrapped, Member>
            >
        ) -> OptionalColumnGroup<Optional, Member> {
            let column = Wrapped.columns[keyPath: keyPath]
            return OptionalColumnGroup(
                base: ColumnGroup<Optional, Member?>(
                    column.groupName,
                    keyPath: \.[flattenedMember: \Member.self, column: column.keyPath]
                )
            )
        }

        #if CasePaths
            public subscript<Member>(
                dynamicMember keyPath: KeyPath<Wrapped.TableColumns, CaseColumn<Wrapped, Member>>
            ) -> TableColumn<Optional, Member??> {
                let column = Wrapped.columns[keyPath: keyPath].base
                return TableColumn<Optional, Member??>(
                    column.name,
                    keyPath: \.[member: \Member?.self, column: column.keyPath]
                )
            }

            public subscript<Member>(
                dynamicMember keyPath: KeyPath<
                    Wrapped.TableColumns, CaseColumnGroup<Wrapped, Member>
                >
            ) -> ColumnGroup<Optional, Member??> {
                let column = Wrapped.columns[keyPath: keyPath].base
                return ColumnGroup<Optional, Member??>(
                    column.name,
                    keyPath: \.[member: \Member?.self, column: column.keyPath]
                )
            }
        #endif

        public subscript<Member: QueryExpression>(
            dynamicMember keyPath: KeyPath<Wrapped.TableColumns, Member>
        ) -> some QueryExpression<Member.QueryValue?> {
            Member?.some(Wrapped.columns[keyPath: keyPath])
        }

        @_disfavoredOverload
        public subscript<QueryValue>(
            dynamicMember keyPath: KeyPath<Wrapped.TableColumns, some QueryExpression<QueryValue?>>
        ) -> some QueryExpression<QueryValue?> {
            Wrapped.columns[keyPath: keyPath]
        }
    }

    public typealias Selection = Wrapped.Selection?
}

extension Optional: _Selection where Wrapped: _Selection {}

extension Optional: PrimaryKeyedTable where Wrapped: PrimaryKeyedTable {}

extension Optional: TableDraft where Wrapped: TableDraft {
    public typealias SourceTable = Wrapped.SourceTable?
    public init(_ primaryTable: Wrapped.SourceTable?) {
        self = primaryTable.map(Wrapped.init)
    }
}

extension Optional.TableColumns: PrimaryKeyedTableDefinition
where Wrapped.TableColumns: PrimaryKeyedTableDefinition {
    public typealias PrimaryKey = Wrapped.PrimaryKey?

    public struct PrimaryColumn: _TableColumnExpression {
        public typealias Root = Optional

        public typealias Value = Wrapped.PrimaryKey?

        public var _names: [String] {
            Wrapped.columns.primaryKey._names
        }

        public var defaultValue: Wrapped.PrimaryKey.QueryOutput?? {
            Wrapped.columns.primaryKey.defaultValue
        }

        public var keyPath: KeyPath<Wrapped?, Wrapped.PrimaryKey.QueryOutput?> {
            \.[member: \Wrapped.PrimaryKey.self, column: Wrapped.columns.primaryKey.keyPath]
        }

        public var queryFragment: ISO_9075.Fragment {
            Wrapped.columns.primaryKey.queryFragment
        }
    }

    public var primaryKey: PrimaryColumn {
        PrimaryColumn()
    }
}

extension Optional.TableColumns.PrimaryColumn: TableColumnExpression
where Wrapped.TableColumns.PrimaryColumn: TableColumnExpression {
    public var name: String {
        Wrapped.columns.primaryKey.name
    }

}

extension Optional.TableColumns.PrimaryColumn: WritableTableColumnExpression
where Wrapped.TableColumns.PrimaryColumn: WritableTableColumnExpression {}

extension Optional: TableExpression where Wrapped: TableExpression {
    public var allColumns: [ISO_9075.Fragment] {
        self?.allColumns
            ?? Wrapped.QueryValue.TableColumns.allColumns.map { "NULL AS \(quote: $0.name)" }
    }
}

extension QueryExpression where QueryValue: _OptionalProtocol {
    public func map<T>(
        _ transform: (_UnwrapExpression<Self>) -> some QueryExpression<T>
    ) -> some QueryExpression<T?>
    where QueryValue: QueryRepresentable & QueryExpression {
        Case(self.is(nil))
            .when(SQLQueryExpression("1"), then: SQLQueryExpression("NULL"))
            .else(SQLQueryExpression(transform(_UnwrapExpression(base: self)).queryFragment))
    }

    public func flatMap<T>(
        _ transform: (_UnwrapExpression<Self>) -> some QueryExpression<T?>
    ) -> some QueryExpression<T?> {
        SQLQueryExpression(transform(_UnwrapExpression(base: self)).queryFragment)
    }
}

public struct _UnwrapExpression<Base: QueryExpression>: QueryExpression
where Base.QueryValue: _OptionalProtocol {
    public typealias QueryValue = Base.QueryValue.Wrapped

    let base: Base

    public var queryFragment: ISO_9075.Fragment { base.queryFragment }
}
