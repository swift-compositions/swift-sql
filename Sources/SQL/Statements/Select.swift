public import ISO_9075_Foundation

extension Table {
    public static func select<ResultColumn: QueryExpression>(
        _ selection: KeyPath<TableColumns, ResultColumn>
    ) -> Select<ResultColumn.QueryValue, Self, ()>
    where ResultColumn.QueryValue: QueryRepresentable {
        Where().select(selection)
    }

    public static func select<ResultColumn: QueryExpression>(
        _ selection: (TableColumns) -> ResultColumn
    ) -> Select<ResultColumn.QueryValue, Self, ()>
    where ResultColumn.QueryValue: QueryRepresentable {
        Where().select(selection)
    }

    public static func select<
        C1: QueryExpression,
        C2: QueryExpression,
        each C3: QueryExpression
    >(
        _ selection: (TableColumns) -> (C1, C2, repeat each C3)
    ) -> Select<(C1.QueryValue, C2.QueryValue, repeat (each C3).QueryValue), Self, ()>
    where
        C1.QueryValue: QueryRepresentable,
        C2.QueryValue: QueryRepresentable,
        repeat (each C3).QueryValue: QueryRepresentable
    {
        Where().select(selection)
    }

    public static func distinct(_ isDistinct: Bool = true) -> SelectOf<Self> {
        Where().distinct(isDistinct)
    }

    public static func join<
        each C: QueryRepresentable,
        F: Table,
        each J: Table
    >(
        _ other: some SelectStatement<(repeat each C), F, (repeat each J)>,
        on constraint: (
            (TableColumns, F.TableColumns, repeat (each J).TableColumns)
        ) -> some QueryExpression<Bool>
    ) -> Select<(repeat each C), Self, (F, repeat each J)> {
        Where().join(other, on: constraint)
    }

    @_documentation(visibility: private)
    public static func join<each C: QueryRepresentable, F: Table>(
        _ other: some SelectStatement<(repeat each C), F, ()>,
        on constraint: (
            (TableColumns, F.TableColumns)
        ) -> some QueryExpression<Bool>
    ) -> Select<(repeat each C), Self, F> {
        Where().join(other, on: constraint)
    }

    public static func leftJoin<
        each C: QueryRepresentable,
        F: Table,
        each J: Table
    >(
        _ other: some SelectStatement<(repeat each C), F, (repeat each J)>,
        on constraint: (
            (TableColumns, F.TableColumns, repeat (each J).TableColumns)
        ) -> some QueryExpression<Bool>
    ) -> Select<
        (repeat (each C)._Optionalized),
        Self,
        (F._Optionalized, repeat (each J)._Optionalized)
    > {
        Where().leftJoin(other, on: constraint)
    }

    @_documentation(visibility: private)
    public static func leftJoin<each C: QueryRepresentable, F: Table>(
        _ other: some SelectStatement<(repeat each C), F, ()>,
        on constraint: (
            (TableColumns, F.TableColumns)
        ) -> some QueryExpression<Bool>
    ) -> Select<(repeat (each C)._Optionalized), Self, F._Optionalized> {
        Where().leftJoin(other, on: constraint)
    }

    public static func rightJoin<
        each C: QueryRepresentable,
        F: Table,
        each J: Table
    >(
        _ other: some SelectStatement<(repeat each C), F, (repeat each J)>,
        on constraint: (
            (TableColumns, F.TableColumns, repeat (each J).TableColumns)
        ) -> some QueryExpression<Bool>
    ) -> Select<(repeat each C), Self._Optionalized, (F, repeat each J)> {
        Where<Self>().rightJoin(other, on: constraint)
    }

    @_documentation(visibility: private)
    public static func rightJoin<each C: QueryRepresentable, F: Table>(
        _ other: some SelectStatement<(repeat each C), F, ()>,
        on constraint: (
            (TableColumns, F.TableColumns)
        ) -> some QueryExpression<Bool>
    ) -> Select<(repeat each C), Self._Optionalized, F> {
        Where<Self>().rightJoin(other, on: constraint)
    }

    public static func fullJoin<
        each C: QueryRepresentable,
        F: Table,
        each J: Table
    >(
        _ other: some SelectStatement<(repeat each C), F, (repeat each J)>,
        on constraint: (
            (TableColumns, F.TableColumns, repeat (each J).TableColumns)
        ) -> some QueryExpression<Bool>
    ) -> Select<
        (repeat (each C)._Optionalized),
        Self._Optionalized,
        (F._Optionalized, repeat (each J)._Optionalized)
    > {
        Where<Self>().fullJoin(other, on: constraint)
    }

    @_documentation(visibility: private)
    public static func fullJoin<each C: QueryRepresentable, F: Table>(
        _ other: some SelectStatement<(repeat each C), F, ()>,
        on constraint: (
            (TableColumns, F.TableColumns)
        ) -> some QueryExpression<Bool>
    ) -> Select<(repeat (each C)._Optionalized), Self._Optionalized, F._Optionalized> {
        Where<Self>().fullJoin(other, on: constraint)
    }

    public static func group<C: QueryExpression>(
        by grouping: (TableColumns) -> C
    ) -> SelectOf<Self> {
        Where().group(by: grouping)
    }

    public static func group<
        C1: QueryExpression,
        C2: QueryExpression,
        each C3: QueryExpression
    >(
        by grouping: (TableColumns) -> (C1, C2, repeat each C3)
    ) -> SelectOf<Self> {
        Where().group(by: grouping)
    }

    public static func having(
        _ predicate: (TableColumns) -> some QueryExpression<some _OptionalPromotable<Bool?>>
    ) -> SelectOf<Self> {
        Where().having(predicate)
    }

    public static func order(
        by ordering: KeyPath<TableColumns, some QueryExpression>
    ) -> SelectOf<Self> {
        Where().order(by: ordering)
    }

    public static func order(
        @QueryFragmentBuilder<()>
        by ordering: (TableColumns) -> [ISO_9075.Fragment]
    ) -> SelectOf<Self> {
        Where().order(by: ordering)
    }

    public static func limit(_ maxLength: (some QueryExpression<Int>)?) -> SelectOf<Self> {
        Where().limit(maxLength)
    }

    public static func limit(
        @QueryFragmentBuilder<Int>
        _ maxLength: (TableColumns) -> [ISO_9075.Fragment]
    ) -> SelectOf<Self> {
        Where().limit(maxLength)
    }

    public static func offset(_ offset: (some QueryExpression<Int>)?) -> SelectOf<Self> {
        Where().offset(offset)
    }

    public static func offset(
        @QueryFragmentBuilder<Int>
        _ offset: (TableColumns) -> [ISO_9075.Fragment]
    ) -> SelectOf<Self> {
        Where().offset(offset)
    }

    public static func count() -> Select<Int, Self, ()> {
        Where().count()
    }

    public static func count<Filter: QueryExpression<Bool>>(
        filter: (TableColumns) -> Filter
    ) -> Select<Int, Self, ()> {
        Where().count(filter: filter)
    }
}

public struct _SelectClauses: Sendable {
    var isEmpty = false
    var distinct = false
    var columns: [ISO_9075.Fragment] = []
    var from: ISO_9075.Fragment?
    var joins: [_JoinClause] = []
    var `where`: [ISO_9075.Fragment] = []
    var group: [ISO_9075.Fragment] = []
    var having: [ISO_9075.Fragment] = []
    var order: [ISO_9075.Fragment] = []
    var limit: _LimitClause?
    var valuesElements: [ValuesElement] = []
}

    @dynamicMemberLookup
public struct Select<Columns, From: _SelectSource, Joins>: Sendable {
    @CopyOnWrite var clauses = _SelectClauses()

    fileprivate var isEmpty: Bool {
        get { clauses.isEmpty }
        set { clauses.isEmpty = newValue }
        _modify { yield &clauses.isEmpty }
    }
    fileprivate var distinct: Bool {
        get { clauses.distinct }
        set { clauses.distinct = newValue }
        _modify { yield &clauses.distinct }
    }
    fileprivate var columns: [ISO_9075.Fragment] {
        get { clauses.columns }
        set { clauses.columns = newValue }
        _modify { yield &clauses.columns }
    }
    fileprivate var from: ISO_9075.Fragment? {
        get { clauses.from }
        set { clauses.from = newValue }
        _modify { yield &clauses.from }
    }
    fileprivate var joins: [_JoinClause] {
        get { clauses.joins }
        set { clauses.joins = newValue }
        _modify { yield &clauses.joins }
    }
    fileprivate var `where`: [ISO_9075.Fragment] {
        get { clauses.where }
        set { clauses.where = newValue }
        _modify { yield &clauses.where }
    }
    fileprivate var group: [ISO_9075.Fragment] {
        get { clauses.group }
        set { clauses.group = newValue }
        _modify { yield &clauses.group }
    }
    fileprivate var having: [ISO_9075.Fragment] {
        get { clauses.having }
        set { clauses.having = newValue }
        _modify { yield &clauses.having }
    }
    fileprivate var order: [ISO_9075.Fragment] {
        get { clauses.order }
        set { clauses.order = newValue }
        _modify { yield &clauses.order }
    }
    fileprivate var limit: _LimitClause? {
        get { clauses.limit }
        set { clauses.limit = newValue }
        _modify { yield &clauses.limit }
    }

    fileprivate init(
        isEmpty: Bool,
        distinct: Bool,
        columns: [ISO_9075.Fragment],
        from: ISO_9075.Fragment? = nil,
        joins: [_JoinClause],
        where: [ISO_9075.Fragment],
        group: [ISO_9075.Fragment],
        having: [ISO_9075.Fragment],
        order: [ISO_9075.Fragment],
        limit: _LimitClause?
    ) {
        self.isEmpty = isEmpty
        self.columns = columns
        self.distinct = distinct
        self.from = from
        self.joins = joins
        self.where = `where`
        self.group = group
        self.having = having
        self.order = order
        self.limit = limit
    }

    init(clauses: _SelectClauses) {
        self.clauses = clauses
    }

    package var _tableReference: ISO_9075.Fragment? {
        get { clauses.from }
        set { clauses.from = newValue }
    }
}

@dynamicMemberLookup
public struct ValuesColumns<Value>: QueryExpression, _SelectSource, Sendable {
    public typealias QueryValue = Value

    let columns: [ISO_9075.Fragment]
    let elements: [ValuesElement]?

    package init(columns: [ISO_9075.Fragment], elements: [ValuesElement]? = nil) {
        self.columns = columns
        self.elements = elements
    }

    public var queryFragment: ISO_9075.Fragment {
        columns.joined(separator: ", ")
    }

    public subscript<Member>(
        dynamicMember keyPath: KeyPath<Value, Member>
    ) -> SQLQueryExpression<Member> {
        column(at: (elements ?? []).columnIndex(of: keyPath), as: Member.self)
    }

    private func column<Member>(at index: Int?, as _: Member.Type) -> SQLQueryExpression<Member> {
        guard let index, columns.indices.contains(index) else {
            preconditionFailure("Could not determine the column for the given key path")
        }
        return SQLQueryExpression(columns[index], as: Member.self)
    }
}

extension ValuesColumns where Value: QueryRepresentable {
    public subscript<Member>(
        dynamicMember keyPath: KeyPath<Value, Member>
    ) -> SQLQueryExpression<Member> {
        column(
            at: Value._valuesColumnIndex(of: keyPath)
                ?? (elements ?? ValuesElement.elements(for: Value.self)).columnIndex(of: keyPath),
            as: Member.self
        )
    }
}

extension Select where Joins == () {
    @_disfavoredOverload
    public init(_ value: Columns)
    where Columns: QueryExpression, Columns.QueryValue: QueryRepresentable, From == ValuesColumns<Columns> {
        self.init(clauses: _SelectClauses())
        columns = $_isSelecting.withValue(true) { [value.queryFragment] }
        clauses.valuesElements = ValuesElement.elements(for: Columns.QueryValue.self)
    }

    @_disfavoredOverload
    public init<each Value: QueryExpression>(
        _ values: repeat each Value
    )
    where
        Columns == (repeat (each Value).QueryValue),
        repeat (each Value).QueryValue: QueryRepresentable,
        From == ValuesColumns<(repeat (each Value).QueryValue)>
    {
        self.init(clauses: _SelectClauses())
        columns = $_isSelecting.withValue(true) {
            var columns: [ISO_9075.Fragment] = []
            for value in repeat each values {
                columns.append(value.queryFragment)
            }
            return columns
        }
        clauses.valuesElements = ValuesElement.elements(
            for: repeat ((each Value).QueryValue).self
        )
    }

    package init(
        valuesColumns valueColumns: [ISO_9075.Fragment],
        elements: [ValuesElement],
        from: ISO_9075.Fragment,
        isEmpty: Bool = false
    ) {
        self.init(clauses: _SelectClauses())
        self.isEmpty = isEmpty
        columns = valueColumns
        clauses.from = from
        clauses.valuesElements = elements
    }

    package var _valuesElements: [ValuesElement] {
        clauses.valuesElements
    }

    public func `where`<each C: QueryExpression>(
        @QueryFragmentBuilder<Bool>
        _ predicate: (repeat ValuesColumns<each C>) -> [ISO_9075.Fragment]
    ) -> Self
    where From == ValuesColumns<(repeat each C)> {
        var select = self
        let columns: (repeat ValuesColumns<each C>) = _valuesColumns { range in
            guard range.upperBound <= clauses.columns.count else {
                preconditionFailure("Could not determine the columns for value at position \(range.lowerBound)")
            }
            return Array(clauses.columns[range])
        }
        select.where.append(contentsOf: predicate(repeat each columns))
        return select
    }

    public func order<each C: QueryExpression>(
        @QueryFragmentBuilder<()>
        by ordering: (repeat ValuesColumns<each C>) -> [ISO_9075.Fragment]
    ) -> Self
    where From == ValuesColumns<(repeat each C)> {
        var select = self
        let columns: (repeat ValuesColumns<each C>) = _valuesColumns { range in
            range.map { "\(raw: $0 + 1)" }
        }
        select.order.append(contentsOf: ordering(repeat each columns))
        return select
    }

    package func _where(_ predicate: ISO_9075.Fragment) -> Self {
        var select = self
        select.where.append(predicate)
        return select
    }

    package func _order(_ ordering: ISO_9075.Fragment) -> Self {
        var select = self
        select.order.append(ordering)
        return select
    }
}

package func _valuesColumns<each C: QueryExpression>(
    at columns: (Range<Int>) -> [ISO_9075.Fragment]
) -> (repeat ValuesColumns<each C>) {
    var index = 0
    func column<Value: QueryExpression>(_: Value.Type) -> ValuesColumns<Value> {
        let width = Value._columnWidth
        defer { index += width }
        return ValuesColumns(columns: columns(index..<index + width))
    }
    return (repeat column((each C).self))
}

extension Select {
    public func distinct(_ isDistinct: Bool = true) -> Self {
        var select = self
        select.distinct = isDistinct
        return select
    }

    public func limit<each J: Table>(_ maxLength: (some QueryExpression<Int>)?) -> Self
    where Joins == (repeat each J) {
        _limit(maxLength?.queryFragment)
    }

    public func offset<each J: Table>(_ offset: (some QueryExpression<Int>)?) -> Self
    where Joins == (repeat each J) {
        _offset(offset?.queryFragment)
    }

    fileprivate func _limit(_ maxLength: ISO_9075.Fragment?) -> Self {
        guard let maxLength else { return self }
        var select = self
        select.limit = _LimitClause(maxLength: maxLength, offset: select.limit?.offset)
        return select
    }

    fileprivate func _offset(_ offset: ISO_9075.Fragment?) -> Self {
        guard let offset else { return self }
        var select = self
        select.limit = _LimitClause(maxLength: select.limit?.maxLength, offset: offset)
        return select
    }
}

extension Select where From: Table {
    init(isEmpty: Bool = false, where: [ISO_9075.Fragment] = []) {
        self.isEmpty = isEmpty
        self.where = `where`
    }


    public func select<each C1: QueryRepresentable, C2: QueryExpression>(
        _ selection: KeyPath<From.TableColumns, C2>
    ) -> Select<(repeat each C1, C2.QueryValue), From, ()>
    where Columns == (repeat each C1), C2.QueryValue: QueryRepresentable, Joins == () {
        select { $0[keyPath: selection] }
    }

    @_disfavoredOverload
    public func select<C: QueryExpression, each J: Table>(
        _ selection: ((From.TableColumns, repeat (each J).TableColumns)) -> C
    ) -> Select<C.QueryValue, From, Joins>
    where Columns == (), C.QueryValue: QueryRepresentable, Joins == (repeat each J) {
        _select(selection)
    }

    @_disfavoredOverload
    public func select<C: QueryExpression, each J: Table>(
        _ selection: (From.TableColumns, repeat (each J).TableColumns) -> C
    ) -> Select<C.QueryValue, From, Joins>
    where Columns == (), C.QueryValue: QueryRepresentable, Joins == (repeat each J) {
        _select(selection)
    }

    public func select<each C1: QueryRepresentable, C2: QueryExpression>(
        _ selection: (From.TableColumns) -> C2
    ) -> Select<(repeat each C1, C2.QueryValue), From, ()>
    where Columns == (repeat each C1), C2.QueryValue: QueryRepresentable, Joins == () {
        _select(selection)
    }

    public func select<each C1: QueryRepresentable, C2: QueryExpression, each J: Table>(
        _ selection: ((From.TableColumns, repeat (each J).TableColumns)) -> C2
    ) -> Select<(repeat each C1, C2.QueryValue), From, Joins>
    where Columns == (repeat each C1), C2.QueryValue: QueryRepresentable, Joins == (repeat each J) {
        _select(selection)
    }

    @_disfavoredOverload
    public func select<each C1: QueryRepresentable, C2: QueryExpression, each J: Table>(
        _ selection: (From.TableColumns, repeat (each J).TableColumns) -> C2
    ) -> Select<(repeat each C1, C2.QueryValue), From, Joins>
    where Columns == (repeat each C1), C2.QueryValue: QueryRepresentable, Joins == (repeat each J) {
        _select(selection)
    }

    public func select<
        each C1: QueryRepresentable,
        C2: QueryExpression,
        C3: QueryExpression,
        each C4: QueryExpression,
        each J: Table
    >(
        _ selection: ((From.TableColumns, repeat (each J).TableColumns)) -> (C2, C3, repeat each C4)
    ) -> Select<
        (repeat each C1, C2.QueryValue, C3.QueryValue, repeat (each C4).QueryValue),
        From,
        Joins
    >
    where
        Columns == (repeat each C1),
        C2.QueryValue: QueryRepresentable,
        C3.QueryValue: QueryRepresentable,
        repeat (each C4).QueryValue: QueryRepresentable,
        Joins == (repeat each J)
    {
        _select(selection)
    }

    @_disfavoredOverload
    public func select<
        each C1: QueryRepresentable,
        C2: QueryExpression,
        C3: QueryExpression,
        each C4: QueryExpression,
        each J: Table
    >(
        _ selection: (From.TableColumns, repeat (each J).TableColumns) -> (C2, C3, repeat each C4)
    ) -> Select<
        (repeat each C1, C2.QueryValue, C3.QueryValue, repeat (each C4).QueryValue),
        From,
        Joins
    >
    where
        Columns == (repeat each C1),
        C2.QueryValue: QueryRepresentable,
        C3.QueryValue: QueryRepresentable,
        repeat (each C4).QueryValue: QueryRepresentable,
        Joins == (repeat each J)
    {
        _select(selection)
    }

    private func _select<
        each C1: QueryRepresentable,
        each C2: QueryExpression,
        each J: Table
    >(
        _ selection: ((From.TableColumns, repeat (each J).TableColumns)) -> (repeat each C2)
    ) -> Select<(repeat each C1, repeat (each C2).QueryValue), From, (repeat each J)>
    where
        Columns == (repeat each C1),
        repeat (each C2).QueryValue: QueryRepresentable,
        Joins == (repeat each J)
    {
        Select<(repeat each C1, repeat (each C2).QueryValue), From, (repeat each J)>(
            isEmpty: isEmpty,
            distinct: distinct,
            columns: columns
                + $_isSelecting.withValue(true) {
                    Array(repeat each selection((From.columns, repeat (each J).columns)))
                },
            from: from,
            joins: joins,
            where: `where`,
            group: group,
            having: having,
            order: order,
            limit: limit
        )
    }

    @_documentation(visibility: private)
    public func join<each C1: QueryRepresentable, each C2: QueryRepresentable, F: Table>(
        _ other: some SelectStatement<(repeat each C2), F, ()>,
        on constraint: ((From.TableColumns, F.TableColumns)) -> some QueryExpression<Bool>
    ) -> Select<(repeat each C1, repeat each C2), From, F>
    where Columns == (repeat each C1), Joins == () {
        let other = other.asSelect()
        let join = _JoinClause(
            operator: nil,
            tableReference: other._tableReference,
            table: F.self,
            constraint: constraint((From.columns, F.columns))
        )
        return Select<(repeat each C1, repeat each C2), From, F>(
            isEmpty: isEmpty || other.isEmpty,
            distinct: distinct || other.distinct,
            columns: columns + other.columns,
            from: from,
            joins: joins + [join] + other.joins,
            where: `where` + other.where,
            group: group + other.group,
            having: having + other.having,
            order: order + other.order,
            limit: other.limit ?? limit
        )
    }

    public func join<
        each C1: QueryRepresentable,
        each C2: QueryRepresentable,
        F: Table,
        each J1: Table,
        each J2: Table
    >(
        _ other: some SelectStatement<(repeat each C2), F, (repeat each J2)>,
        on constraint: (
            (
                From.TableColumns, repeat (each J1).TableColumns, F.TableColumns,
                repeat (each J2).TableColumns
            )
        ) -> some QueryExpression<Bool>
    ) -> Select<(repeat each C1, repeat each C2), From, (repeat each J1, F, repeat each J2)>
    where Columns == (repeat each C1), Joins == (repeat each J1) {
        let other = other.asSelect()
        let join = _JoinClause(
            operator: nil,
            tableReference: other._tableReference,
            table: F.self,
            constraint: constraint(
                (From.columns, repeat (each J1).columns, F.columns, repeat (each J2).columns)
            )
        )
        return Select<(repeat each C1, repeat each C2), From, (repeat each J1, F, repeat each J2)>(
            isEmpty: isEmpty || other.isEmpty,
            distinct: distinct || other.distinct,
            columns: columns + other.columns,
            from: from,
            joins: joins + [join] + other.joins,
            where: `where` + other.where,
            group: group + other.group,
            having: having + other.having,
            order: order + other.order,
            limit: other.limit ?? limit
        )
    }

    package func _join<each C: QueryRepresentable, F: Table, each J: Table>(
        _ other: Select<(repeat each C), F, (repeat each J)>,
        constraint: SQLQueryExpression<Bool>
    ) -> Select<(repeat each C), From, (F, repeat each J)>
    where Columns == (), Joins == () {
        Select<(repeat each C), From, (F, repeat each J)>(
            isEmpty: isEmpty || other.isEmpty,
            distinct: distinct || other.distinct,
            columns: columns + other.columns,
            from: from,
            joins: joins
                + [
                    _JoinClause(
                        operator: nil,
                        tableReference: other._tableReference,
                        table: F.self,
                        constraint: constraint
                    )
                ] + other.joins,
            where: `where` + other.where,
            group: group + other.group,
            having: having + other.having,
            order: order + other.order,
            limit: other.limit ?? limit
        )
    }

    @_documentation(visibility: private)
    @_disfavoredOverload
    public func join<
        each C1: QueryRepresentable,
        each C2: QueryRepresentable,
        F: Table,
        each J: Table
    >(
        _ other: some SelectStatement<(repeat each C2), F, ()>,
        on constraint: (
            (From.TableColumns, repeat (each J).TableColumns, F.TableColumns)
        ) -> some QueryExpression<Bool>
    ) -> Select<(repeat each C1, repeat each C2), From, (repeat each J, F)>
    where Columns == (repeat each C1), Joins == (repeat each J) {
        let other = other.asSelect()
        let join = _JoinClause(
            operator: nil,
            tableReference: other._tableReference,
            table: F.self,
            constraint: constraint(
                (From.columns, repeat (each J).columns, F.columns)
            )
        )
        return Select<(repeat each C1, repeat each C2), From, (repeat each J, F)>(
            isEmpty: isEmpty || other.isEmpty,
            distinct: distinct || other.distinct,
            columns: columns + other.columns,
            from: from,
            joins: joins + [join] + other.joins,
            where: `where` + other.where,
            group: group + other.group,
            having: having + other.having,
            order: order + other.order,
            limit: other.limit ?? limit
        )
    }

    @_disfavoredOverload
    @_documentation(visibility: private)
    public func join<F: Table, each J: Table>(
        _ other: some SelectStatement<(), F, (repeat each J)>,
        on constraint: (
            (From.TableColumns, F.TableColumns, repeat (each J).TableColumns)
        ) -> some QueryExpression<Bool>
    ) -> Select<QueryValue, From, (F, repeat each J)> where QueryValue: QueryRepresentable {
        let other = other.asSelect()
        let join = _JoinClause(
            operator: nil,
            tableReference: other._tableReference,
            table: F.self,
            constraint: constraint(
                (From.columns, F.columns, repeat (each J).columns)
            )
        )
        return Select<QueryValue, From, (F, repeat each J)>(
            isEmpty: isEmpty || other.isEmpty,
            distinct: distinct || other.distinct,
            columns: columns + other.columns,
            from: from,
            joins: joins + [join] + other.joins,
            where: `where` + other.where,
            group: group + other.group,
            having: having + other.having,
            order: order + other.order,
            limit: other.limit ?? limit
        )
    }

    @_disfavoredOverload
    @_documentation(visibility: private)
    public func join<F: Table>(
        _ other: some SelectStatementOf<F>,
        on constraint: (
            (From.TableColumns, Joins.TableColumns, F.TableColumns)
        ) -> some QueryExpression<Bool>
    ) -> Select<(), From, (Joins, F)> where Joins: Table {
        let other = other.asSelect()
        let join = _JoinClause(
            operator: nil,
            tableReference: other._tableReference,
            table: F.self,
            constraint: constraint(
                (From.columns, Joins.columns, F.columns)
            )
        )
        return Select<(), From, (Joins, F)>(
            isEmpty: isEmpty || other.isEmpty,
            distinct: distinct || other.distinct,
            columns: columns + other.columns,
            from: from,
            joins: joins + [join] + other.joins,
            where: `where` + other.where,
            group: group + other.group,
            having: having + other.having,
            order: order + other.order,
            limit: other.limit ?? limit
        )
    }

    @_documentation(visibility: private)
    public func leftJoin<each C1: QueryRepresentable, each C2: QueryRepresentable, F: Table>(
        _ other: some SelectStatement<(repeat each C2), F, ()>,
        on constraint: ((From.TableColumns, F.TableColumns)) -> some QueryExpression<Bool>
    ) -> Select<(repeat each C1, repeat (each C2)._Optionalized), From, F._Optionalized>
    where Columns == (repeat each C1), Joins == () {
        let other = other.asSelect()
        let join = _JoinClause(
            operator: .left,
            tableReference: other._tableReference,
            table: F.self,
            constraint: constraint((From.columns, F.columns))
        )
        return Select<(repeat each C1, repeat (each C2)._Optionalized), From, F._Optionalized>(
            isEmpty: isEmpty || other.isEmpty,
            distinct: distinct || other.distinct,
            columns: columns + other.columns,
            from: from,
            joins: joins + [join] + other.joins,
            where: `where` + other.where,
            group: group + other.group,
            having: having + other.having,
            order: order + other.order,
            limit: other.limit ?? limit
        )
    }

    public func leftJoin<
        each C1: QueryRepresentable,
        each C2: QueryRepresentable,
        F: Table,
        each J1: Table,
        each J2: Table
    >(
        _ other: some SelectStatement<(repeat each C2), F, (repeat each J2)>,
        on constraint: (
            (
                From.TableColumns, repeat (each J1).TableColumns, F.TableColumns,
                repeat (each J2).TableColumns
            )
        ) -> some QueryExpression<Bool>
    ) -> Select<
        (repeat each C1, repeat (each C2)._Optionalized),
        From,
        (repeat each J1, F._Optionalized, repeat (each J2)._Optionalized)
    >
    where Columns == (repeat each C1), Joins == (repeat each J1) {
        let other = other.asSelect()
        let join = _JoinClause(
            operator: .left,
            tableReference: other._tableReference,
            table: F.self,
            constraint: constraint(
                (From.columns, repeat (each J1).columns, F.columns, repeat (each J2).columns)
            )
        )
        return Select<
            (repeat each C1, repeat (each C2)._Optionalized),
            From,
            (repeat each J1, F._Optionalized, repeat (each J2)._Optionalized)
        >(
            isEmpty: isEmpty || other.isEmpty,
            distinct: distinct || other.distinct,
            columns: columns + other.columns,
            from: from,
            joins: joins + [join] + other.joins,
            where: `where` + other.where,
            group: group + other.group,
            having: having + other.having,
            order: order + other.order,
            limit: other.limit ?? limit
        )
    }

    @_disfavoredOverload
    @_documentation(visibility: private)
    public func leftJoin<
        each C1: QueryRepresentable,
        each C2: QueryRepresentable,
        F: Table,
        each J: Table
    >(
        _ other: some SelectStatement<(repeat each C2), F, ()>,
        on constraint: (
            (From.TableColumns, repeat (each J).TableColumns, F.TableColumns)
        ) -> some QueryExpression<Bool>
    ) -> Select<
        (repeat each C1, repeat (each C2)._Optionalized),
        From,
        (repeat each J, F._Optionalized)
    >
    where Columns == (repeat each C1), Joins == (repeat each J) {
        let other = other.asSelect()
        let join = _JoinClause(
            operator: .left,
            tableReference: other._tableReference,
            table: F.self,
            constraint: constraint(
                (From.columns, repeat (each J).columns, F.columns)
            )
        )
        return Select<
            (repeat each C1, repeat (each C2)._Optionalized),
            From,
            (repeat each J, F._Optionalized)
        >(
            isEmpty: isEmpty || other.isEmpty,
            distinct: distinct || other.distinct,
            columns: columns + other.columns,
            from: from,
            joins: joins + [join] + other.joins,
            where: `where` + other.where,
            group: group + other.group,
            having: having + other.having,
            order: order + other.order,
            limit: other.limit ?? limit
        )
    }

    @_disfavoredOverload
    @_documentation(visibility: private)
    public func leftJoin<F: Table, each J: Table>(
        _ other: some SelectStatement<(), F, (repeat each J)>,
        on constraint: (
            (From.TableColumns, F.TableColumns, repeat (each J).TableColumns)
        ) -> some QueryExpression<Bool>
    ) -> Select<QueryValue, From, (F._Optionalized, repeat (each J)._Optionalized)>
    where QueryValue: QueryRepresentable {
        let other = other.asSelect()
        let join = _JoinClause(
            operator: .left,
            tableReference: other._tableReference,
            table: F.self,
            constraint: constraint(
                (From.columns, F.columns, repeat (each J).columns)
            )
        )
        return Select<QueryValue, From, (F._Optionalized, repeat (each J)._Optionalized)>(
            isEmpty: isEmpty || other.isEmpty,
            distinct: distinct || other.distinct,
            columns: columns + other.columns,
            from: from,
            joins: joins + [join] + other.joins,
            where: `where` + other.where,
            group: group + other.group,
            having: having + other.having,
            order: order + other.order,
            limit: other.limit ?? limit
        )
    }

    @_disfavoredOverload
    @_documentation(visibility: private)
    public func leftJoin<F: Table>(
        _ other: some SelectStatementOf<F>,
        on constraint: (
            (From.TableColumns, Joins.TableColumns, F.TableColumns)
        ) -> some QueryExpression<Bool>
    ) -> Select<(), From, (Joins, F._Optionalized)>
    where Joins: Table {
        let other = other.asSelect()
        let join = _JoinClause(
            operator: .left,
            tableReference: other._tableReference,
            table: F.self,
            constraint: constraint(
                (From.columns, Joins.columns, F.columns)
            )
        )
        return Select<(), From, (Joins, F._Optionalized)>(
            isEmpty: isEmpty || other.isEmpty,
            distinct: distinct || other.distinct,
            columns: columns + other.columns,
            from: from,
            joins: joins + [join] + other.joins,
            where: `where` + other.where,
            group: group + other.group,
            having: having + other.having,
            order: order + other.order,
            limit: other.limit ?? limit
        )
    }

    @_documentation(visibility: private)
    public func rightJoin<each C1: QueryRepresentable, each C2: QueryRepresentable, F: Table>(
        _ other: some SelectStatement<(repeat each C2), F, ()>,
        on constraint: ((From.TableColumns, F.TableColumns)) -> some QueryExpression<Bool>
    ) -> Select<(repeat each C1, repeat each C2), From._Optionalized, F>
    where Columns == (repeat each C1), Joins == () {
        let other = other.asSelect()
        let join = _JoinClause(
            operator: .right,
            tableReference: other._tableReference,
            table: F.self,
            constraint: constraint((From.columns, F.columns))
        )
        return Select<(repeat each C1, repeat each C2), From._Optionalized, F>(
            isEmpty: isEmpty || other.isEmpty,
            distinct: distinct || other.distinct,
            columns: columns + other.columns,
            from: from,
            joins: joins + [join] + other.joins,
            where: `where` + other.where,
            group: group + other.group,
            having: having + other.having,
            order: order + other.order,
            limit: other.limit ?? limit
        )
    }

    public func rightJoin<
        each C1: QueryRepresentable,
        each C2: QueryRepresentable,
        F: Table,
        each J1: Table,
        each J2: Table
    >(
        _ other: some SelectStatement<(repeat each C2), F, (repeat each J2)>,
        on constraint: (
            (
                From.TableColumns, repeat (each J1).TableColumns, F.TableColumns,
                repeat (each J2).TableColumns
            )
        ) -> some QueryExpression<Bool>
    ) -> Select<
        (repeat (each C1)._Optionalized, repeat each C2),
        From._Optionalized,
        (repeat (each J1)._Optionalized, F, repeat each J2)
    >
    where Columns == (repeat each C1), Joins == (repeat each J1) {
        let other = other.asSelect()
        let join = _JoinClause(
            operator: .right,
            tableReference: other._tableReference,
            table: F.self,
            constraint: constraint(
                (From.columns, repeat (each J1).columns, F.columns, repeat (each J2).columns)
            )
        )
        return Select<
            (repeat (each C1)._Optionalized, repeat each C2),
            From._Optionalized,
            (repeat (each J1)._Optionalized, F, repeat each J2)
        >(
            isEmpty: isEmpty || other.isEmpty,
            distinct: distinct || other.distinct,
            columns: columns + other.columns,
            from: from,
            joins: joins + [join] + other.joins,
            where: `where` + other.where,
            group: group + other.group,
            having: having + other.having,
            order: order + other.order,
            limit: other.limit ?? limit
        )
    }

    @_disfavoredOverload
    @_documentation(visibility: private)
    public func rightJoin<
        each C1: QueryRepresentable,
        each C2: QueryRepresentable,
        F: Table,
        each J: Table
    >(
        _ other: some SelectStatement<(repeat each C2), F, ()>,
        on constraint: (
            (From.TableColumns, repeat (each J).TableColumns, F.TableColumns)
        ) -> some QueryExpression<Bool>
    ) -> Select<
        (repeat (each C1)._Optionalized, repeat each C2),
        From._Optionalized,
        (repeat (each J)._Optionalized, F)
    >
    where Columns == (repeat each C1), Joins == (repeat each J) {
        let other = other.asSelect()
        let join = _JoinClause(
            operator: .right,
            tableReference: other._tableReference,
            table: F.self,
            constraint: constraint(
                (From.columns, repeat (each J).columns, F.columns)
            )
        )
        return Select<
            (repeat (each C1)._Optionalized, repeat each C2),
            From._Optionalized,
            (repeat (each J)._Optionalized, F)
        >(
            isEmpty: isEmpty || other.isEmpty,
            distinct: distinct || other.distinct,
            columns: columns + other.columns,
            from: from,
            joins: joins + [join] + other.joins,
            where: `where` + other.where,
            group: group + other.group,
            having: having + other.having,
            order: order + other.order,
            limit: other.limit ?? limit
        )
    }

    @_disfavoredOverload
    @_documentation(visibility: private)
    public func rightJoin<F: Table, each J: Table>(
        _ other: some SelectStatement<(), F, (repeat each J)>,
        on constraint: (
            (From.TableColumns, F.TableColumns, repeat (each J).TableColumns)
        ) -> some QueryExpression<Bool>
    ) -> Select<QueryValue, From._Optionalized, (F, repeat each J)>
    where QueryValue: QueryRepresentable {
        let other = other.asSelect()
        let join = _JoinClause(
            operator: .right,
            tableReference: other._tableReference,
            table: F.self,
            constraint: constraint(
                (From.columns, F.columns, repeat (each J).columns)
            )
        )
        return Select<QueryValue, From._Optionalized, (F, repeat each J)>(
            isEmpty: isEmpty || other.isEmpty,
            distinct: distinct || other.distinct,
            columns: columns + other.columns,
            from: from,
            joins: joins + [join] + other.joins,
            where: `where` + other.where,
            group: group + other.group,
            having: having + other.having,
            order: order + other.order,
            limit: other.limit ?? limit
        )
    }

    @_disfavoredOverload
    @_documentation(visibility: private)
    public func rightJoin<F: Table>(
        _ other: some SelectStatementOf<F>,
        on constraint: (
            (From.TableColumns, Joins.TableColumns, F.TableColumns)
        ) -> some QueryExpression<Bool>
    ) -> Select<(), From._Optionalized, (Joins._Optionalized, F)>
    where Joins: Table {
        let other = other.asSelect()
        let join = _JoinClause(
            operator: .right,
            tableReference: other._tableReference,
            table: F.self,
            constraint: constraint(
                (From.columns, Joins.columns, F.columns)
            )
        )
        return Select<(), From._Optionalized, (Joins._Optionalized, F)>(
            isEmpty: isEmpty || other.isEmpty,
            distinct: distinct || other.distinct,
            columns: columns + other.columns,
            from: from,
            joins: joins + [join] + other.joins,
            where: `where` + other.where,
            group: group + other.group,
            having: having + other.having,
            order: order + other.order,
            limit: other.limit ?? limit
        )
    }

    @_documentation(visibility: private)
    public func fullJoin<each C1: QueryRepresentable, each C2: QueryRepresentable, F: Table>(
        _ other: some SelectStatement<(repeat each C2), F, ()>,
        on constraint: ((From.TableColumns, F.TableColumns)) -> some QueryExpression<Bool>
    ) -> Select<
        (repeat (each C1)._Optionalized, repeat (each C2)._Optionalized), From._Optionalized,
        F._Optionalized
    >
    where Columns == (repeat each C1), Joins == () {
        let other = other.asSelect()
        let join = _JoinClause(
            operator: .full,
            tableReference: other._tableReference,
            table: F.self,
            constraint: constraint((From.columns, F.columns))
        )
        return Select<
            (repeat (each C1)._Optionalized, repeat (each C2)._Optionalized), From._Optionalized,
            F._Optionalized
        >(
            isEmpty: isEmpty || other.isEmpty,
            distinct: distinct || other.distinct,
            columns: columns + other.columns,
            from: from,
            joins: joins + [join] + other.joins,
            where: `where` + other.where,
            group: group + other.group,
            having: having + other.having,
            order: order + other.order,
            limit: other.limit ?? limit
        )
    }

    public func fullJoin<
        each C1: QueryRepresentable,
        each C2: QueryRepresentable,
        F: Table,
        each J1: Table,
        each J2: Table
    >(
        _ other: some SelectStatement<(repeat each C2), F, (repeat each J2)>,
        on constraint: (
            (
                From.TableColumns, repeat (each J1).TableColumns, F.TableColumns,
                repeat (each J2).TableColumns
            )
        ) -> some QueryExpression<Bool>
    ) -> Select<
        (repeat (each C1)._Optionalized, repeat (each C2)._Optionalized),
        From._Optionalized,
        (repeat (each J1)._Optionalized, F._Optionalized, repeat (each J2)._Optionalized)
    >
    where Columns == (repeat each C1), Joins == (repeat each J1) {
        let other = other.asSelect()
        let join = _JoinClause(
            operator: .full,
            tableReference: other._tableReference,
            table: F.self,
            constraint: constraint(
                (From.columns, repeat (each J1).columns, F.columns, repeat (each J2).columns)
            )
        )
        return Select<
            (repeat (each C1)._Optionalized, repeat (each C2)._Optionalized),
            From._Optionalized,
            (repeat (each J1)._Optionalized, F._Optionalized, repeat (each J2)._Optionalized)
        >(
            isEmpty: isEmpty || other.isEmpty,
            distinct: distinct || other.distinct,
            columns: columns + other.columns,
            from: from,
            joins: joins + [join] + other.joins,
            where: `where` + other.where,
            group: group + other.group,
            having: having + other.having,
            order: order + other.order,
            limit: other.limit ?? limit
        )
    }

    @_disfavoredOverload
    @_documentation(visibility: private)
    public func fullJoin<
        each C1: QueryRepresentable,
        each C2: QueryRepresentable,
        F: Table,
        each J: Table
    >(
        _ other: some SelectStatement<(repeat each C2), F, ()>,
        on constraint: (
            (From.TableColumns, repeat (each J).TableColumns, F.TableColumns)
        ) -> some QueryExpression<Bool>
    ) -> Select<
        (repeat (each C1)._Optionalized, repeat (each C2)._Optionalized),
        From._Optionalized,
        (repeat (each J)._Optionalized, F._Optionalized)
    >
    where Columns == (repeat each C1), Joins == (repeat each J) {
        let other = other.asSelect()
        let join = _JoinClause(
            operator: .full,
            tableReference: other._tableReference,
            table: F.self,
            constraint: constraint(
                (From.columns, repeat (each J).columns, F.columns)
            )
        )
        return Select<
            (repeat (each C1)._Optionalized, repeat (each C2)._Optionalized),
            From._Optionalized,
            (repeat (each J)._Optionalized, F._Optionalized)
        >(
            isEmpty: isEmpty || other.isEmpty,
            distinct: distinct || other.distinct,
            columns: columns + other.columns,
            from: from,
            joins: joins + [join] + other.joins,
            where: `where` + other.where,
            group: group + other.group,
            having: having + other.having,
            order: order + other.order,
            limit: other.limit ?? limit
        )
    }

    @_disfavoredOverload
    @_documentation(visibility: private)
    public func fullJoin<F: Table, each J: Table>(
        _ other: some SelectStatement<(), F, (repeat each J)>,
        on constraint: (
            (From.TableColumns, F.TableColumns, repeat (each J).TableColumns)
        ) -> some QueryExpression<Bool>
    ) -> Select<QueryValue, From._Optionalized, (F._Optionalized, repeat (each J)._Optionalized)>
    where QueryValue: QueryRepresentable {
        let other = other.asSelect()
        let join = _JoinClause(
            operator: .full,
            tableReference: other._tableReference,
            table: F.self,
            constraint: constraint(
                (From.columns, F.columns, repeat (each J).columns)
            )
        )
        return Select<
            QueryValue, From._Optionalized, (F._Optionalized, repeat (each J)._Optionalized)
        >(
            isEmpty: isEmpty || other.isEmpty,
            distinct: distinct || other.distinct,
            columns: columns + other.columns,
            from: from,
            joins: joins + [join] + other.joins,
            where: `where` + other.where,
            group: group + other.group,
            having: having + other.having,
            order: order + other.order,
            limit: other.limit ?? limit
        )
    }

    @_disfavoredOverload
    @_documentation(visibility: private)
    public func fullJoin<F: Table>(
        _ other: some SelectStatementOf<F>,
        on constraint: (
            (From.TableColumns, Joins.TableColumns, F.TableColumns)
        ) -> some QueryExpression<Bool>
    ) -> Select<(), From._Optionalized, (Joins._Optionalized, F._Optionalized)>
    where Joins: Table {
        let other = other.asSelect()
        let join = _JoinClause(
            operator: .full,
            tableReference: other._tableReference,
            table: F.self,
            constraint: constraint(
                (From.columns, Joins.columns, F.columns)
            )
        )
        return Select<(), From._Optionalized, (Joins._Optionalized, F._Optionalized)>(
            isEmpty: isEmpty || other.isEmpty,
            distinct: distinct || other.distinct,
            columns: columns + other.columns,
            from: from,
            joins: joins + [join] + other.joins,
            where: `where` + other.where,
            group: group + other.group,
            having: having + other.having,
            order: order + other.order,
            limit: other.limit ?? limit
        )
    }

    public func `where`(
        _ keyPath: KeyPath<From.TableColumns, some QueryExpression<some _OptionalPromotable<Bool?>>>
    ) -> Self
    where Joins == () {
        var select = self
        select.where.append(From.columns[keyPath: keyPath].queryFragment)
        return select
    }

    @_disfavoredOverload
    public func `where`<each J: Table>(
        _ predicate: (From.TableColumns, repeat (each J).TableColumns) -> some QueryExpression<
            some _OptionalPromotable<Bool?>
        >
    ) -> Self
    where Joins == (repeat each J) {
        var select = self
        select.where.append(predicate(From.columns, repeat (each J).columns).queryFragment)
        return select
    }

    public func `where`<each J: Table>(
        @QueryFragmentBuilder<Bool>
        _ predicate: (From.TableColumns, repeat (each J).TableColumns) -> [ISO_9075.Fragment]
    ) -> Self
    where Joins == (repeat each J) {
        var select = self
        select.where.append(contentsOf: predicate(From.columns, repeat (each J).columns))
        return select
    }

    @_disfavoredOverload
    public func `where`(
        _ predicate: (From.TableColumns, Joins.TableColumns) -> some QueryExpression<
            some _OptionalPromotable<Bool?>
        >
    ) -> Self
    where Joins: Table {
        var select = self
        select.where.append(predicate(From.columns, Joins.columns).queryFragment)
        return select
    }

    public func `where`(
        @QueryFragmentBuilder<Bool>
        _ predicate: (From.TableColumns, Joins.TableColumns) -> [ISO_9075.Fragment]
    ) -> Self
    where Joins: Table {
        var select = self
        select.where.append(contentsOf: predicate(From.columns, Joins.columns))
        return select
    }

    public func and(_ other: Where<From>) -> Self {
        var select = self
        select.where = (select.where + other.predicates).removingDuplicates()
        return select
    }

    public func or(_ other: Where<From>) -> Self {
        var select = self
        if select.where.isEmpty {
            select.where = other.predicates
        } else {
            select.where = [
                """
                (\(select.where.joined(separator: " AND ")) \
                OR \
                \(other.predicates.joined(separator: " AND ")))
                """
            ]
        }
        return select
    }

    @_disfavoredOverload
    public func group<C: QueryExpression, each J: Table>(
        by grouping: (From.TableColumns, repeat (each J).TableColumns) -> C
    ) -> Self where Joins == (repeat each J) {
        _group(by: grouping)
    }

    public func group<
        C1: QueryExpression,
        C2: QueryExpression,
        each C3: QueryExpression,
        each J: Table
    >(
        by grouping: (From.TableColumns, repeat (each J).TableColumns) -> (C1, C2, repeat each C3)
    ) -> Self where Joins == (repeat each J) {
        _group(by: grouping)
    }

    public func group<C: QueryExpression>(
        by grouping: (From.TableColumns, Joins.TableColumns) -> C
    ) -> Self where Joins: Table {
        _group(by: grouping)
    }

    public func group<
        C1: QueryExpression,
        C2: QueryExpression,
        each C3: QueryExpression
    >(
        by grouping: (From.TableColumns, Joins.TableColumns) -> (C1, C2, repeat each C3)
    ) -> Self where Joins: Table {
        _group(by: grouping)
    }

    @_disfavoredOverload
    private func _group<
        each C: QueryExpression,
        each J: Table
    >(
        by grouping: (From.TableColumns, repeat (each J).TableColumns) -> (repeat each C)
    ) -> Self where Joins == (repeat each J) {
        var select = self
        select.group
            .append(
                contentsOf: Array(repeat each grouping(From.columns, repeat (each J).columns))
            )
        return select
    }

    private func _group<each C: QueryExpression>(
        by grouping: (From.TableColumns, Joins.TableColumns) -> (repeat each C)
    ) -> Self where Joins: Table {
        var select = self
        select.group
            .append(
                contentsOf: Array(repeat each grouping(From.columns, Joins.columns))
            )
        return select
    }

    @_disfavoredOverload
    public func having<each J: Table>(
        _ predicate: (From.TableColumns, repeat (each J).TableColumns) -> some QueryExpression<
            some _OptionalPromotable<Bool?>
        >
    ) -> Self
    where Joins == (repeat each J) {
        var select = self
        select.having.append(predicate(From.columns, repeat (each J).columns).queryFragment)
        return select
    }

    public func having<each J: Table>(
        @QueryFragmentBuilder<Bool>
        _ predicate: (From.TableColumns, repeat (each J).TableColumns) -> [ISO_9075.Fragment]
    ) -> Self
    where Joins == (repeat each J) {
        var select = self
        select.having.append(contentsOf: predicate(From.columns, repeat (each J).columns))
        return select
    }

    @_disfavoredOverload
    public func having(
        _ predicate: (From.TableColumns, Joins.TableColumns) -> some QueryExpression<
            some _OptionalPromotable<Bool?>
        >
    ) -> Self
    where Joins: Table {
        var select = self
        select.having.append(predicate(From.columns, Joins.columns).queryFragment)
        return select
    }

    public func having(
        @QueryFragmentBuilder<Bool>
        _ predicate: (From.TableColumns, Joins.TableColumns) -> [ISO_9075.Fragment]
    ) -> Self
    where Joins: Table {
        var select = self
        select.having.append(contentsOf: predicate(From.columns, Joins.columns))
        return select
    }

    public func order(by ordering: KeyPath<From.TableColumns, some QueryExpression>) -> Self
    where Joins == () {
        var select = self
        select.order.append(From.columns[keyPath: ordering].queryFragment)
        return select
    }

    public func order<each J: Table>(
        @QueryFragmentBuilder<()>
        by ordering: (From.TableColumns, repeat (each J).TableColumns) -> [ISO_9075.Fragment]
    ) -> Self
    where Joins == (repeat each J) {
        var select = self
        select.order.append(contentsOf: ordering(From.columns, repeat (each J).columns))
        return select
    }

    public func order(
        @QueryFragmentBuilder<()>
        by ordering: (From.TableColumns, Joins.TableColumns) -> [ISO_9075.Fragment]
    ) -> Self
    where Joins: Table {
        var select = self
        select.order.append(contentsOf: ordering(From.columns, Joins.columns))
        return select
    }

    public func limit<each J: Table>(
        @QueryFragmentBuilder<Int>
        _ maxLength: (From.TableColumns, repeat (each J).TableColumns) -> [ISO_9075.Fragment]
    ) -> Self
    where Joins == (repeat each J) {
        _limit(maxLength(From.columns, repeat (each J).columns).last)
    }

    public func limit(
        @QueryFragmentBuilder<Int>
        _ maxLength: (From.TableColumns, Joins.TableColumns) -> [ISO_9075.Fragment]
    ) -> Self
    where Joins: Table {
        _limit(maxLength(From.columns, Joins.columns).last)
    }

    public func offset<each J: Table>(
        @QueryFragmentBuilder<Int>
        _ offset: (From.TableColumns, repeat (each J).TableColumns) -> [ISO_9075.Fragment]
    ) -> Self
    where Joins == (repeat each J) {
        _offset(offset(From.columns, repeat (each J).columns).last)
    }

    public func offset(
        @QueryFragmentBuilder<Int>
        _ offset: (From.TableColumns, Joins.TableColumns) -> [ISO_9075.Fragment]
    ) -> Self
    where Joins: Table {
        _offset(offset(From.columns, Joins.columns).last)
    }

    public func count<each J: Table>() -> Select<Int, From, Joins>
    where Columns == (), Joins == (repeat each J) {
        select { _ in .count() }
    }

    public func count<each J: Table, Filter: QueryExpression<Bool>>(
        filter: (From.TableColumns, repeat (each J).TableColumns) -> Filter
    ) -> Select<Int, From, Joins>
    where Columns == (), Joins == (repeat each J) {
        let filter = filter(From.columns, repeat (each J).columns)
        return select { _ in .count(filter: filter) }
    }

    public func count<each C: QueryRepresentable, each J: Table>() -> Select<
        (repeat each C, Int), From, (repeat each J)
    >
    where Columns == (repeat each C), Joins == (repeat each J) {
        select { _ in .count() }
    }

    public func count<each C: QueryRepresentable, each J: Table, Filter: QueryExpression<Bool>>(
        filter: (From.TableColumns, repeat (each J).TableColumns) -> Filter
    ) -> Select<
        (repeat each C, Int), From, (repeat each J)
    >
    where Columns == (repeat each C), Joins == (repeat each J) {
        let filter = filter(From.columns, repeat (each J).columns)
        return select { _ in .count(filter: filter) }
    }

    public func count() -> Select<Int, From, Joins>
    where Columns == (), Joins: Table {
        select { _, _ in .count() }
    }

    public func count<Filter: QueryExpression<Bool>>(
        filter: (From.TableColumns, Joins.TableColumns) -> Filter
    ) -> Select<Int, From, Joins>
    where Columns == (), Joins: Table {
        let filter = filter(From.columns, Joins.columns)
        return select { _, _ in .count(filter: filter) }
    }

    public func count<each C: QueryRepresentable>() -> Select<
        (repeat each C, Int), From, Joins
    >
    where Columns == (repeat each C), Joins: Table {
        select { _, _ in .count() }
    }

    public func count<each C: QueryRepresentable, Filter: QueryExpression<Bool>>(
        filter: (From.TableColumns, Joins.TableColumns) -> Filter
    ) -> Select<
        (repeat each C, Int), From, Joins
    >
    where Columns == (repeat each C), Joins: Table {
        let filter = filter(From.columns, Joins.columns)
        return select { _, _ in .count(filter: filter) }
    }

    public func map<each C1: QueryRepresentable, each C2: QueryExpression>(
        _ transform: (repeat SQLQueryExpression<each C1>) -> (repeat each C2)
    ) -> Select<(repeat (each C2).QueryValue), From, Joins>
    where
        QueryValue == (repeat each C1),
        repeat (each C2).QueryValue: QueryRepresentable
    {
        var iterator = columns.makeIterator()
        func next<Element>() -> SQLQueryExpression<Element> {
            SQLQueryExpression(iterator.next()!)
        }
        return Select<(repeat (each C2).QueryValue), From, Joins>(
            isEmpty: isEmpty,
            distinct: distinct,
            columns: Array(repeat each transform(repeat { _ in next() }((each C1).self))),
            from: from,
            joins: joins,
            where: `where`,
            group: group,
            having: having,
            order: order,
            limit: limit
        )
    }

    public var unscoped: Where<From> {
        From.unscoped
    }

    public var all: Self {
        self
    }

    public var none: Self {
        var select = self
        select.isEmpty = true
        return select
    }
}

public func + <
    each C1: QueryRepresentable,
    each C2: QueryRepresentable,
    From: Table,
    each J1: Table,
    each J2: Table
>(
    lhs: some SelectStatement<(repeat each C1), From, (repeat each J1)>,
    rhs: some SelectStatement<(repeat each C2), From, (repeat each J2)>
) -> Select<
    (repeat each C1, repeat each C2), From, (repeat each J1, repeat each J2)
> {
    let lhs = lhs.asSelect()
    let rhs = rhs.asSelect()
    return Select<
        (repeat each C1, repeat each C2), From, (repeat each J1, repeat each J2)
    >(
        isEmpty: lhs.isEmpty || rhs.isEmpty,
        distinct: lhs.distinct || rhs.distinct,
        columns: lhs.columns + rhs.columns,
        from: rhs.from ?? lhs.from,
        joins: lhs.joins + rhs.joins,
        where: (lhs.where + rhs.where).removingDuplicates(),
        group: (lhs.group + rhs.group).removingDuplicates(),
        having: (lhs.having + rhs.having).removingDuplicates(),
        order: (lhs.order + rhs.order).removingDuplicates(),
        limit: rhs.limit ?? lhs.limit
    )
}

extension SelectStatement {
    public func `as`<Name: AliasName>(
        _ alias: Name.Type
    ) -> Select<QueryValue, TableAlias<From, Name>, Joins> {
        Select(clauses: asSelect().clauses.aliasing(From.self, as: Name.self))
    }
}

extension _SelectClauses {
    fileprivate func aliasing<T: Table, Name: AliasName>(
        _ table: T.Type,
        as alias: Name.Type
    ) -> Self {
        var clauses = self
        clauses.columns = columns.map { $0.aliasing(table, as: alias) }
        clauses.from = from.map { $0.aliasing(table, as: alias) }
        clauses.joins = joins.map { $0.aliasing(table, as: alias) }
        clauses.where = `where`.map { $0.aliasing(table, as: alias) }
        clauses.group = group.map { $0.aliasing(table, as: alias) }
        clauses.having = having.map { $0.aliasing(table, as: alias) }
        clauses.order = order.map { $0.aliasing(table, as: alias) }
        clauses.limit = limit.map { $0.aliasing(table, as: alias) }
        return clauses
    }
}

@TaskLocal public var _isSelecting = false

extension Select: SelectStatement where From: Table {
    public var _selectClauses: _SelectClauses {
        clauses
    }
}

extension Select: PartialSelectStatement {
    public typealias QueryValue = Columns

    var _rendersFromClause: Bool {
        clauses.from != nil || From._fromTable != nil
    }

    public var query: ISO_9075.Fragment {
        guard !isEmpty else { return "" }
        var query: ISO_9075.Fragment = "SELECT"
        let fromTable = From._fromTable
        let columns =
            columns.isEmpty
            ? $_isSelecting.withValue(true) { fromTable.map { [$0.columns] } ?? [] }
                + joins.map { $0.tableColumns }
            : columns
        if distinct {
            query.append(" DISTINCT")
        }
        query.append(" \(columns.joined(separator: ", "))")
        if _rendersFromClause {
            query.append("\(.newlineOrSpace)FROM ")
            if let tableReference = clauses.from {
                query.append(tableReference)
            } else if let fromTable {
                query.append(fromTable.reference)
            }
        }
        if let tableAlias = fromTable?.alias {
            query.append(" AS \(quote: tableAlias)")
        }
        for join in joins {
            query.append("\(.newlineOrSpace)\(join)")
        }
        if !`where`.isEmpty {
            let `where`: ISO_9075.Fragment = `where`.map { "(\($0))" }.joined(separator: " AND ")
            query.append("\(.newlineOrSpace)WHERE \(`where`)")
        }
        if !group.isEmpty {
            query.append("\(.newlineOrSpace)GROUP BY \(group.joined(separator: ", "))")
        }
        if !having.isEmpty {
            let having: ISO_9075.Fragment = having.map { "(\($0))" }.joined(separator: " AND ")
            query.append("\(.newlineOrSpace)HAVING \(having)")
        }
        if !order.isEmpty {
            query.append("\(.newlineOrSpace)ORDER BY \(order.joined(separator: ", "))")
        }
        if let limit {
            query.append("\(.newlineOrSpace)\(limit)")
        }
        return query
    }
}

public typealias SelectOf<From: Table, each Join: Table> =
    Select<(), From, (repeat each Join)>

public struct _JoinClause: QueryExpression, Sendable {
    public typealias QueryValue = Never

    struct Operator {
        static let full = Self(queryFragment: "FULL")
        static let inner = Self(queryFragment: "INNER")
        static let left = Self(queryFragment: "LEFT")
        static let right = Self(queryFragment: "RIGHT")
        let queryFragment: ISO_9075.Fragment
    }

    let constraint: ISO_9075.Fragment
    let `operator`: ISO_9075.Fragment?
    let tableAlias: String?
    let tableColumns: ISO_9075.Fragment
    let tableReference: ISO_9075.Fragment

    init<T: Table>(
        operator: Operator?,
        tableReference: ISO_9075.Fragment? = nil,
        table: T.Type,
        constraint: some QueryExpression<Bool>
    ) {
        self.constraint = constraint.queryFragment
        self.operator = `operator`?.queryFragment
        tableAlias = table.tableAlias
        tableColumns = $_isSelecting.withValue(true) { table.columns.queryFragment }
        self.tableReference = tableReference ?? table.tableFragment
    }

    public var queryFragment: ISO_9075.Fragment {
        var query: ISO_9075.Fragment = ""
        if let `operator` {
            query.append("\(`operator`) ")
        }
        query.append("JOIN \(tableReference) ")
        if let tableAlias = tableAlias {
            query.append("AS \(quote: tableAlias) ")
        }
        query.append("ON \(constraint)")
        return query
    }

    private init(
        constraint: ISO_9075.Fragment,
        operator: ISO_9075.Fragment?,
        tableAlias: String?,
        tableColumns: ISO_9075.Fragment,
        tableReference: ISO_9075.Fragment
    ) {
        self.constraint = constraint
        self.operator = `operator`
        self.tableAlias = tableAlias
        self.tableColumns = tableColumns
        self.tableReference = tableReference
    }

    fileprivate func aliasing<T: Table, Name: AliasName>(
        _ table: T.Type,
        as alias: Name.Type
    ) -> Self {
        Self(
            constraint: constraint.aliasing(table, as: alias),
            operator: `operator`,
            tableAlias: tableAlias,
            tableColumns: tableColumns.aliasing(table, as: alias),
            tableReference: tableReference.aliasing(table, as: alias)
        )
    }
}

public struct _LimitClause: QueryExpression, Sendable {
    public typealias QueryValue = Never

    let maxLength: ISO_9075.Fragment?
    let offset: ISO_9075.Fragment?

    public var queryFragment: ISO_9075.Fragment {
        var query: ISO_9075.Fragment = "LIMIT \(maxLength ?? "-1")"
        if let offset {
            query.append(" OFFSET \(offset)")
        }
        return query
    }

    fileprivate func aliasing<T: Table, Name: AliasName>(
        _ table: T.Type,
        as alias: Name.Type
    ) -> Self {
        Self(
            maxLength: maxLength.map { $0.aliasing(table, as: alias) },
            offset: offset.map { $0.aliasing(table, as: alias) }
        )
    }
}

@propertyWrapper
private struct CopyOnWrite<Value> {
    final class Storage {
        var value: Value
        init(value: Value) {
            self.value = value
        }
    }
    var storage: Storage
    init(wrappedValue: Value) {
        self.storage = Storage(value: wrappedValue)
    }
    var wrappedValue: Value {
        get { storage.value }
        set {
            if isKnownUniquelyReferenced(&storage) {
                storage.value = newValue
            } else {
                storage = Storage(value: newValue)
            }
        }
    }
}

extension CopyOnWrite: Sendable where Value: Sendable {}

extension CopyOnWrite.Storage: @unchecked Sendable where Value: Sendable {}
