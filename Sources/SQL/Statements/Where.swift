public import ISO_9075_Foundation

extension Table {
    public static func `where`(
        _ keyPath: KeyPath<TableColumns, some QueryExpression<some _OptionalPromotable<Bool?>>>
    ) -> Where<Self> {
        Where(predicates: [columns[keyPath: keyPath].queryFragment])
    }

    @_disfavoredOverload
    public static func `where`(
        _ predicate: (TableColumns) -> some QueryExpression<some _OptionalPromotable<Bool?>>
    ) -> Where<Self> {
        Where(predicates: [predicate(columns).queryFragment])
    }

    public static func `where`(
        @QueryFragmentBuilder<Bool> _ predicate: (TableColumns) -> [ISO_9075.Fragment]
    ) -> Where<Self> {
        Where(predicates: predicate(columns))
    }
}

    @dynamicMemberLookup
public struct Where<From: Table>: Sendable {
    public static func + (lhs: Self, rhs: Self) -> Self {
        Where(predicates: (lhs.predicates + rhs.predicates).removingDuplicates())
    }

    var predicates: [ISO_9075.Fragment]
    var scope: Scope

    package init(predicates: [ISO_9075.Fragment] = [], scope: Scope = .default) {
        self.predicates = predicates
        self.scope = scope
    }

        public static subscript(dynamicMember keyPath: KeyPath<From.Type, Self>) -> Self {
            From.self[keyPath: keyPath]
        }

        public subscript<each C: QueryRepresentable, each J: Table>(
            dynamicMember keyPath: KeyPath<
                From.Type, Select<(repeat each C), From, (repeat each J)>
            >
        ) -> Select<(repeat each C), From, (repeat each J)> {
            self + From.self[keyPath: keyPath]
        }

        public subscript(dynamicMember keyPath: KeyPath<From.Type, Self>) -> Self {
            self + From.self[keyPath: keyPath]
        }

        public subscript(
            dynamicMember keyPath: KeyPath<From.SourceTable.Type, Where<From.SourceTable>>
        ) -> Self
        where From: TableDraft {
            self + unsafeBitCast(From.SourceTable.self[keyPath: keyPath], to: Self.self)
        }
}

extension Where: SelectStatement {
    public typealias QueryValue = ()

    public func asSelect() -> SelectOf<From> {
        let select: SelectOf<From>
        switch scope {
        case .default:
            select = Select(clauses: From.all._selectClauses)
        case .empty:
            select = Select(isEmpty: true, where: predicates)
        case .unscoped:
            select = Select()
        }
        return select.and(self)
    }

    public var _selectClauses: _SelectClauses {
        _SelectClauses(isEmpty: scope == .empty, where: predicates)
    }

    public func select<C: QueryExpression>(
        _ selection: KeyPath<From.TableColumns, C>
    ) -> Select<C.QueryValue, From, ()>
    where C.QueryValue: QueryRepresentable {
        asSelect().select(selection)
    }

    public func select<C: QueryExpression>(
        _ selection: (From.TableColumns) -> C
    ) -> Select<C.QueryValue, From, ()>
    where C.QueryValue: QueryRepresentable {
        asSelect().select(selection)
    }

    public func select<C1: QueryExpression, C2: QueryExpression, each C3: QueryExpression>(
        _ selection: (From.TableColumns) -> (C1, C2, repeat each C3)
    ) -> Select<(C1.QueryValue, C2.QueryValue, repeat (each C3).QueryValue), From, ()>
    where
        C1.QueryValue: QueryRepresentable,
        C2.QueryValue: QueryRepresentable,
        repeat (each C3).QueryValue: QueryRepresentable
    {
        asSelect().select(selection)
    }

    public func distinct(_ isDistinct: Bool = true) -> SelectOf<From> {
        asSelect().distinct(isDistinct)
    }

    public func join<each C: QueryRepresentable, F: Table, each J: Table>(
        _ other: any SelectStatement<(repeat each C), F, (repeat each J)>,
        on constraint: (
            (From.TableColumns, F.TableColumns, repeat (each J).TableColumns)
        ) -> some QueryExpression<Bool>
    ) -> Select<(repeat each C), From, (F, repeat each J)> {
        asSelect().join(other, on: constraint)
    }

    @_documentation(visibility: private)
    public func join<each C: QueryRepresentable, F: Table>(
        _ other: any SelectStatement<(repeat each C), F, ()>,
        on constraint: ((From.TableColumns, F.TableColumns)) -> some QueryExpression<Bool>
    ) -> Select<(repeat each C), From, F> {
        asSelect().join(other, on: constraint)
    }

    public func leftJoin<each C: QueryRepresentable, F: Table, each J: Table>(
        _ other: any SelectStatement<(repeat each C), F, (repeat each J)>,
        on constraint: (
            (From.TableColumns, F.TableColumns, repeat (each J).TableColumns)
        ) -> some QueryExpression<Bool>
    ) -> Select<
        (repeat (each C)._Optionalized),
        From,
        (F._Optionalized, repeat (each J)._Optionalized)
    > {
        let joined = asSelect().leftJoin(other, on: constraint)
        return joined
    }

    @_documentation(visibility: private)
    public func leftJoin<each C: QueryRepresentable, F: Table>(
        _ other: any SelectStatement<(repeat each C), F, ()>,
        on constraint: ((From.TableColumns, F.TableColumns)) -> some QueryExpression<Bool>
    ) -> Select<(repeat (each C)._Optionalized), From, F._Optionalized> {
        asSelect().leftJoin(other, on: constraint)
    }

    public func rightJoin<each C: QueryRepresentable, F: Table, each J: Table>(
        _ other: any SelectStatement<(repeat each C), F, (repeat each J)>,
        on constraint: (
            (From.TableColumns, F.TableColumns, repeat (each J).TableColumns)
        ) -> some QueryExpression<Bool>
    ) -> Select<(repeat each C), From._Optionalized, (F, repeat each J)> {
        let joined = asSelect().rightJoin(other, on: constraint)
        return joined
    }

    @_documentation(visibility: private)
    public func rightJoin<each C: QueryRepresentable, F: Table>(
        _ other: any SelectStatement<(repeat each C), F, ()>,
        on constraint: ((From.TableColumns, F.TableColumns)) -> some QueryExpression<Bool>
    ) -> Select<(repeat each C), From._Optionalized, F> {
        asSelect().rightJoin(other, on: constraint)
    }

    public func fullJoin<each C: QueryRepresentable, F: Table, each J: Table>(
        _ other: any SelectStatement<(repeat each C), F, (repeat each J)>,
        on constraint: (
            (From.TableColumns, F.TableColumns, repeat (each J).TableColumns)
        ) -> some QueryExpression<Bool>
    ) -> Select<
        (repeat (each C)._Optionalized),
        From._Optionalized,
        (F._Optionalized, repeat (each J)._Optionalized)
    > {
        let joined = asSelect().fullJoin(other, on: constraint)
        return joined
    }

    @_documentation(visibility: private)
    public func fullJoin<each C: QueryRepresentable, F: Table>(
        _ other: any SelectStatement<(repeat each C), F, ()>,
        on constraint: ((From.TableColumns, F.TableColumns)) -> some QueryExpression<Bool>
    ) -> Select<(repeat (each C)._Optionalized), From._Optionalized, F._Optionalized> {
        asSelect().fullJoin(other, on: constraint)
    }

    public func `where`(
        _ keyPath: KeyPath<From.TableColumns, some QueryExpression<some _OptionalPromotable<Bool?>>>
    ) -> Self {
        var `where` = self
        `where`.predicates.append(From.columns[keyPath: keyPath].queryFragment)
        return `where`
    }

    @_disfavoredOverload
    public func `where`(
        _ predicate: (From.TableColumns) -> some QueryExpression<some _OptionalPromotable<Bool?>>
    ) -> Self {
        var `where` = self
        `where`.predicates.append(predicate(From.columns).queryFragment)
        return `where`
    }

    public func `where`(
        @QueryFragmentBuilder<Bool> _ predicate: (From.TableColumns) -> [ISO_9075.Fragment]
    ) -> Self {
        var `where` = self
        `where`.predicates.append(contentsOf: predicate(From.columns))
        return `where`
    }

    public static func && (lhs: Self, rhs: Self) -> Self {
        lhs.and(rhs)
    }

    public static func || (lhs: Self, rhs: Self) -> Self {
        lhs.or(rhs)
    }

    public static prefix func ! (where: Self) -> Self {
        `where`.not()
    }

    public func and(_ other: Self) -> Self {
        guard !predicates.isEmpty else { return other }
        guard !other.predicates.isEmpty else { return self }
        var `where` = self
        `where`.predicates = [
            """
            (\(`where`.predicates.joined(separator: " AND "))) \
            AND \
            (\(other.predicates.joined(separator: " AND ")))
            """
        ]
        return `where`
    }

    public func or(_ other: Self) -> Self {
        guard !predicates.isEmpty else { return other }
        guard !other.predicates.isEmpty else { return self }
        var `where` = self
        `where`.predicates = [
            """
            (\(`where`.predicates.joined(separator: " AND "))) \
            OR \
            (\(other.predicates.joined(separator: " AND ")))
            """
        ]
        return `where`
    }

    public func not() -> Self {
        var `where` = self
        `where`.predicates = [
            "NOT (\(predicates.isEmpty ? "1" : predicates.joined(separator: " AND ")))"
        ]
        return `where`
    }

    public func group<C: QueryExpression>(
        by grouping: (From.TableColumns) -> C
    ) -> Select<(), From, ()> {
        asSelect().group(by: grouping)
    }

    public func group<C1: QueryExpression, C2: QueryExpression, each C3: QueryExpression>(
        by grouping: (From.TableColumns) -> (C1, C2, repeat each C3)
    ) -> SelectOf<From> {
        asSelect().group(by: grouping)
    }

    public func having(
        _ predicate: (From.TableColumns) -> some QueryExpression<some _OptionalPromotable<Bool?>>
    ) -> SelectOf<From> {
        asSelect().having(predicate)
    }

    public func order(
        by ordering: KeyPath<From.TableColumns, some QueryExpression>
    ) -> SelectOf<From> {
        asSelect().order(by: ordering)
    }

    public func order(
        @QueryFragmentBuilder<()>
        by ordering: (From.TableColumns) -> [ISO_9075.Fragment]
    ) -> SelectOf<From> {
        asSelect().order(by: ordering)
    }

    public func limit(_ maxLength: (any QueryExpression<Int>)?) -> SelectOf<From> {
        asSelect().limit(maxLength)
    }

    public func limit(
        @QueryFragmentBuilder<Int>
        _ maxLength: (From.TableColumns) -> [ISO_9075.Fragment]
    ) -> SelectOf<From> {
        asSelect().limit(maxLength)
    }

    public func offset(_ offset: (any QueryExpression<Int>)?) -> SelectOf<From> {
        asSelect().offset(offset)
    }

    public func offset(
        @QueryFragmentBuilder<Int>
        _ offset: (From.TableColumns) -> [ISO_9075.Fragment]
    ) -> SelectOf<From> {
        asSelect().offset(offset)
    }

    public func count(
        filter: ((From.TableColumns) -> any QueryExpression<Bool>)? = nil
    ) -> Select<Int, From, ()> {
        asSelect().count(filter: filter)
    }

    public func delete() -> DeleteOf<From> {
        Delete(
            isEmpty: scope == .empty,
            where: scope == .unscoped ? predicates : From.all._selectClauses.where + predicates
        )
    }

    public func update(set updates: (inout Updates<From>) -> Void) -> UpdateOf<From> {
        Update(
            isEmpty: scope == .empty,
            updates: Updates(updates),
            where: scope == .unscoped ? predicates : From.all._selectClauses.where + predicates
        )
    }

    public var query: ISO_9075.Fragment {
        asSelect().query
    }
}
