import Foundation
import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public enum ViewModelifyEnv {
    public static let isDebug = {
        var isDebug = false
        assert({
            isDebug = true
        }() == ())
        return isDebug
    }()
}

public struct ViewInspectify: MemberMacro, ExtensionMacro {
    public static func expansion(of node: SwiftSyntax.AttributeSyntax, providingMembersOf declaration: some SwiftSyntax.DeclGroupSyntax, in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.DeclSyntax] {
        ["let inspection = Inspection<Self>()"]
    }
    public static func expansion(of node: SwiftSyntax.AttributeSyntax, attachedTo declaration: some SwiftSyntax.DeclGroupSyntax, providingExtensionsOf type: some SwiftSyntax.TypeSyntaxProtocol, conformingTo protocols: [SwiftSyntax.TypeSyntax], in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.ExtensionDeclSyntax] {
        let decl: DeclSyntax = "extension \(raw: type.trimmedDescription): ViewInspectified {}"
        return [decl.cast(ExtensionDeclSyntax.self)]
    }
}

public struct ViewModelify: MemberMacro, ExtensionMacro {
    public static func expansion(of node: SwiftSyntax.AttributeSyntax, providingMembersOf declaration: some SwiftSyntax.DeclGroupSyntax, in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.DeclSyntax] {
        var res: [SwiftSyntax.DeclSyntax] = ["var wrappedValue: Self { self }"]
        if ViewModelifyEnv.isDebug {
            res.append("fileprivate let _inspection = Inspection<Self>()")
        }
        return res
    }

    public static func expansion(of node: SwiftSyntax.AttributeSyntax, attachedTo declaration: some SwiftSyntax.DeclGroupSyntax, providingExtensionsOf type: some SwiftSyntax.TypeSyntaxProtocol, conformingTo protocols: [SwiftSyntax.TypeSyntax], in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.ExtensionDeclSyntax] {
        guard ViewModelifyEnv.isDebug else {
            return []
        }
        let decl1: DeclSyntax = """
        extension \(raw: type.trimmedDescription): ViewInspectified {
          var inspection: Inspection<\(raw: type.trimmedDescription)> { _inspection }
        }
        """
        let decl2: DeclSyntax = """
        extension \(raw: type.trimmedDescription): View {
          var body: some View {
            let _ = Self._printChanges()
            EmptyView()
              .applyViewInspectorModifiers(self)
          }
        }
        """
        return [decl1.cast(ExtensionDeclSyntax.self), decl2.cast(ExtensionDeclSyntax.self)]
    }
}

@main
struct ViewModelifyPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        ViewModelify.self,
        ViewInspectify.self
    ]
}
