import Foundation
import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

enum Env {
    static var isDebug = {
        var isDebug = false
        assert({
            isDebug = true
        }() == ())
        return isDebug
    }()
}

public struct ModelifyAppear: MemberMacro, ExtensionMacro {
    public static func expansion(of node: SwiftSyntax.AttributeSyntax, providingMembersOf declaration: some SwiftSyntax.DeclGroupSyntax, in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.DeclSyntax] {
        var res: [SwiftSyntax.DeclSyntax] = ["var wrappedValue: Self { self }"]
        if Env.isDebug {
            res.append("var inspect: ((Self) -> Void)?")
        }
        return res
    }

    public static func expansion(of node: SwiftSyntax.AttributeSyntax, attachedTo declaration: some SwiftSyntax.DeclGroupSyntax, providingExtensionsOf type: some SwiftSyntax.TypeSyntaxProtocol, conformingTo protocols: [SwiftSyntax.TypeSyntax], in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.ExtensionDeclSyntax] {
        guard Env.isDebug else {
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

public struct ModelifyReceive: MemberMacro, ExtensionMacro {
    public static func expansion(of node: SwiftSyntax.AttributeSyntax, providingMembersOf declaration: some SwiftSyntax.DeclGroupSyntax, in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.DeclSyntax] {
        var res: [SwiftSyntax.DeclSyntax] = ["var wrappedValue: Self { self }"]
        if Env.isDebug {
            res.append("let inspection = Inspection<Self>()")
        }
        return res
    }

    public static func expansion(of node: SwiftSyntax.AttributeSyntax, attachedTo declaration: some SwiftSyntax.DeclGroupSyntax, providingExtensionsOf type: some SwiftSyntax.TypeSyntaxProtocol, conformingTo protocols: [SwiftSyntax.TypeSyntax], in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.ExtensionDeclSyntax] {
        guard Env.isDebug else {
            return []
        }
        let decl: DeclSyntax = """
        extension \(raw: type.trimmedDescription): View {
            var body: some View { EmptyView().onReceive(inspection.notice) { self.inspection.visit(self, $0) } }
        }
        """
        let ext = decl.cast(ExtensionDeclSyntax.self)
        return [ext]
    }
}

@main
struct ViewModelifyPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        ModelifyAppear.self,
        ModelifyReceive.self
    ]
}
