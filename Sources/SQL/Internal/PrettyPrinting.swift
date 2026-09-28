public import ISO_9075_Foundation

extension ISO_9075.Fragment {
    public static var newlineOrSpace: Self { "\n" }

    package static var newline: Self { "\n" }

    public func indented() -> Self {
        Self(
            segments: [.sql("  ")]
                + segments.map { segment in
                    switch segment {
                    case .sql(let sql): .sql(sql.replacing("\n", with: "\n  "))
                    case .value, .identifier, .keyword: segment
                    }
                }
        )
    }
}
