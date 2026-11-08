public import ISO_9075_Foundation

@dynamicMemberLookup
public struct UpdatesGroup<Base: Table, Values: Table> where Values.QueryOutput: Table {
    package let group: ColumnGroup<Base, Values>
    package var updates: [(String, ISO_9075.Fragment)] = []

    package init(group: ColumnGroup<Base, Values>) {
        self.group = group
    }

    public subscript<Member>(
        dynamicMember keyPath: KeyPath<Values.TableColumns, TableColumn<Values.QueryOutput, Member>>
    ) -> any QueryExpression<Member> {
        get { group[dynamicMember: keyPath] }
        set { updates.append((group[dynamicMember: keyPath].name, newValue.queryFragment)) }
    }

    @_disfavoredOverload
    public subscript<Member>(
        dynamicMember keyPath: KeyPath<Values.TableColumns, TableColumn<Values.QueryOutput, Member>>
    ) -> SQLQueryExpression<Member> {
        get { SQLQueryExpression(group[dynamicMember: keyPath]) }
        set { updates.append((group[dynamicMember: keyPath].name, newValue.queryFragment)) }
    }

    @_disfavoredOverload
    @available(
        *,
        unavailable,
        message: """
            Use '#bind' to explicitly wrap this value in a query expression: '$0.column = #bind(value)'
            """
    )
    public subscript<Member: QueryExpression>(
        dynamicMember keyPath: KeyPath<Values.TableColumns, TableColumn<Values.QueryOutput, Member>>
    ) -> Member.QueryOutput {
        get { fatalError() }
        set {}
    }

    public subscript<Member>(
        dynamicMember keyPath: KeyPath<Values.TableColumns, ColumnGroup<Values.QueryOutput, Member>>
    ) -> UpdatesGroup<Base, Member> {
        get { UpdatesGroup<Base, Member>(group: group[dynamicMember: keyPath]) }
        set { updates.append(contentsOf: newValue.updates) }
    }

    public subscript<Member>(
        dynamicMember keyPath: KeyPath<
            Values.TableColumns, OptionalColumnGroup<Values.QueryOutput, Member>
        >
    ) -> UpdatesGroup<Base, Member?> {
        get { UpdatesGroup<Base, Member?>(group: group[dynamicMember: keyPath].base) }
        set { updates.append(contentsOf: newValue.updates) }
    }

    @_disfavoredOverload
    public subscript<Member>(
        dynamicMember keyPath: KeyPath<Values.TableColumns, ColumnGroup<Values.QueryOutput, Member>>
    ) -> Member.QueryOutput {
        @available(
            *,
            unavailable,
            message: """
                Use '#bind' to explicitly wrap this value in a query expression: '$0.column = #bind(value)'
                """
        )
        get { fatalError() }
        set {
            let row = Member(queryOutput: newValue)
            updates.append(
                contentsOf: Member.TableColumns.writableColumns.map { ($0.name, $0.render(row)) }
            )
        }
    }
}
