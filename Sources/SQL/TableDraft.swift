import ISO_9075_Foundation

public protocol TableDraft: Table {
    associatedtype SourceTable: Table where SourceTable.Draft == Self

    init(_ source: SourceTable)
}
