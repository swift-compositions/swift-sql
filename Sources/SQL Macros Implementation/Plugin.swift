import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct SQLPlugin: CompilerPlugin {
    let providingMacros: [any Macro.Type] =
        [
            BindMacro.self,
            ColumnCheckFailMacro.self,
            ColumnCheckFailRawRepresentableMacro.self,
            ColumnCheckGroupMacro.self,
            ColumnCheckPassMacro.self,
            ColumnDefaultMacro.self,
            ColumnDefinitionMacro.self,
            ColumnMacro.self,
            EphemeralMacro.self,
            PrimaryKeyDefaultMacro.self,
            SQLMacro.self,
            TableMacro.self,
        ]
        + casePathsMacros
}

#if CasePaths
    private let casePathsMacros: [any Macro.Type] = [CaseCheckFailMacro.self]
#else
    private let casePathsMacros: [any Macro.Type] = []
#endif
