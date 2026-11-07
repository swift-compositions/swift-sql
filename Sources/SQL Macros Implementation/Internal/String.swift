extension String {
    var lowercasingLeadingUppercase: String {
        let leading = prefix(while: \.isUppercase).count
        let count = leading > 1 && leading < self.count ? leading - 1 : leading
        return prefix(count).lowercased() + dropFirst(count)
    }
}
