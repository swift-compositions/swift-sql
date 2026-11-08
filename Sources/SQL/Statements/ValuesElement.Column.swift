public import ISO_9075_Foundation


extension ValuesElement {
    public struct Column: Sendable {
        package let name: String?
        package let decoding: @Sendable (ISO_9075.Fragment) -> ISO_9075.Fragment

        package init(name: String?, decoding: @escaping @Sendable (ISO_9075.Fragment) -> ISO_9075.Fragment) {
            self.name = name
            self.decoding = decoding
        }
    }
}
