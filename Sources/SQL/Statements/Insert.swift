public import ISO_9075_Foundation

extension Table {
    public typealias Excluded = TableAlias<Self, _ExcludedName>.TableColumns

    public static func insert(
        _ columns: (TableColumns) -> TableColumns = { $0 },
        @InsertValuesBuilder<Self> values: () -> ValuesRows<Self>,
        onConflictDoUpdate updates: ((inout Updates<Self>, Excluded) -> Void)?,
        @QueryFragmentBuilder<Bool>
        where updateFilter: (TableColumns, Excluded) -> [ISO_9075.Fragment] = { _, _ in [] }
    ) -> InsertOf<Self> {
        _insert(
            columnNames: TableColumns.writableColumns.map(\.name),
            values: .values(values().rows),
            onConflict: { _ -> ()? in nil },
            where: { _ in return [] },
            doUpdate: updates,
            where: updateFilter
        )
    }

    public static func insert(
        _ columns: (TableColumns) -> TableColumns = { $0 },
        @InsertValuesBuilder<Self> values: () -> ValuesRows<Self>,
        onConflictDoUpdate updates: ((inout Updates<Self>) -> Void)? = nil,
        @QueryFragmentBuilder<Bool>
        where updateFilter: (TableColumns) -> [ISO_9075.Fragment] = { _ in [] }
    ) -> InsertOf<Self> {
        insert(
            columns,
            values: values,
            onConflictDoUpdate: updates.map { updates in { row, _ in updates(&row) } },
            where: { columns, _ in return updateFilter(columns) }
        )
    }

    public static func insert<T1: _TableColumnExpression, each T2: _TableColumnExpression>(
        _ columns: (TableColumns) -> TableColumns = { $0 },
        @InsertValuesBuilder<Self> values: () -> ValuesRows<Self>,
        onConflict conflictTargets: (TableColumns) -> (T1, repeat each T2),
        @QueryFragmentBuilder<Bool>
        where targetFilter: (TableColumns) -> [ISO_9075.Fragment] = { _ in [] },
        doUpdate updates: (inout Updates<Self>, Excluded) -> Void = { _, _ in },
        @QueryFragmentBuilder<Bool>
        where updateFilter: (TableColumns, Excluded) -> [ISO_9075.Fragment] = { _, _ in [] }
    ) -> InsertOf<Self> {
        withoutActuallyEscaping(updates) { updates in
            _insert(
                columnNames: TableColumns.writableColumns.map(\.name),
                values: .values(values().rows),
                onConflict: conflictTargets,
                where: targetFilter,
                doUpdate: updates,
                where: updateFilter
            )
        }
    }

    public static func insert<T1: _TableColumnExpression, each T2: _TableColumnExpression>(
        _ columns: (TableColumns) -> TableColumns = { $0 },
        @InsertValuesBuilder<Self> values: () -> ValuesRows<Self>,
        onConflict conflictTargets: (TableColumns) -> (T1, repeat each T2),
        @QueryFragmentBuilder<Bool>
        where targetFilter: (TableColumns) -> [ISO_9075.Fragment] = { _ in [] },
        doUpdate updates: (inout Updates<Self>) -> Void,
        @QueryFragmentBuilder<Bool>
        where updateFilter: (TableColumns) -> [ISO_9075.Fragment] = { _ in [] }
    ) -> InsertOf<Self> {
        insert(
            columns,
            values: values,
            onConflict: conflictTargets,
            where: targetFilter,
            doUpdate: { row, _ in updates(&row) },
            where: { row, _ in return updateFilter(row) }
        )
    }

    public static func insert<V1: _TableColumnExpression, each V2: _TableColumnExpression>(
        _ columns: (TableColumns) -> (V1, repeat each V2),
        @InsertValuesBuilder<(V1.Value, repeat (each V2).Value)>
        values: () -> ValuesRows<(V1.Value, repeat (each V2).Value)>,
        onConflictDoUpdate updates: ((inout Updates<Self>, Excluded) -> Void)?,
        @QueryFragmentBuilder<Bool>
        where updateFilter: (TableColumns, Excluded) -> [ISO_9075.Fragment] = { _, _ in [] }
    ) -> InsertOf<Self> {
        _insert(
            columns,
            values: values,
            onConflict: { _ -> ()? in nil },
            where: { _ in return [] },
            doUpdate: updates,
            where: updateFilter
        )
    }

    public static func insert<V1: _TableColumnExpression, each V2: _TableColumnExpression>(
        _ columns: (TableColumns) -> (V1, repeat each V2),
        @InsertValuesBuilder<(V1.Value, repeat (each V2).Value)>
        values: () -> ValuesRows<(V1.Value, repeat (each V2).Value)>,
        onConflictDoUpdate updates: ((inout Updates<Self>) -> Void)? = nil,
        @QueryFragmentBuilder<Bool>
        where updateFilter: (TableColumns) -> [ISO_9075.Fragment] = { _ in [] }
    ) -> InsertOf<Self> {
        insert(
            columns,
            values: values,
            onConflictDoUpdate: updates.map { updates in { row, _ in updates(&row) } },
            where: { columns, _ in return updateFilter(columns) }
        )
    }

    public static func insert<
        V1: _TableColumnExpression,
        each V2: _TableColumnExpression,
        T1: _TableColumnExpression,
        each T2: _TableColumnExpression
    >(
        _ columns: (TableColumns) -> (V1, repeat each V2),
        @InsertValuesBuilder<(V1.Value, repeat (each V2).Value)>
        values: () -> ValuesRows<(V1.Value, repeat (each V2).Value)>,
        onConflict conflictTargets: (TableColumns) -> (T1, repeat each T2),
        @QueryFragmentBuilder<Bool>
        where targetFilter: (TableColumns) -> [ISO_9075.Fragment] = { _ in [] },
        doUpdate updates: (inout Updates<Self>, Excluded) -> Void = { _, _ in },
        @QueryFragmentBuilder<Bool>
        where updateFilter: (TableColumns, Excluded) -> [ISO_9075.Fragment] = { _, _ in [] }
    ) -> InsertOf<Self> {
        withoutActuallyEscaping(updates) { updates in
            _insert(
                columns,
                values: values,
                onConflict: conflictTargets,
                where: targetFilter,
                doUpdate: updates,
                where: updateFilter
            )
        }
    }

    public static func insert<
        V1: _TableColumnExpression,
        each V2: _TableColumnExpression,
        T1: _TableColumnExpression,
        each T2: _TableColumnExpression
    >(
        _ columns: (TableColumns) -> (V1, repeat each V2),
        @InsertValuesBuilder<(V1.Value, repeat (each V2).Value)>
        values: () -> ValuesRows<(V1.Value, repeat (each V2).Value)>,
        onConflict conflictTargets: (TableColumns) -> (T1, repeat each T2),
        @QueryFragmentBuilder<Bool>
        where targetFilter: (TableColumns) -> [ISO_9075.Fragment] = { _ in [] },
        doUpdate updates: (inout Updates<Self>) -> Void,
        @QueryFragmentBuilder<Bool>
        where updateFilter: (TableColumns) -> [ISO_9075.Fragment] = { _ in [] }
    ) -> InsertOf<Self> {
        insert(
            columns,
            values: values,
            onConflict: conflictTargets,
            where: targetFilter,
            doUpdate: { row, _ in updates(&row) },
            where: { row, _ in return updateFilter(row) }
        )
    }

    private static func _insert<
        each Value: _TableColumnExpression,
        each ConflictTarget: _TableColumnExpression
    >(
        _ columns: (TableColumns) -> (repeat each Value),
        @InsertValuesBuilder<(repeat (each Value).Value)>
        values: () -> ValuesRows<(repeat (each Value).Value)>,
        onConflict conflictTargets: (TableColumns) -> (repeat each ConflictTarget)?,
        @QueryFragmentBuilder<Bool>
        where targetFilter: (TableColumns) -> [ISO_9075.Fragment] = { _ in [] },
        doUpdate updates: ((inout Updates<Self>, Excluded) -> Void)?,
        @QueryFragmentBuilder<Bool>
        where updateFilter: (TableColumns, Excluded) -> [ISO_9075.Fragment] = { _, _ in [] }
    ) -> InsertOf<Self> {
        var columnNames: [String] = []
        for column in repeat each columns(Self.columns) {
            columnNames.append(contentsOf: column._names)
        }
        return _insert(
            columnNames: columnNames,
            values: .values(values().rows),
            onConflict: conflictTargets,
            where: targetFilter,
            doUpdate: updates,
            where: updateFilter
        )
    }

    public static func insert<
        V1: _TableColumnExpression,
        each V2: _TableColumnExpression
    >(
        _ columns: (TableColumns) -> (V1, repeat each V2),
        select selection: () -> some PartialSelectStatement<(V1.Value, repeat (each V2).Value)>,
        onConflictDoUpdate updates: ((inout Updates<Self>, Excluded) -> Void)? = nil,
        @QueryFragmentBuilder<Bool>
        where updateFilter: (TableColumns, Excluded) -> [ISO_9075.Fragment] = { _, _ in [] }
    ) -> InsertOf<Self> {
        _insert(
            columns,
            select: selection,
            onConflict: { _ -> ()? in nil },
            where: { _ in return [] },
            doUpdate: updates,
            where: updateFilter
        )
    }

    public static func insert<V1: _TableColumnExpression>(
        _ columns: (TableColumns) -> V1,
        select selection: () -> some PartialSelectStatement<V1.Value>,
        onConflictDoUpdate updates: ((inout Updates<Self>, Excluded) -> Void)? = nil,
        @QueryFragmentBuilder<Bool>
        where updateFilter: (TableColumns, Excluded) -> [ISO_9075.Fragment] = { _, _ in [] }
    ) -> InsertOf<Self> {
        _insert(
            columns,
            select: selection,
            onConflict: { _ -> ()? in nil },
            where: { _ in return [] },
            doUpdate: updates,
            where: updateFilter
        )
    }

    public static func insert<
        V1: _TableColumnExpression,
        each V2: _TableColumnExpression
    >(
        _ columns: (TableColumns) -> (V1, repeat each V2),
        select selection: () -> some PartialSelectStatement<(V1.Value, repeat (each V2).Value)>,
        onConflictDoUpdate updates: ((inout Updates<Self>) -> Void)?,
        @QueryFragmentBuilder<Bool>
        where updateFilter: (TableColumns) -> [ISO_9075.Fragment] = { _ in [] }
    ) -> InsertOf<Self> {
        insert(
            columns,
            select: selection,
            onConflictDoUpdate: updates.map { updates in { row, _ in updates(&row) } },
            where: { columns, _ in return updateFilter(columns) }
        )
    }

    public static func insert<
        V1: _TableColumnExpression,
        each V2: _TableColumnExpression,
        T1: _TableColumnExpression,
        each T2: _TableColumnExpression
    >(
        _ columns: (TableColumns) -> (V1, repeat each V2),
        select selection: () -> some PartialSelectStatement<(V1.Value, repeat (each V2).Value)>,
        onConflict conflictTargets: (TableColumns) -> (T1, repeat each T2),
        @QueryFragmentBuilder<Bool>
        where targetFilter: (TableColumns) -> [ISO_9075.Fragment] = { _ in [] },
        doUpdate updates: (inout Updates<Self>, Excluded) -> Void = { _, _ in },
        @QueryFragmentBuilder<Bool>
        where updateFilter: (TableColumns, Excluded) -> [ISO_9075.Fragment] = { _, _ in [] }
    ) -> InsertOf<Self> {
        withoutActuallyEscaping(updates) { updates in
            _insert(
                columns,
                select: selection,
                onConflict: conflictTargets,
                where: targetFilter,
                doUpdate: updates,
                where: updateFilter
            )
        }
    }

    public static func insert<
        V1: _TableColumnExpression,
        T1: _TableColumnExpression,
        each T2: _TableColumnExpression
    >(
        _ columns: (TableColumns) -> V1,
        select selection: () -> some PartialSelectStatement<V1.Value>,
        onConflict conflictTargets: (TableColumns) -> (T1, repeat each T2),
        @QueryFragmentBuilder<Bool>
        where targetFilter: (TableColumns) -> [ISO_9075.Fragment] = { _ in [] },
        doUpdate updates: (inout Updates<Self>, Excluded) -> Void = { _, _ in },
        @QueryFragmentBuilder<Bool>
        where updateFilter: (TableColumns, Excluded) -> [ISO_9075.Fragment] = { _, _ in [] }
    ) -> InsertOf<Self> {
        withoutActuallyEscaping(updates) { updates in
            _insert(
                columns,
                select: selection,
                onConflict: conflictTargets,
                where: targetFilter,
                doUpdate: updates,
                where: updateFilter
            )
        }
    }

    public static func insert<
        V1: _TableColumnExpression,
        each V2: _TableColumnExpression,
        T1: _TableColumnExpression,
        each T2: _TableColumnExpression
    >(
        _ columns: (TableColumns) -> (V1, repeat each V2),
        select selection: () -> some PartialSelectStatement<(V1.Value, repeat (each V2).Value)>,
        onConflict conflictTargets: (TableColumns) -> (T1, repeat each T2),
        @QueryFragmentBuilder<Bool>
        where targetFilter: (TableColumns) -> [ISO_9075.Fragment] = { _ in [] },
        doUpdate updates: (inout Updates<Self>) -> Void,
        @QueryFragmentBuilder<Bool>
        where updateFilter: (TableColumns) -> [ISO_9075.Fragment] = { _ in [] }
    ) -> InsertOf<Self> {
        insert(
            columns,
            select: selection,
            onConflict: conflictTargets,
            where: targetFilter,
            doUpdate: { row, _ in updates(&row) },
            where: { row, _ in return updateFilter(row) }
        )
    }

    public static func insert<
        V1: _TableColumnExpression,
        T1: _TableColumnExpression,
        each T2: _TableColumnExpression
    >(
        _ columns: (TableColumns) -> V1,
        select selection: () -> some PartialSelectStatement<V1.Value>,
        onConflict conflictTargets: (TableColumns) -> (T1, repeat each T2),
        @QueryFragmentBuilder<Bool>
        where targetFilter: (TableColumns) -> [ISO_9075.Fragment] = { _ in [] },
        doUpdate updates: (inout Updates<Self>) -> Void,
        @QueryFragmentBuilder<Bool>
        where updateFilter: (TableColumns) -> [ISO_9075.Fragment] = { _ in [] }
    ) -> InsertOf<Self> {
        insert(
            columns,
            select: selection,
            onConflict: conflictTargets,
            where: targetFilter,
            doUpdate: { row, _ in updates(&row) },
            where: { columns, _ in return updateFilter(columns) }
        )
    }

    private static func _insert<
        each Value: _TableColumnExpression,
        each ConflictTarget: _TableColumnExpression
    >(
        _ columns: (TableColumns) -> (repeat each Value),
        select selection: () -> some PartialSelectStatement<(repeat (each Value).Value)>,
        onConflict conflictTargets: (TableColumns) -> (repeat each ConflictTarget)?,
        @QueryFragmentBuilder<Bool>
        where targetFilter: (TableColumns) -> [ISO_9075.Fragment] = { _ in [] },
        doUpdate updates: ((inout Updates<Self>, Excluded) -> Void)?,
        @QueryFragmentBuilder<Bool>
        where updateFilter: (TableColumns, Excluded) -> [ISO_9075.Fragment] = { _, _ in [] }
    ) -> InsertOf<Self> {
        var columnNames: [String] = []
        for column in repeat each columns(Self.columns) {
            columnNames.append(contentsOf: column._names)
        }
        return _insert(
            columnNames: columnNames,
            values: .select(selection()),
            onConflict: conflictTargets,
            where: targetFilter,
            doUpdate: updates,
            where: updateFilter
        )
    }

    public static func insert() -> InsertOf<Self> {
        _insert(
            columnNames: [],
            values: .default,
            onConflict: { _ -> ()? in nil },
            where: { _ in return [] },
            doUpdate: nil,
            where: { _, _ in return [] }
        )
    }

    fileprivate static func _insert<each ConflictTarget: _TableColumnExpression>(
        columnNames: [String],
        values: InsertValues,
        onConflict conflictTargets: (TableColumns) -> (repeat each ConflictTarget)?,
        @QueryFragmentBuilder<Bool>
        where targetFilter: (TableColumns) -> [ISO_9075.Fragment] = { _ in [] },
        doUpdate updates: ((inout Updates<Self>, Excluded) -> Void)?,
        @QueryFragmentBuilder<Bool>
        where updateFilter: (TableColumns, Excluded) -> [ISO_9075.Fragment] = { _, _ in [] }
    ) -> InsertOf<Self> {
        var conflictTargetColumnNames: [String] = []
        if let conflictTargets = conflictTargets(Self.columns) {
            for column in repeat each conflictTargets {
                conflictTargetColumnNames.append(contentsOf: column._names)
            }
        }
        return Insert(
            conflictResolution: nil,
            columnNames: columnNames,
            conflictTargetColumnNames: conflictTargetColumnNames,
            conflictTargetFilter: targetFilter(Self.columns),
            values: values,
            updates: updates.map { updates in Updates { updates(&$0, Excluded.QueryValue.columns) }
            },
            updateFilter: updateFilter(Self.columns, Excluded.QueryValue.columns),
            returning: []
        )
    }
}

extension PrimaryKeyedTable {
    public static func upsert(
        @InsertValuesBuilder<Self> values: () -> ValuesRows<Self>
    ) -> InsertOf<Self> {
        insert(
            values: values,
            onConflict: { $0.primaryKey },
            doUpdate: { updates, _ in
                for (column, excluded) in zip(
                    Draft.TableColumns.writableColumns,
                    Excluded.writableColumns
                )
                where !columns.primaryKey._names.contains(column.name) {
                    updates.set(column, excluded.queryFragment)
                }
            }
        )
    }
}

private enum InsertValues {
    case `default`
    case values([[ISO_9075.Fragment]])
    case select(any PartialSelectStatement)
}

public struct Insert<Into: Table, Returning> {
    package var conflictResolution: ISO_9075.Fragment?
    var columnNames: [String]
    var conflictTargetColumnNames: [String]
    var conflictTargetFilter: [ISO_9075.Fragment]
    fileprivate var values: InsertValues
    var updates: Updates<Into>?
    var updateFilter: [ISO_9075.Fragment]
    var returning: [ISO_9075.Fragment]

    package func _returning<R>(_ returning: [ISO_9075.Fragment]) -> Insert<Into, R> {
        Insert<Into, R>(
            conflictResolution: conflictResolution,
            columnNames: columnNames,
            conflictTargetColumnNames: conflictTargetColumnNames,
            conflictTargetFilter: conflictTargetFilter,
            values: values,
            updates: updates,
            updateFilter: updateFilter,
            returning: returning
        )
    }

    fileprivate init(
        conflictResolution: ISO_9075.Fragment?,
        columnNames: [String],
        conflictTargetColumnNames: [String],
        conflictTargetFilter: [ISO_9075.Fragment],
        values: InsertValues,
        updates: Updates<Into>?,
        updateFilter: [ISO_9075.Fragment],
        returning: [ISO_9075.Fragment]
    ) {
        self.conflictResolution = conflictResolution
        self.columnNames = columnNames
        self.conflictTargetColumnNames = conflictTargetColumnNames
        self.conflictTargetFilter = conflictTargetFilter
        self.values = values
        self.updates = updates
        self.updateFilter = updateFilter
        self.returning = returning
    }

}

extension Insert: Statement {
    public typealias QueryValue = Returning
    public typealias From = Into

    public var query: ISO_9075.Fragment {
        var query: ISO_9075.Fragment = "INSERT"
        if let conflictResolution {
            query.append(" OR \(conflictResolution)")
        }
        query.append(" INTO ")
        if let schemaName = Into.schemaName {
            query.append("\(quote: schemaName).")
        }
        query.append("\(quote: Into.tableName)")
        if let tableAlias = Into.tableAlias {
            query.append(" AS \(quote: tableAlias)")
        }
        if !columnNames.isEmpty {
            query.append(
                "\(.newlineOrSpace)(\(columnNames.map { "\(quote: $0)" }.joined(separator: ", ")))"
            )
        }
        switch values {
        case .default:
            query.append("\(.newlineOrSpace)DEFAULT VALUES")

        case .select(let statement):
            let select = statement.query
            guard !select.isEmpty else { return "" }
            query.append("\(.newlineOrSpace)\(select)")
            if updates != nil,
                (statement as? any HasUpsertParsingAmbiguity)?.hasUpsertParsingAmbiguity == true
            {
                query.append("\(.newlineOrSpace)WHERE 1")
            }

        case .values(let values):
            guard !values.isEmpty else { return "" }
            query.append("\(.newlineOrSpace)VALUES\(.newlineOrSpace)")
            let values: [ISO_9075.Fragment] = values.map {
                var value: ISO_9075.Fragment = "("
                value.append($0.joined(separator: ", "))
                value.append(")")
                return value
            }
            query.append(values.joined(separator: ", "))
        }

        var hasInvalidWhere = false
        if let updates {
            query.append("\(.newlineOrSpace)ON CONFLICT ")
            if !conflictTargetColumnNames.isEmpty {
                query.append("(")
                query.append(
                    conflictTargetColumnNames.map { "\(quote: $0)" }.joined(separator: ", ")
                )
                query.append(")\(.newlineOrSpace)")
                if !conflictTargetFilter.isEmpty {
                    query.append(
                        "WHERE \(conflictTargetFilter.joined(separator: " AND "))\(.newlineOrSpace)"
                    )
                }
            }
            query.append("DO ")
            if updates.isEmpty {
                query.append("NOTHING")
                hasInvalidWhere = !updateFilter.isEmpty
            } else {
                query.append("UPDATE \(bind: updates)")
                if !updateFilter.isEmpty {
                    query.append(
                        "\(.newlineOrSpace)WHERE \(updateFilter.joined(separator: " AND "))"
                    )
                }
            }
        } else {
            hasInvalidWhere = !updateFilter.isEmpty
        }
        if !returning.isEmpty {
            query.append("\(.newlineOrSpace)RETURNING \(returning.joined(separator: ", "))")
        }
        precondition(
            !hasInvalidWhere,
            "Insert statement has invalid update 'where': \(updateFilter.joined(separator: " AND ").debugDescription)"
        )
        return query
    }
}

public typealias InsertOf<Into: Table> = Insert<Into, ()>

@resultBuilder
public enum InsertValuesBuilder<Value> {
    public static func buildExpression(_ expression: [Value]) -> ValuesRows<Value>
    where Value: Table {
        ValuesRows(rows: _writableRows(expression), elements: [Value.writableValuesElement])
    }

    @_disfavoredOverload
    public static func buildExpression(_ expression: [Value.Draft]) -> ValuesRows<Value>
    where Value: Table, Value.Draft: TableDraft {
        ValuesRows(rows: _writableRows(expression), elements: [Value.Draft.writableValuesElement])
    }

    @_disfavoredOverload
    public static func buildExpression<V: QueryExpression>(
        _ expression: [V]
    ) -> ValuesRows<Value>
    where
        Value == V.QueryValue,
        V.QueryValue: QueryRepresentable & QueryBindable
    {
        ValuesRows(
            rows: expression.map { [$0.queryFragment] },
            elements: ValuesElement.elements(for: Value.self)
        )
    }

    @_disfavoredOverload
    public static func buildExpression(
        _ expression: [Value.QueryOutput]
    ) -> ValuesRows<Value>
    where Value: QueryRepresentable & QueryBindable {
        ValuesRows(
            rows: expression.map { [Value(queryOutput: $0).queryFragment] },
            elements: ValuesElement.elements(for: Value.self)
        )
    }

    public static func buildExpression(_ expression: Value) -> ValuesRows<Value>
    where Value: Table {
        buildExpression([expression])
    }

    public static func buildExpression(_ expression: Value.Draft) -> ValuesRows<Value>
    where Value: Table, Value.Draft: TableDraft {
        buildExpression([expression])
    }

    @_disfavoredOverload
    public static func buildExpression<V: QueryExpression>(
        _ expression: V
    ) -> ValuesRows<Value>
    where
        Value == V.QueryValue,
        V.QueryValue: QueryRepresentable & QueryBindable
    {
        buildExpression([expression])
    }

    public static func buildExpression(
        _ expression: Value.QueryOutput
    ) -> ValuesRows<Value>
    where Value: QueryRepresentable & QueryBindable {
        buildExpression([expression])
    }

    @_disfavoredOverload
    public static func buildExpression<each V: QueryExpression>(
        _ expression: (repeat each V)
    ) -> ValuesRows<Value>
    where
        Value == (repeat (each V).QueryValue),
        repeat (each V).QueryValue: QueryRepresentable
    {
        var valueFragment: [ISO_9075.Fragment] = []
        for column in repeat each expression {
            valueFragment.append(column.queryFragment)
        }
        return ValuesRows(
            rows: [valueFragment],
            elements: ValuesElement.elements(for: repeat ((each V).QueryValue).self)
        )
    }

    public static func buildExpression<each V: QueryRepresentable & QueryBindable>(
        _ expression: (repeat (each V).QueryOutput)
    ) -> ValuesRows<Value>
    where Value == (repeat each V) {
        var valueFragment: [ISO_9075.Fragment] = []
        for (columnType, column) in repeat ((each V).self, each expression) {
            valueFragment.append(columnType.init(queryOutput: column).queryFragment)
        }
        return ValuesRows(
            rows: [valueFragment],
            elements: ValuesElement.elements(for: repeat (each V).self)
        )
    }

    public static func buildExpression(
        _ expression: Value.Selection
    ) -> ValuesRows<Value>
    where Value: Table {
        ValuesRows(
            rows: [expression.allColumns],
            elements: [Value.valuesElement]
        )
    }

    public static func buildExpression(
        _ expression: some TableExpression<Value>
    ) -> ValuesRows<Value>
    where Value: Table {
        ValuesRows(
            rows: [expression.allColumns],
            elements: [Value.valuesElement]
        )
    }

    public static func buildArray(_ components: [ValuesRows<Value>]) -> ValuesRows<Value> {
        var rows = ValuesRows<Value>(rows: [])
        rows.rows.reserveCapacity(components.reduce(0) { $0 + $1.rows.count })
        for component in components {
            rows.append(component)
        }
        return rows
    }

    public static func buildBlock(_ components: ValuesRows<Value>) -> ValuesRows<Value> {
        components
    }

    public static func buildEither(first component: ValuesRows<Value>) -> ValuesRows<Value> {
        component
    }

    public static func buildEither(second component: ValuesRows<Value>) -> ValuesRows<Value> {
        component
    }

    public static func buildLimitedAvailability(_ component: ValuesRows<Value>) -> ValuesRows<Value>
    {
        component
    }

    public static func buildOptional(_ component: ValuesRows<Value>?) -> ValuesRows<Value> {
        component ?? ValuesRows(rows: [])
    }

    public static func buildPartialBlock(first: ValuesRows<Value>) -> ValuesRows<Value> {
        first
    }

    public static func buildPartialBlock(
        accumulated: ValuesRows<Value>,
        next: ValuesRows<Value>
    ) -> ValuesRows<Value> {
        var rows = accumulated
        rows.append(next)
        return rows
    }
}

private func _writableRows<T: Table>(_ values: [T]) -> [[ISO_9075.Fragment]] {
    values.map { value in
        T.TableColumns.writableColumns.map { column in
            func open<Root, Member>(
                _ column: some WritableTableColumnExpression<Root, Member>
            ) -> ISO_9075.Fragment {
                Member(queryOutput: (value as! Root)[keyPath: column.keyPath]).queryFragment
            }
            return open(column)
        }
    }
}

public struct _ExcludedName: AliasName {
    public static var aliasName: String { "excluded" }
}
