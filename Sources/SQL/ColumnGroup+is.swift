extension ColumnGroup where QueryValue: Table {
    public func `is`<V>(
        _ keyPath: KeyPath<Values.TableColumns, CaseColumn<Values.QueryOutput, V>>
    ) -> some QueryExpression<Bool> {
        self[dynamicMember: keyPath].isNot(nil)
    }

    public func `is`<V>(
        _ keyPath: KeyPath<Values.TableColumns, CaseColumnGroup<Values.QueryOutput, V>>
    ) -> some QueryExpression<Bool> {
        self[dynamicMember: keyPath].isNot(nil)
    }
}

extension OptionalColumnGroup {
    public func `is`<V>(
        _ keyPath: KeyPath<Values.QueryOutput.TableColumns, CaseColumn<Values.QueryOutput, V>>
    ) -> some QueryExpression<Bool> {
        self[dynamicMember: keyPath].isNot(nil)
    }

    public func `is`<V>(
        _ keyPath: KeyPath<
            Values.QueryOutput.TableColumns, CaseColumnGroup<Values.QueryOutput, V>
        >
    ) -> some QueryExpression<Bool> {
        self[dynamicMember: keyPath].isNot(nil)
    }
}
