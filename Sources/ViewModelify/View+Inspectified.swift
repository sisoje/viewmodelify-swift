import OSLog
import SwiftUI

public extension View {
    @ViewBuilder func applyViewInspectorModifiers<V: Inspectified>(_ view: V) -> some View {
        onAppear {
            Logger().info("Inspection: \(V.self).onAppear")
            view.inspection.didAppear?(view)
        }
        .onReceive(view.inspection.notice) {
            Logger().info("Inspection: \(V.self).onReceive")
            view.inspection.visit(view, $0)
        }
    }
}
