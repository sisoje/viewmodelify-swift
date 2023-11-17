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

@attached(extension, conformances: View, names: arbitrary)
@attached(member, names: arbitrary)
public macro ViewModelify() = #externalMacro(module: "ViewModelifyMacros", type: "ViewModelify")
