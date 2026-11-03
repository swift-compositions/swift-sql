// swift-format-ignore-file: AmbiguousTrailingClosureOverload
// REASON: each clause has an expression-closure overload and a @QueryFragmentBuilder overload;
// @_disfavoredOverload and the builder attribute resolve a trailing closure, so callers are not ambiguous.

import ISO_9075_Foundation

extension Delete {
    public func returning<QueryValue: QueryRepresentable>(
        _ selection: (From.TableColumns) -> TableColumn<From, QueryValue>
    ) -> Delete<From, QueryValue> {
        returning(fragments: [selection(From.columns).returningFragment])
    }

    @_disfavoredOverload
    public func returning<each QueryValue: QueryRepresentable>(
        _ selection: (From.TableColumns) -> (repeat TableColumn<From, each QueryValue>)
    ) -> Delete<From, (repeat each QueryValue)> {
        let columns = selection(From.columns)
        var fragments: [ISO_9075.Fragment] = []
        for column in repeat each columns {
            fragments.append(column.returningFragment)
        }
        return returning(fragments: fragments)
    }

    public func returning(_ selection: (From.TableColumns) -> From.TableColumns) -> Delete<From, From> {
        returning(fragments: From.TableColumns.allColumns.map(\.returningFragment))
    }
}

extension Insert {
    public func returning<QueryValue: QueryRepresentable>(
        _ selection: (Into.TableColumns) -> TableColumn<Into, QueryValue>
    ) -> Insert<Into, QueryValue> {
        returning(fragments: [selection(Into.columns).returningFragment])
    }

    @_disfavoredOverload
    public func returning<each QueryValue: QueryRepresentable>(
        _ selection: (Into.TableColumns) -> (repeat TableColumn<Into, each QueryValue>)
    ) -> Insert<Into, (repeat each QueryValue)> {
        let columns = selection(Into.columns)
        var fragments: [ISO_9075.Fragment] = []
        for column in repeat each columns {
            fragments.append(column.returningFragment)
        }
        return returning(fragments: fragments)
    }

    public func returning(_ selection: (Into.TableColumns) -> Into.TableColumns) -> Insert<Into, Into> {
        returning(fragments: Into.TableColumns.allColumns.map(\.returningFragment))
    }
}

extension Update {
    public func returning<QueryValue: QueryRepresentable>(
        _ selection: (From.TableColumns) -> TableColumn<From, QueryValue>
    ) -> Update<From, QueryValue> {
        returning(fragments: [selection(From.columns).returningFragment])
    }

    @_disfavoredOverload
    public func returning<each QueryValue: QueryRepresentable>(
        _ selection: (From.TableColumns) -> (repeat TableColumn<From, each QueryValue>)
    ) -> Update<From, (repeat each QueryValue)> {
        let columns = selection(From.columns)
        var fragments: [ISO_9075.Fragment] = []
        for column in repeat each columns {
            fragments.append(column.returningFragment)
        }
        return returning(fragments: fragments)
    }

    public func returning(_ selection: (From.TableColumns) -> From.TableColumns) -> Update<From, From> {
        returning(fragments: From.TableColumns.allColumns.map(\.returningFragment))
    }
}
