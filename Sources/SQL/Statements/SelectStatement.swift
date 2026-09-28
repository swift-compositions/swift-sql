public protocol PartialSelectStatement<QueryValue>: Statement {}

public protocol SelectStatement<QueryValue, From, Joins>: PartialSelectStatement
where From: Table {
    func asSelect() -> Select<QueryValue, From, Joins>

    var _selectClauses: _SelectClauses { get }
}

extension SelectStatement {
    public func asSelect() -> Select<QueryValue, From, Joins> {
        Select(clauses: _selectClauses)
    }

    public var _selectClauses: _SelectClauses {
        asSelect().clauses
    }

    public func selectStar<each J: Table>() -> Select<(From, repeat each J), From, Joins>
    where Joins == (repeat each J) {
        var select = Select<(From, repeat each J), From, Joins>()
        select.clauses = asSelect().clauses
        return select
    }
}

public typealias SelectStatementOf<From: Table, each Join: Table> =
    SelectStatement<(), From, (repeat each Join)>

extension SelectStatement {
    public static func `where`<From>(
        _ predicate: (From.TableColumns) -> some QueryExpression<some _OptionalPromotable<Bool?>>
    ) -> Self
    where Self == Where<From> {
        Self(predicates: [predicate(From.columns).queryFragment])
    }
}

extension SelectStatement {
    public var _hasUpsertParsingAmbiguity: Bool {
        _selectClauses.hasUpsertParsingAmbiguity
    }
}

extension Select {
    public var _hasUpsertParsingAmbiguity: Bool {
        _rendersFromClause && clauses.hasUpsertParsingAmbiguity
    }
}

extension _SelectClauses {
    var hasUpsertParsingAmbiguity: Bool {
        !isEmpty
            && joins.isEmpty
            && `where`.isEmpty
            && group.isEmpty
            && having.isEmpty
            && order.isEmpty
            && limit == nil
    }
}
