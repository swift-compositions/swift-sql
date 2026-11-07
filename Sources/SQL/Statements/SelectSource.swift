public import ISO_9075_Foundation

public protocol _SelectSource {
    static var _fromTable: _FromTable? { get }
}

public struct _FromTable: Sendable {
    let columns: ISO_9075.Fragment
    let reference: ISO_9075.Fragment
    let alias: String?
}

extension _SelectSource {
    public static var _fromTable: _FromTable? { nil }
}

extension Table {
    public static var _fromTable: _FromTable? {
        _FromTable(
            columns: _allColumnsFragment,
            reference: schemaName.map { "\(quote: $0).\(tableFragment)" } ?? tableFragment,
            alias: tableAlias
        )
    }
}

extension Optional: _SelectSource where Wrapped: Table {}

extension TableAlias: _SelectSource where Base: Table {}
