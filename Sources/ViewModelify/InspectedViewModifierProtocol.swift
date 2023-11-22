import SwiftUI

public protocol InspectedViewModifierProtocol: ViewModifier, InspectionHolder {
    associatedtype InspectedBody: View
    @ViewBuilder @MainActor func inspectedBody(content: Content) -> InspectedBody
}

public extension InspectedViewModifierProtocol {
    @ViewBuilder @MainActor func body(content: Content) -> some View {
        inspectedBody(content: content).applyInspection(self)
    }
}
