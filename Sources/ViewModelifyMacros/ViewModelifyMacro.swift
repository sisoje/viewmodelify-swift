import Foundation
import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

private enum Env {
    static var isDebug = {
        var isDebug = false
        assert({
            isDebug = true
        }() == ())
        return isDebug
    }()
}

public struct ViewModelify: MemberMacro, ExtensionMacro {
    public static func expansion(of node: SwiftSyntax.AttributeSyntax, providingMembersOf declaration: some SwiftSyntax.DeclGroupSyntax, in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.DeclSyntax] {
        var res: [SwiftSyntax.DeclSyntax] = ["var wrappedValue: Self { self }"]
        if Env.isDebug {
            res.append("let inspection = Inspection<Self>()")
            res.append("var didAppear: ((Self) -> Void)?")
        }
        return res
    }

    public static func expansion(of node: SwiftSyntax.AttributeSyntax, attachedTo declaration: some SwiftSyntax.DeclGroupSyntax, providingExtensionsOf type: some SwiftSyntax.TypeSyntaxProtocol, conformingTo protocols: [SwiftSyntax.TypeSyntax], in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.ExtensionDeclSyntax] {
        guard Env.isDebug else {
            return []
        }
        let decl: DeclSyntax = """
        extension \(raw: type.trimmedDescription): View {
          var body: some View {
            let _ = Self._printChanges()
            EmptyView()
              .onAppear {
                print("\(raw: type.trimmedDescription).onAppear")
                didAppear?(self)
              }
              .onReceive(inspection.notice) {
                print("\(raw: type.trimmedDescription).onReceive")
                self.inspection.visit(self, $0)
              }
          }
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
