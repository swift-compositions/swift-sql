extension _TableColumnExpression where Value: _OptionalProtocol {
    /// Compares this optional column with the single value selected by a scalar subquery.
    ///
    /// - Parameter subquery: A select statement that returns the column's optional value type.
    /// - Returns: A Boolean query expression using SQL equality.
    public func eq(
        _ subquery: some PartialSelectStatement<Value>
    ) -> some QueryExpression<Bool> {
        BinaryOperator(lhs: self, operator: "=", rhs: subquery)
    }
}
