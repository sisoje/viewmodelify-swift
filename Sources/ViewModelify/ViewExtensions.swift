import OSLog
import SwiftUI

extension View {
    func applyInspection<V: InspectionHolder>(_ view: V) -> some View {
        onReceive(view.inspection.notice) {
            Logger().info("Inspection notice: \(V.self).onReceive")
            view.inspection.visit(view, $0)
        }
    }
}
