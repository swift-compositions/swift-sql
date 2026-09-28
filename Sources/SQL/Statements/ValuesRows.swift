public import ISO_9075_Foundation

public struct ValuesRows<Value>: Sendable {
    package var rows: [[ISO_9075.Fragment]]
    package var elements: [ValuesElement]

    package init(rows: [[ISO_9075.Fragment]] = [], elements: [ValuesElement] = []) {
        self.rows = rows
        self.elements = elements
    }

    package mutating func append(_ other: Self) {
        rows.append(contentsOf: other.rows)
        if elements.isEmpty {
            elements = other.elements
        }
    }
}
