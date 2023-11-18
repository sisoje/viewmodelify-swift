import Combine
import SwiftUI

public final class Inspection<V> {
    public init() {}
    public let notice = PassthroughSubject<UInt, Never>()
    public var callbacks: [UInt: (V) -> Void] = [:]
    public var didAppear: ((V) -> Void)?
    public func visit(_ view: V, _ line: UInt) {
        if let callback = callbacks.removeValue(forKey: line) {
            callback(view)
        }
    }
}

public protocol ViewInspectified {
    var inspection: Inspection<Self> { get }
}

public extension View {
    @ViewBuilder func applyViewInspectorModifiers<V: ViewInspectified>(_ v: V) -> some View {
        onAppear {
            print("\(V.self).onAppear")
            v.inspection.didAppear?(v)
        }
        .onReceive(v.inspection.notice) {
            print("\(V.self).onReceive")
            v.inspection.visit(v, $0)
        }
    }
}

@attached(extension, conformances: ViewInspectified, View, names: arbitrary)
@attached(member, names: arbitrary)
public macro ViewModelify() = #externalMacro(module: "ViewModelifyMacros", type: "ViewModelify")

@attached(extension, conformances: ViewInspectified, names: arbitrary)
@attached(member, names: arbitrary)
public macro ViewInspectify() = #externalMacro(module: "ViewModelifyMacros", type: "ViewInspectify")
