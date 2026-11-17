import ISO_9075_Foundation
public import SQL
public import Test

extension Test::Test.Snapshot.Strategy where Value: SQL::Statement, Format == Swift.String {
    /// The statement's SQL, with values inline.
    public static var sql: Self {
        Test::Test.Snapshot.Strategy<Swift.String, Swift.String>.lines.pullback(\.query.debugDescription)
    }
}

extension Test::Test.Snapshot.Strategy where Value: QueryExpression, Format == Swift.String {
    /// The expression's SQL, with values inline.
    public static var sql: Self {
        Test::Test.Snapshot.Strategy<Swift.String, Swift.String>.lines.pullback(\.queryFragment.debugDescription)
    }
}

extension Test::Test.Snapshot.Strategy where Format == Swift.String {
    /// The rows `execute` returns for the value, drawn as a table.
    ///
    /// A tuple row has one column per element; any other row has one column. A cell is `nil` for an absent
    /// value, a quoted literal for a string, the type's own description where it has one, and otherwise the
    /// value's type name with one line per stored property. No rows render as `(No results)`, and a thrown
    /// error renders as its description.
    public static func rows<Row, Failure: Swift.Error>(
        _ execute: @escaping (Value) throws(Failure) -> [Row]
    ) -> Self {
        Test::Test.Snapshot.Strategy<Swift.String, Swift.String>.lines.pullback { value in
            do throws(Failure) {
                return Rows.table(try execute(value))
            } catch {
                return Swift.String(describing: error)
            }
        }
    }
}

private enum Rows {}

extension Rows {
    static func table<Row>(_ rows: [Row]) -> Swift.String {
        guard !rows.isEmpty else { return "(No results)" }
        let cellRows: [[[Swift.String]]] = rows.map { row in
            let mirror = Mirror(reflecting: row)
            let values = mirror.displayStyle == .tuple ? mirror.children.map(\.value) : [row]
            return values.map { cell($0).split(separator: "\n", omittingEmptySubsequences: false).map(Swift.String.init) }
        }
        let width = cellRows.map(\.count).max() ?? 0
        var spans = [Int](repeating: 0, count: width)
        for row in cellRows {
            for (index, lines) in row.enumerated() {
                spans[index] = max(spans[index], lines.map(\.count).max() ?? 0)
            }
        }
        let isMultiline = cellRows.contains { row in row.contains { $0.count > 1 } }
        func border(_ left: Swift.String, _ middle: Swift.String, _ right: Swift.String) -> Swift.String {
            left + spans.map { Swift.String(repeating: "─", count: $0) }.joined(separator: middle) + right
        }
        let rendered = cellRows.map { row in
            (0..<(row.map(\.count).max() ?? 0)).map { offset in
                "│ "
                    + zip(row, spans).map { lines, span in
                        let text = offset < lines.count ? lines[offset] : ""
                        return text + Swift.String(repeating: " ", count: span - text.count)
                    }
                    .joined(separator: " │ ")
                    + " │"
            }
            .joined(separator: "\n")
        }
        let separator = isMultiline ? "\n" + border("├─", "─┼─", "─┤") + "\n" : "\n"
        return [border("┌─", "─┬─", "─┐"), rendered.joined(separator: separator), border("└─", "─┴─", "─┘")]
            .joined(separator: "\n")
    }

    static func cell(_ value: Any) -> Swift.String {
        let mirror = Mirror(reflecting: value)
        switch mirror.displayStyle {
        case .optional:
            return mirror.children.first.map { cell($0.value) } ?? "nil"

        case .struct, .class:
            guard !(value is any CustomStringConvertible), !(value is any CustomDebugStringConvertible),
                !mirror.children.isEmpty
            else { return inline(value) }
            let fields = mirror.children.map { child in
                "  \(child.label ?? "_"): \(inline(child.value))"
            }
            return "\(type(of: value))(\n" + fields.joined(separator: ",\n") + "\n)"

        default:
            return inline(value)
        }
    }

    static func inline(_ value: Any) -> Swift.String {
        let mirror = Mirror(reflecting: value)
        if mirror.displayStyle == .optional {
            return mirror.children.first.map { inline($0.value) } ?? "nil"
        }
        if let string = value as? Swift.String {
            return Swift.String(reflecting: string)
        }
        return Swift.String(describing: value)
    }
}
