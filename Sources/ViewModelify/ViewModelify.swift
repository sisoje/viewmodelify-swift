import Combine
import SwiftUI

public final class Inspection<V> {
    public init() {}
    public let notice = PassthroughSubject<UInt, Never>()
    public var callbacks: [UInt: (V) -> Void] = [:]
    public func visit(_ view: V, _ line: UInt) {
        if let callback = callbacks.removeValue(forKey: line) {
            callback(view)
        }
    }
}

public protocol ViewInspectified: View {
    var didAppear: ((Self) -> Void)? { get }
    var inspection: Inspection<Self> { get }
}

public extension View {
    @ViewBuilder func applyViewInspectorModifiers<V: View>(_ selfie: V) -> some View { self }

    @ViewBuilder func applyViewInspectorModifiers<V: ViewInspectified>(_ selfie: V) -> some View {
        onAppear {
            print("\(V.self).onAppear")
            selfie.didAppear?(selfie)
        }
        .onReceive(selfie.inspection.notice) {
            print("\(V.self).onReceive")
            selfie.inspection.visit(selfie, $0)
        }
    }
}

@attached(extension, conformances: ViewInspectified, names: arbitrary)
@attached(member, names: arbitrary)
public macro ViewModelify() = #externalMacro(module: "ViewModelifyMacros", type: "ViewModelify")

@attached(extension, conformances: ViewInspectified, names: arbitrary)
@attached(member, names: arbitrary)
public macro ViewInspectify() = #externalMacro(module: "ViewModelifyMacros", type: "ViewInspectify")
