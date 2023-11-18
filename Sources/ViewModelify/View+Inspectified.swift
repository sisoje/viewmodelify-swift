import OSLog
import SwiftUI

public extension View {
    @ViewBuilder func applyViewInspectorModifiers<V: Inspectified>(_ v: V) -> some View {
        onAppear {
            Logger().info("Inspection: \(V.self).onAppear")
            v.inspection.didAppear?(v)
        }
        .onReceive(v.inspection.notice) {
            Logger().info("Inspection: \(V.self).onReceive")
            v.inspection.visit(v, $0)
        }
    }
}
