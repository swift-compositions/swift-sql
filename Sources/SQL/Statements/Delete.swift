public import ISO_9075_Foundation

extension Table {
    public static func delete() -> DeleteOf<Self> {
        Where().delete()
    }
}

extension PrimaryKeyedTable {
    public static func delete(_ row: Self) -> DeleteOf<Self> {
        delete()
            .where {
                $0.primaryKey.eq(PrimaryKey(queryOutput: row[keyPath: $0.primaryKey.keyPath]))
            }
    }
}

public struct Delete<From: Table, Returning> {
    var isEmpty: Bool
    var `where`: [ISO_9075.Fragment] = []
    var returning: [ISO_9075.Fragment] = []

    public func _returning<R>(_ returning: [ISO_9075.Fragment]) -> Delete<From, R> {
        Delete<From, R>(isEmpty: isEmpty, where: `where`, returning: returning)
    }

    public func `where`(
        _ keyPath: KeyPath<From.TableColumns, some QueryExpression<some _OptionalPromotable<Bool?>>>
    ) -> Self {
        var update = self
        update.where.append(From.columns[keyPath: keyPath].queryFragment)
        return update
    }

    @_disfavoredOverload
    public func `where`(
        _ predicate: (From.TableColumns) -> some QueryExpression<some _OptionalPromotable<Bool?>>
    ) -> Self {
        var update = self
        update.where.append(predicate(From.columns).queryFragment)
        return update
    }

    public func `where`(
        @QueryFragmentBuilder<Bool> _ predicate: (From.TableColumns) -> [ISO_9075.Fragment]
    ) -> Self {
        var update = self
        update.where.append(contentsOf: predicate(From.columns))
        return update
    }

}

public typealias DeleteOf<From: Table> = Delete<From, ()>

extension Delete: Statement {
    public typealias QueryValue = Returning

    public var query: ISO_9075.Fragment {
        guard !isEmpty else { return "" }
        var query: ISO_9075.Fragment = "DELETE FROM "
        if let schemaName = From.schemaName {
            query.append("\(quote: schemaName).")
        }
        query.append("\(quote: From.tableName)")
        if let tableAlias = From.tableAlias {
            query.append(" AS \(quote: tableAlias)")
        }
        if !`where`.isEmpty {
            let `where`: ISO_9075.Fragment = `where`.map { "(\($0))" }.joined(separator: " AND ")
            query.append("\(.newlineOrSpace)WHERE \(`where`)")
        }
        if !returning.isEmpty {
            query.append("\(.newlineOrSpace)RETURNING \(returning.joined(separator: ", "))")
        }
        return query
    }
}
