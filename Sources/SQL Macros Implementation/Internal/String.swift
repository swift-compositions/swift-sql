extension String {
    // A type's name as its table's: the leading capitals lowercased, keeping the last of several as the next word's
    // start ("URLRequest" becomes "urlRequest"). The same as Standard Library Extensions' lowercasingLeadingUppercase,
    // kept here so the macro depends on nothing the app also builds, and Xcode can use prebuilt swift-syntax.
    var lowercasingLeadingUppercase: String {
        let leading = prefix(while: \.isUppercase).count
        let count = leading > 1 && leading < self.count ? leading - 1 : leading
        return prefix(count).lowercased() + dropFirst(count)
    }
}
