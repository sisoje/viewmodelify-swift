import Foundation
import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

enum ViewModelifyEnv {
    static let isDebug = {
        var isDebug = false
        assert((isDebug = true) == ())
        return isDebug
    }()
}

public struct InspectedViewModifier: MemberMacro, ExtensionMacro {
    public static func expansion(
        of node: SwiftSyntax.AttributeSyntax,
        providingMembersOf declaration: some SwiftSyntax.DeclGroupSyntax,
        in context: some SwiftSyntaxMacros.MacroExpansionContext
    ) throws -> [SwiftSyntax.DeclSyntax] { ["let inspection = Inspection<Self>()"] }

    public static func expansion(
        of node: SwiftSyntax.AttributeSyntax,
        attachedTo declaration: some SwiftSyntax.DeclGroupSyntax,
        providingExtensionsOf type: some SwiftSyntax.TypeSyntaxProtocol,
        conformingTo protocols: [SwiftSyntax.TypeSyntax],
        in context: some SwiftSyntaxMacros.MacroExpansionContext
    ) throws -> [SwiftSyntax.ExtensionDeclSyntax] {
        let decl: DeclSyntax = "extension \(raw: type.trimmedDescription): InspectedViewModifierProtocol {}"
        return [decl.cast(ExtensionDeclSyntax.self)]
    }
}

public struct InspectedView: MemberMacro, ExtensionMacro {
    public static func expansion(
        of node: SwiftSyntax.AttributeSyntax,
        providingMembersOf declaration: some SwiftSyntax.DeclGroupSyntax,
        in context: some SwiftSyntaxMacros.MacroExpansionContext
    ) throws -> [SwiftSyntax.DeclSyntax] { ["let inspection = Inspection<Self>()"] }

    public static func expansion(
        of node: SwiftSyntax.AttributeSyntax,
        attachedTo declaration: some SwiftSyntax.DeclGroupSyntax,
        providingExtensionsOf type: some SwiftSyntax.TypeSyntaxProtocol,
        conformingTo protocols: [SwiftSyntax.TypeSyntax],
        in context: some SwiftSyntaxMacros.MacroExpansionContext
    ) throws -> [SwiftSyntax.ExtensionDeclSyntax] {
        let decl: DeclSyntax = "extension \(raw: type.trimmedDescription): InspectedViewProtocol {}"
        return [decl.cast(ExtensionDeclSyntax.self)]
    }
}

public struct ViewModelify: MemberMacro, ExtensionMacro {
    public static func expansion(
        of node: SwiftSyntax.AttributeSyntax,
        providingMembersOf declaration: some SwiftSyntax.DeclGroupSyntax,
        in context: some SwiftSyntaxMacros.MacroExpansionContext
    ) throws -> [SwiftSyntax.DeclSyntax] {
        var res: [SwiftSyntax.DeclSyntax] = ["var wrappedValue: Self { self }"]
        if ViewModelifyEnv.isDebug {
            res.append("let inspection = Inspection<Self>()")
        }
        return res
    }

    public static func expansion(
        of node: SwiftSyntax.AttributeSyntax,
        attachedTo declaration: some SwiftSyntax.DeclGroupSyntax,
        providingExtensionsOf type: some SwiftSyntax.TypeSyntaxProtocol,
        conformingTo protocols: [SwiftSyntax.TypeSyntax],
        in context: some SwiftSyntaxMacros.MacroExpansionContext
    ) throws -> [SwiftSyntax.ExtensionDeclSyntax] {
        guard ViewModelifyEnv.isDebug else { return [] }
        let decl1: DeclSyntax = "extension \(raw: type.trimmedDescription): InspectedViewProtocol { var inspectedBody: some View { EmptyView() } }"
        return [decl1.cast(ExtensionDeclSyntax.self)]
    }
}

@main
struct ViewModelifyPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        ViewModelify.self,
        InspectedView.self,
        InspectedViewModifier.self
    ]
}
