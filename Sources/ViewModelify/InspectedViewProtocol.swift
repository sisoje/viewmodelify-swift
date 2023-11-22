import OSLog
import SwiftUI
import ViewModelifyMacros

public protocol InspectedViewProtocol: View, InspectionHolder {
    associatedtype InspectedBody: View
    @ViewBuilder @MainActor var inspectedBody: InspectedBody { get }
}

public extension InspectedViewProtocol {
    @ViewBuilder @MainActor var body: some View {
        if #available(macOS 12, iOS 15, tvOS 15, watchOS 8, macCatalyst 15, *) {
            let _ = assert(Self._printChanges() == ())
        }
        inspectedBody.applyInspection(self)
    }
}
