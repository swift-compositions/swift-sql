public import ISO_9075_Foundation

public struct Column<Root: Table> {
    public let name: String
    public let isWritable: Bool
    package let render: (Root) -> ISO_9075.Fragment
    package let isNull: (Root) -> Bool
    package let decoding: @Sendable (ISO_9075.Fragment) -> ISO_9075.Fragment
    package let keyPath: PartialKeyPath<Root>?

    package init(
        name: String,
        isWritable: Bool,
        render: @escaping (Root) -> ISO_9075.Fragment,
        isNull: @escaping (Root) -> Bool,
        decoding: @escaping @Sendable (ISO_9075.Fragment) -> ISO_9075.Fragment,
        keyPath: PartialKeyPath<Root>?
    ) {
        self.name = name
        self.isWritable = isWritable
        self.render = render
        self.isNull = isNull
        self.decoding = decoding
        self.keyPath = keyPath
    }

    package init<Value: QueryRepresentable & QueryBindable>(
        name: String,
        isWritable: Bool,
        keyPath: KeyPath<Root, Value.QueryOutput>,
        as _: Value.Type
    ) {
        self.init(
            name: name,
            isWritable: isWritable,
            render: { Value(queryOutput: $0[keyPath: keyPath]).queryFragment },
            isNull: { Value(queryOutput: $0[keyPath: keyPath]).queryBinding == .null },
            decoding: { Value.queryFragment(decoding: $0) },
            keyPath: keyPath
        )
    }

    public var queryFragment: ISO_9075.Fragment {
        let column: ISO_9075.Fragment = "\(Root.self).\(quote: name)"
        return _isSelecting ? decoding(column) : column
    }

    public var returningFragment: ISO_9075.Fragment {
        decoding("\(quote: name)")
    }

    package var fieldOffset: Int? {
        keyPath.flatMap { MemoryLayout<Root>.offset(of: $0) }
    }

    public func aliased<Name: AliasName>(_: Name.Type) -> Column<TableAlias<Root, Name>> {
        Column<TableAlias<Root, Name>>(
            name: name,
            isWritable: isWritable,
            render: { [render] alias in render(alias.base) },
            isNull: { [isNull] alias in isNull(alias.base) },
            decoding: decoding,
            keyPath: keyPath.flatMap { (\TableAlias<Root, Name>.base as PartialKeyPath).appending(path: $0) }
        )
    }

    public var optional: Column<Root?> {
        Column<Root?>(
            name: name,
            isWritable: isWritable,
            render: { [render] root in root.map(render) ?? "NULL" },
            isNull: { [isNull] root in root.map(isNull) ?? true },
            decoding: decoding,
            keyPath: nil
        )
    }

    package func rooted<Outer: Table>(at path: KeyPath<Outer, Root>) -> Column<Outer> {
        Column<Outer>(
            name: name,
            isWritable: isWritable,
            render: { [render] outer in render(outer[keyPath: path]) },
            isNull: { [isNull] outer in isNull(outer[keyPath: path]) },
            decoding: decoding,
            keyPath: keyPath.flatMap { (path as PartialKeyPath).appending(path: $0) }
        )
    }

    package func rendering(_ root: Root, primaryKeys: Set<String>) -> ISO_9075.Fragment {
        primaryKeys.contains(name) && isNull(root) ? "\(ISO_9075.Keyword.defaultPrimaryKey)" : render(root)
    }
}
