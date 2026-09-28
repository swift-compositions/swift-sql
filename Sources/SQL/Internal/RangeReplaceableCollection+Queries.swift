public import ISO_9075_Foundation

extension RangeReplaceableCollection {
    public init<each Q: QueryExpression>(_ elements: repeat each Q)
    where Element == ISO_9075.Fragment {
        self.init()
        for element in repeat each elements {
            append(element.queryFragment)
        }
    }

    func removingDuplicates() -> Self where Element: Hashable {
        var set: Set<Element> = []
        return filter { set.insert($0).inserted }
    }
}
