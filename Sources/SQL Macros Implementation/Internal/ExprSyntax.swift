import SwiftParser
import SwiftSyntax
import SwiftSyntaxBuilder

extension ExprSyntax {
    var literalType: TypeSyntax? {
        return if self.is(BooleanLiteralExprSyntax.self) {
            "Swift.Bool"
        } else if self.is(FloatLiteralExprSyntax.self) {
            "Swift.Double"
        } else if self.is(IntegerLiteralExprSyntax.self) {
            "Swift.Int"
        } else if self.is(StringLiteralExprSyntax.self) {
            "Swift.String"
        } else {
            nil
        }
    }

    var isNonEmptyStringLiteral: Bool {
        guard let literal = self.as(StringLiteralExprSyntax.self)?.representedLiteralValue
        else { return false }
        return !literal.isEmpty
    }
}
