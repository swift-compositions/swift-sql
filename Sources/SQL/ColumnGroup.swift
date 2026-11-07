public import ISO_9075_Foundation

@dynamicMemberLookup
public struct ColumnGroup<Root: Table, Values: Table>: _TableColumnExpression
where Values.QueryOutput: Table {
    public typealias Value = Values

    public var _names: [String] { Values.TableColumns.allColumns.map(\.name) }

    public typealias QueryValue = Values

    public let groupName: String

    private let _defaultValue: () -> Values.QueryOutput?

    private let _keyPath: () -> KeyPath<Root, Values.QueryOutput>

    public var defaultValue: Values.QueryOutput? { _defaultValue() }

    public var keyPath: KeyPath<Root, Values.QueryOutput> { _keyPath() }

    public init(
        _ name: String,
        keyPath: @autoclosure @escaping () -> KeyPath<Root, Values.QueryOutput>,
        default defaultValue: @autoclosure @escaping () -> Values.QueryOutput? = nil
    ) {
        self.groupName = name
        self._defaultValue = defaultValue
        self._keyPath = keyPath
    }

    public var queryFragment: ISO_9075.Fragment {
        _columns.map(\.queryFragment).joined(separator: ", ")
    }

    public subscript<Member>(
        dynamicMember keyPath: KeyPath<Values.TableColumns, TableColumn<Values.QueryOutput, Member>>
    ) -> TableColumn<Root, Member> {
        let column = Values.columns[keyPath: keyPath]
        return TableColumn<Root, Member>(
            column.name,
            keyPath: self.keyPath.appending(path: column.keyPath),
            default: column.defaultValue
        )
    }

    public subscript<Member>(
        dynamicMember keyPath: KeyPath<
            Values.TableColumns, GeneratedColumn<Values.QueryOutput, Member>
        >
    ) -> GeneratedColumn<Root, Member> {
        let column = Values.columns[keyPath: keyPath]
        return GeneratedColumn<Root, Member>(
            column.name,
            keyPath: self.keyPath.appending(path: column.keyPath),
            default: column.defaultValue
        )
    }

    public subscript<Member>(
        dynamicMember keyPath: KeyPath<Values.TableColumns, ColumnGroup<Values.QueryOutput, Member>>
    ) -> ColumnGroup<Root, Member> {
        let column = Values.columns[keyPath: keyPath]
        return ColumnGroup<Root, Member>(
            column.groupName,
            keyPath: self.keyPath.appending(path: column.keyPath),
            default: column.defaultValue
        )
    }

    public subscript<Member>(
        dynamicMember keyPath: KeyPath<
            Values.TableColumns, OptionalColumnGroup<Values.QueryOutput, Member>
        >
    ) -> OptionalColumnGroup<Root, Member> {
        let column = Values.columns[keyPath: keyPath]
        return OptionalColumnGroup(
            base: ColumnGroup<Root, Member?>(
                column.groupName,
                keyPath: self.keyPath.appending(path: column.keyPath)
            )
        )
    }

    public var _columns: [Column<Root>] {
        Values.QueryOutput.TableColumns.allColumns.map { $0.rooted(at: keyPath) }
    }

    public var _writableColumns: [Column<Root>] {
        Values.QueryOutput.TableColumns.writableColumns.map { $0.rooted(at: keyPath) }
    }
}
