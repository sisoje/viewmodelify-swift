import Combine

//#if canImport(ViewInspector)
//import ViewInspector
//extension Inspection: InspectionEmissary {}
//#endif

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
