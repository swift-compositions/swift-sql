// swift-format-ignore-file: AmbiguousTrailingClosureOverload
// REASON: each clause has an expression-closure overload and a @QueryFragmentBuilder overload;
// @_disfavoredOverload and the builder attribute resolve a trailing closure, so callers are not ambiguous.

public import ISO_9075_Foundation

extension Table {
    /// An update statement that uses a conflict-resolution algorithm.
    ///
    /// - Parameters:
    ///   - resolution: The algorithm to use when an update violates a constraint.
    ///   - updates: A closure describing the column updates to perform.
    /// - Returns: An update statement.
    public static func update(
        or resolution: Conflict.Resolution,
        set updates: (inout Updates<Self>) -> Void
    ) -> UpdateOf<Self> {
        Where().update(or: resolution, set: updates)
    }

    public static func update(
        set updates: (inout Updates<Self>) -> Void
    ) -> UpdateOf<Self> {
        Where().update(set: updates)
    }
}

extension PrimaryKeyedTable {
    /// An update statement for a row's primary key that uses a conflict-resolution algorithm.
    ///
    /// - Parameters:
    ///   - resolution: The algorithm to use when the update violates a constraint.
    ///   - row: The row containing the new values and the primary key to update.
    /// - Returns: An update statement.
    public static func update(
        or resolution: Conflict.Resolution,
        _ row: Self
    ) -> UpdateOf<Self> {
        update(or: resolution) { updates in
            for column in TableColumns.writableColumns
            where !columns.primaryKey._names.contains(column.name) {
                updates.set(column, column.render(row))
            }
        }
        .where {
            $0.primaryKey.eq(PrimaryKey(queryOutput: row[keyPath: $0.primaryKey.keyPath]))
        }
    }

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
    package var conflictResolution: Conflict.Resolution?
    var updates: Updates<From>
    var `where`: [ISO_9075.Fragment]
    var returning: [ISO_9075.Fragment]

    public func returning<R>(fragments: [ISO_9075.Fragment]) -> Update<From, R> {
        Update<From, R>(
            isEmpty: isEmpty,
            conflictResolution: conflictResolution,
            updates: updates,
            where: `where`,
            returning: fragments
        )
    }

    package init(
        isEmpty: Bool,
        conflictResolution: Conflict.Resolution? = nil,
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
