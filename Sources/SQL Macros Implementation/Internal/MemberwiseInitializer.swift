import SwiftSyntax
import SwiftSyntaxBuilder

struct MemberwiseInitializer {
    var access: Keyword
    var parameters: [String] = []
    var assignments: [String] = []

    init?(access: Keyword, properties: [DeclSyntax]) {
        self.access = access
        let permittedAccess: [Keyword] =
            access == .package ? [.public, .package] : [.public]
        for property in properties {
            guard
                let variable = property.as(VariableDeclSyntax.self),
                variable.bindings.count == 1,
                let binding = variable.bindings.first,
                let identifier = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier
                    .trimmed,
                variable.attributes.allSatisfy({
                    $0.as(AttributeSyntax.self)?.attributeName.as(IdentifierTypeSyntax.self)?
                        .name.text == "Column"
                }),
                variable.modifiers.contains(where: { modifier in
                    modifier.detail == nil
                        && permittedAccess.contains(where: {
                            modifier.name.tokenKind == .keyword($0)
                        })
                })
            else { return nil }
            let isConstant = variable.bindingSpecifier.tokenKind == .keyword(.let)
            let initializer = binding.initializer?.value.trimmed
            if isConstant, initializer != nil { continue }
            guard
                let type = binding.typeAnnotation?.type.trimmed
                    ?? initializer?.literalType
                    ?? initializer?.optionalLiteralType
            else { return nil }
            let defaultValue: ExprSyntax? =
                isConstant
                ? nil
                : initializer
                    ?? (type.is(OptionalTypeSyntax.self)
                        || type.is(ImplicitlyUnwrappedOptionalTypeSyntax.self)
                        ? ExprSyntax(NilLiteralExprSyntax()) : nil)
            let escaping = type.isFunctionType ? "@escaping " : ""
            parameters.append(
                "\(identifier.text): \(escaping)\(type.trimmedDescription)"
                    + (defaultValue.map { " = \($0.trimmedDescription)" } ?? "")
            )
            assignments.append("self.\(identifier.text) = \(identifier.text)")
        }
    }

    var declaration: DeclSyntax {
        guard !parameters.isEmpty
        else { return "\(TokenSyntax.keyword(access)) init() {\n}" }
        return """
            \(TokenSyntax.keyword(access)) init(
            \(raw: parameters.joined(separator: ",\n"))
            ) {
            \(raw: assignments.joined(separator: "\n"))
            }
            """
    }
}

extension ExprSyntax {
    fileprivate var optionalLiteralType: TypeSyntax? {
        guard
            let call = self.as(FunctionCallExprSyntax.self),
            call.calledExpression.as(DeclReferenceExprSyntax.self)?.baseName.text == "Optional",
            call.trailingClosure == nil,
            call.arguments.count == 1,
            let argument = call.arguments.first,
            argument.label == nil,
            let wrapped = argument.expression.literalType
        else { return nil }
        return "Swift.Optional<\(wrapped)>"
    }
}

extension TypeSyntax {
    fileprivate var isFunctionType: Bool {
        self.is(FunctionTypeSyntax.self)
            || self.as(AttributedTypeSyntax.self)?.baseType.is(FunctionTypeSyntax.self) == true
    }
}
