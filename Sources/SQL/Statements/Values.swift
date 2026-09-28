public import ISO_9075_Foundation

public struct Values<QueryValue>: PartialSelectStatement {
  public typealias From = Never

  private let rows: [[ISO_9075.Fragment]]
  package let _valuesElements: [ValuesElement]

  public init(@InsertValuesBuilder<QueryValue> _ values: () -> ValuesRows<QueryValue>) {
    let built = values()
    rows = built.rows
    _valuesElements = built.elements
  }

  public var query: ISO_9075.Fragment {
    guard !rows.isEmpty else { return "" }
    var query: ISO_9075.Fragment = "VALUES "
    query.append(
      rows
        .map { "(\($0.joined(separator: ", ")))" as ISO_9075.Fragment }
        .joined(separator: ", ")
    )
    return query
  }
}

extension Select where Joins == () {
  public init(_ values: Values<Columns>)
  where From == Values<Columns> {
    self.init(values: values, alias: nil)
  }

  public init(_ values: Values<Columns>)
  where From == Values<Columns>, Columns: Table {
    self.init(values: values, alias: Columns.tableName)
  }

  private init(values: Values<Columns>, alias: String?)
  where From == Values<Columns> {
    let elements = values._valuesElements
    let names = elements.flatMap(\.columns).enumerated().map { position, column in
      let decoded = column.decoding("\(quote: "column\(position + 1)")")
      return column.name.map { "\(decoded) AS \(quote: $0)" } ?? decoded
    }
    self.init(
      valuesColumns: names,
      elements: elements,
      from: alias.map { "\(values.queryFragment) AS \(quote: $0)" } ?? values.queryFragment,
      isEmpty: values.query.isEmpty
    )
  }

  public func `where`<Predicate: _OptionalPromotable<Bool?>>(
    _ keyPath: KeyPath<Columns, Predicate>
  ) -> Self
  where From == Values<Columns>, Predicate: QueryRepresentable & QueryBindable {
    _where(_valuesNamedColumns()[dynamicMember: keyPath].queryFragment)
  }

  public func `where`(
    @QueryFragmentBuilder<Bool>
    _ predicate: (ValuesColumns<Columns>) -> [ISO_9075.Fragment]
  ) -> Self
  where From == Values<Columns> {
    var select = self
    for fragment in predicate(_valuesNamedColumns()) {
      select = select._where(fragment)
    }
    return select
  }

  public func `where`<each C: QueryExpression>(
    @QueryFragmentBuilder<Bool>
    _ predicate: (repeat ValuesColumns<each C>) -> [ISO_9075.Fragment]
  ) -> Self
  where From == Values<(repeat each C)> {
    var select = self
    let columns: (repeat ValuesColumns<each C>) = _valuesColumnNames()
    for fragment in predicate(repeat each columns) {
      select = select._where(fragment)
    }
    return select
  }

  public func order<Member: QueryRepresentable & QueryBindable>(
    by ordering: KeyPath<Columns, Member>
  ) -> Self
  where From == Values<Columns> {
    _order(_valuesNamedColumns()[dynamicMember: ordering].queryFragment)
  }

  public func order(
    @QueryFragmentBuilder<()>
    by ordering: (ValuesColumns<Columns>) -> [ISO_9075.Fragment]
  ) -> Self
  where From == Values<Columns> {
    var select = self
    for fragment in ordering(_valuesNamedColumns()) {
      select = select._order(fragment)
    }
    return select
  }

  public func order<each C: QueryExpression>(
    @QueryFragmentBuilder<()>
    by ordering: (repeat ValuesColumns<each C>) -> [ISO_9075.Fragment]
  ) -> Self
  where From == Values<(repeat each C)> {
    var select = self
    let columns: (repeat ValuesColumns<each C>) = _valuesColumnNames()
    for fragment in ordering(repeat each columns) {
      select = select._order(fragment)
    }
    return select
  }

  private func _valuesColumnNames<each C: QueryExpression>()
    -> (repeat ValuesColumns<each C>)
  where From == Values<(repeat each C)> {
    let names = _valuesElements.flatMap { $0.columns.map(\.name) }
    return _valuesColumns { range in
      range.map { position in
        let name = names.indices.contains(position) ? names[position] : nil
        return "\(quote: name ?? "column\(position + 1)")"
      }
    }
  }

  private func _valuesNamedColumns() -> ValuesColumns<Columns>
  where From == Values<Columns> {
    let names = _valuesElements.flatMap { $0.columns.map(\.name) }
    return ValuesColumns(
      columns: names.indices.map { "\(quote: names[$0] ?? "column\($0 + 1)")" },
      elements: _valuesElements
    )
  }
}
