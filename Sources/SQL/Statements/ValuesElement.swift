public import ISO_9075_Foundation

public struct ValuesElement: Sendable {
    package let offset: Int
    package let columns: [Column]
    package let fieldOffsets: [Int]

    package init(offset: Int, columns: [Column], fieldOffsets: [Int] = []) {
        self.offset = offset
        self.columns = columns
        self.fieldOffsets = fieldOffsets
    }

    public struct Column: Sendable {
        package let name: String?
        package let decoding: @Sendable (ISO_9075.Fragment) -> ISO_9075.Fragment

        package init(name: String?, decoding: @escaping @Sendable (ISO_9075.Fragment) -> ISO_9075.Fragment) {
            self.name = name
            self.decoding = decoding
        }

    }

    package static func elements<each V: QueryRepresentable>(for types: repeat (each V).Type) -> [ValuesElement] {
        var elements: [ValuesElement] = []
        var offset = 0
        for type in repeat each types {
            func append<T: QueryRepresentable>(_: T.Type) {
                let alignment = MemoryLayout<T>.alignment
                offset = (offset + alignment - 1) / alignment * alignment
                elements.append(ValuesElement(offset: offset, columns: T._valuesColumns, fieldOffsets: T._valuesFieldOffsets))
                offset += MemoryLayout<T>.size
            }
            append(type)
        }
        return elements
    }
}

extension QueryRepresentable {
    public static var _valuesColumns: [ValuesElement.Column] {
        [ValuesElement.Column(name: nil, decoding: { Self.queryFragment(decoding: $0) })]
    }

    public static var _valuesFieldOffsets: [Int] { [] }

    public static func _valuesColumnIndex(of keyPath: AnyKeyPath) -> Int? { nil }
}

extension [ValuesElement] {
    package func columnIndex<Value>(of keyPath: PartialKeyPath<Value>) -> Int? {
        guard let target = MemoryLayout<Value>.offset(of: keyPath) else { return nil }
        var position = 0
        for element in self {
            if element.columns.count == 1 {
                if element.offset == target { return position }
            } else if target >= element.offset,
                let field = element.fieldOffsets.firstIndex(of: target - element.offset),
                field < element.columns.count
            {
                return position + field
            }
            position += element.columns.count
        }
        return nil
    }
}

extension Table {
    public static var _valuesColumns: [ValuesElement.Column] {
        TableColumns.allColumns.map { ValuesElement.Column(name: $0.name, decoding: $0.decoding) }
    }

    public static var _valuesFieldOffsets: [Int] {
        TableColumns.allColumns.map { $0.fieldOffset ?? 0 }
    }

    public static func _valuesColumnIndex(of keyPath: AnyKeyPath) -> Int? {
        TableColumns.allColumns.firstIndex { $0.keyPath == keyPath }
    }

    package static var valuesElement: ValuesElement {
        ValuesElement(offset: 0, columns: _valuesColumns, fieldOffsets: _valuesFieldOffsets)
    }

    package static var writableValuesElement: ValuesElement {
        ValuesElement(
            offset: 0,
            columns: TableColumns.writableColumns.map { ValuesElement.Column(name: $0.name, decoding: $0.decoding) }
        )
    }
}
