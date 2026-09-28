public import ISO_9075_Foundation
import Standard_Library_Extensions

public protocol AliasName {
    static var aliasName: String { get }
}

extension AliasName {
    public static var aliasName: String {
        _typeName(Self.self, qualified: false).lowercasingLeadingUppercase
    }
}

extension Table {
    public static func `as`<Name: AliasName>(_ aliasName: Name.Type) -> TableAlias<Self, Name>.Type
    {
        TableAlias.self
    }
}

public struct TableAlias<
    Base,
    Name: AliasName  // We should use a value generic here when it's possible.
>: _OptionalPromotable {
    let base: Base

    package subscript<Member: QueryRepresentable>(
        member _: KeyPath<Member, Member>,
        column keyPath: KeyPath<Base, Member.QueryOutput>
    ) -> Member.QueryOutput {
        base[keyPath: keyPath]
    }
}

extension TableAlias: Table, PartialSelectStatement, Statement where Base: Table {
    public typealias Draft = TableAlias<Base.Draft, Name>

    public static var columns: TableColumns {
        TableColumns()
    }

    public static var tableName: String {
        Base.tableName
    }

    public static var tableAlias: String? {
        Name.aliasName
    }

    public static var all: SelectOf<Self> {
        Base.all.as(Name.self)
    }

    @dynamicMemberLookup
    public struct TableColumns: Sendable, TableDefinition {
        public typealias QueryValue = TableAlias

        public static var allColumns: [Column<TableAlias>] {
            Base.TableColumns.allColumns.map { $0.aliased(Name.self) }
        }

        public static var writableColumns: [Column<TableAlias>] {
            Base.TableColumns.writableColumns.map { $0.aliased(Name.self) }
        }

        public subscript<Member>(
            dynamicMember keyPath: KeyPath<Base.TableColumns, TableColumn<Base, Member>>
        ) -> TableColumn<TableAlias, Member> {
            let column = Base.columns[keyPath: keyPath]
            return TableColumn<TableAlias, Member>(
                column.name,
                keyPath: \.[member: \Member.self, column: column.keyPath]
            )
        }

        public subscript<Member>(
            dynamicMember keyPath: KeyPath<Base.TableColumns, GeneratedColumn<Base, Member>>
        ) -> GeneratedColumn<TableAlias, Member> {
            let column = Base.columns[keyPath: keyPath]
            return GeneratedColumn<TableAlias, Member>(
                column.name,
                keyPath: \.[member: \Member.self, column: column.keyPath]
            )
        }

        public subscript<Member>(
            dynamicMember keyPath: KeyPath<Base.TableColumns, ColumnGroup<Base, Member>>
        ) -> ColumnGroup<TableAlias, Member> {
            let column = Base.columns[keyPath: keyPath]
            return ColumnGroup<TableAlias, Member>(
                column.name,
                keyPath: \.[member: \Member.self, column: column.keyPath]
            )
        }

        public subscript<Member>(
            dynamicMember keyPath: KeyPath<Base.TableColumns, OptionalColumnGroup<Base, Member>>
        ) -> OptionalColumnGroup<TableAlias, Member> {
            let column = Base.columns[keyPath: keyPath]
            return OptionalColumnGroup(
                base: ColumnGroup<TableAlias, Member?>(
                    column.name,
                    keyPath: \.[member: \Member?.self, column: column.keyPath]
                )
            )
        }
    }

    public struct Selection: TableExpression {
        public typealias QueryValue = TableAlias

        fileprivate var base: Base.Selection

        public init(_ base: Base.Selection) {
            self.base = base
        }

        public var allColumns: [ISO_9075.Fragment] {
            base.allColumns
        }
    }
}

extension TableAlias: _Selection where Base: _Selection {}

extension TableAlias: PrimaryKeyedTable where Base: PrimaryKeyedTable {}

extension TableAlias: TableDraft where Base: TableDraft {
    public typealias SourceTable = TableAlias<Base.SourceTable, Name>
    public init(_ primaryTable: TableAlias<Base.SourceTable, Name>) {
        self.init(base: Base(primaryTable.base))
    }
}

extension TableAlias.TableColumns: PrimaryKeyedTableDefinition
where Base.TableColumns: PrimaryKeyedTableDefinition {
    public typealias PrimaryKey = Base.PrimaryKey

    public struct PrimaryColumn: _TableColumnExpression {
        public typealias Root = TableAlias

        public typealias Value = Base.PrimaryKey

        public var _names: [String] {
            Base.columns.primaryKey._names
        }

        public var defaultValue: Base.PrimaryKey.QueryOutput? {
            Base.columns.primaryKey.defaultValue
        }

        public var keyPath: KeyPath<TableAlias, Base.PrimaryKey.QueryOutput> {
            \.[member: \Base.PrimaryKey.self, column: Base.columns.primaryKey.keyPath]
        }

        public var queryFragment: ISO_9075.Fragment {
            Base.columns.primaryKey._names
                .map { "\(TableAlias.self).\(quote: $0)" }
                .joined(separator: ", ")
        }
    }

    public var primaryKey: PrimaryColumn {
        PrimaryColumn()
    }
}

extension TableAlias.TableColumns.PrimaryColumn: TableColumnExpression
where Base.TableColumns.PrimaryColumn: TableColumnExpression {
    public var name: String {
        Base.columns.primaryKey.name
    }

}

extension TableAlias.TableColumns.PrimaryColumn: WritableTableColumnExpression
where Base.TableColumns.PrimaryColumn: WritableTableColumnExpression {}

extension TableAlias: QueryExpression where Base: QueryExpression {
    public typealias QueryValue = Self

    public var queryFragment: ISO_9075.Fragment {
        base.queryFragment
    }

    public static var _columnWidth: Int {
        Base._columnWidth
    }

    public var _allFragments: [ISO_9075.Fragment] {
        base._allFragments
    }
}

extension TableAlias: QueryBindable where Base: QueryBindable {
    public var queryBinding: ISO_9075.Value {
        base.queryBinding
    }
}

extension TableAlias: QueryDecodable where Base: QueryDecodable {
    public init(decoder: inout some QueryDecoder) throws(QueryDecodingError) {
        try self.init(base: Base(decoder: &decoder))
    }
}

extension TableAlias: QueryRepresentable where Base: QueryRepresentable {
    public typealias QueryOutput = Base.QueryOutput

    public init(queryOutput: Base.QueryOutput) {
        self.init(base: Base(queryOutput: queryOutput))
    }

    public var queryOutput: Base.QueryOutput {
        base.queryOutput
    }
}

extension TableAlias: Sendable where Base: Sendable {}

extension TableAlias: Equatable where Base: Equatable {}

extension TableAlias: Hashable where Base: Hashable {}

extension TableAlias: Decodable where Base: Decodable {
    public init(from decoder: any Decoder) throws {
        do {
            self.init(base: try decoder.singleValueContainer().decode(Base.self))
        } catch {
            self.init(base: try Base(from: decoder))
        }
    }
}

extension TableAlias: Encodable where Base: Encodable {
    public func encode(to encoder: any Encoder) throws {
        do {
            var container = encoder.singleValueContainer()
            try container.encode(self.base)
        } catch {
            try self.base.encode(to: encoder)
        }
    }
}

extension ISO_9075.Fragment {
    package func aliasing<T: Table, Name: AliasName>(
        _ table: T.Type,
        as alias: Name.Type
    ) -> ISO_9075.Fragment {
        var query = self
        let key = ObjectIdentifier(T.self)
        for index in query.segments.indices {
            guard
                case .identifier(let identifier) = query.segments[index],
                identifier.key == key
            else { continue }
            query.segments[index] = .identifier(
                ISO_9075.Identifier(Name.aliasName, key: ObjectIdentifier(TableAlias<T, Name>.self))
            )
        }
        return query
    }
}
