import Foundation
import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct ViewModelify: MemberMacro, ExtensionMacro {
    public static var isTesting = true

    public static func expansion(of node: SwiftSyntax.AttributeSyntax, providingMembersOf declaration: some SwiftSyntax.DeclGroupSyntax, in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.DeclSyntax] {
        var res: [SwiftSyntax.DeclSyntax] = ["var wrappedValue: Self { self }"]
        if isTesting {
            res.append("var inspect: ((Self) -> Void)?")
        }
        return res
    }

    public static func expansion(of node: SwiftSyntax.AttributeSyntax, attachedTo declaration: some SwiftSyntax.DeclGroupSyntax, providingExtensionsOf type: some SwiftSyntax.TypeSyntaxProtocol, conformingTo protocols: [SwiftSyntax.TypeSyntax], in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.ExtensionDeclSyntax] {
        guard isTesting else {
            return []
        }
        let decl: DeclSyntax = """
        extension \(raw: type.trimmedDescription): View {
            var body: some View { EmptyView().onAppear { inspect?(self) } }
        }
        """
        let ext = decl.cast(ExtensionDeclSyntax.self)
        return [ext]
    }
}

@main
struct ViewModelifyPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        ViewModelify.self,
    ]
}
