public import ISO_9075_Foundation

extension Table {
    public static func update(
        set updates: (inout Updates<Self>) -> Void
    ) -> UpdateOf<Self> {
        Where().update(set: updates)
    }
}

extension PrimaryKeyedTable {
    public static func update(
        _ row: Self
    ) -> UpdateOf<Self> {
        update { updates in
            for column in TableColumns.writableColumns
            where !columns.primaryKey._names.contains(column.name) {
                updates.set(column, column.render(row))
            }
        }
        .where {
            $0.primaryKey.eq(PrimaryKey(queryOutput: row[keyPath: $0.primaryKey.keyPath]))
        }
    }
}

public struct Update<From: Table, Returning> {
    var isEmpty: Bool
    package var conflictResolution: ISO_9075.Fragment?
    var updates: Updates<From>
    var `where`: [ISO_9075.Fragment]
    var returning: [ISO_9075.Fragment]

    package func _returning<R>(_ returning: [ISO_9075.Fragment]) -> Update<From, R> {
        Update<From, R>(
            isEmpty: isEmpty,
            conflictResolution: conflictResolution,
            updates: updates,
            where: `where`,
            returning: returning
        )
    }

    package init(
        isEmpty: Bool,
        conflictResolution: ISO_9075.Fragment? = nil,
        updates: Updates<From>,
        where: [ISO_9075.Fragment] = [],
        returning: [ISO_9075.Fragment] = []
    ) {
        self.isEmpty = isEmpty
        self.conflictResolution = conflictResolution
        self.updates = updates
        self.where = `where`
        self.returning = returning
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

public typealias UpdateOf<Base: Table> = Update<Base, ()>

extension Update: Statement {
    public typealias QueryValue = Returning

    public var query: ISO_9075.Fragment {
        guard !isEmpty, !updates.isEmpty
        else { return "" }

        var query: ISO_9075.Fragment = "UPDATE "
        if let conflictResolution {
            query.append("OR \(conflictResolution) ")
        }
        if let schemaName = From.schemaName {
            query.append("\(quote: schemaName).")
        }
        query.append("\(quote: From.tableName)")
        if let tableAlias = From.tableAlias {
            query.append(" AS \(quote: tableAlias)")
        }
        query.append("\(.newlineOrSpace)\(updates)")
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
