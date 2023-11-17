import Combine
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import SwiftUI
@testable import ViewModelify
import XCTest

// Macro implementations build for the host, so the corresponding module is not available when cross-compiling. Cross-compiled tests may still make use of the macro itself in end-to-end tests.
#if canImport(ViewModelifyMacros)

#endif

struct TestInspection<V> {
    public let notice = PassthroughSubject<UInt, Never>()
    public func visit(_ view: V, _ line: UInt) {}
}

typealias Inspection = TestInspection

@ViewModelify
@propertyWrapper struct TestModel: DynamicProperty {}

final class ViewModelifyTests: XCTestCase {
    func testModel() throws {
        #if canImport(ViewModelifyMacros)
        let vm = TestModel()
        vm.didAppear?(vm)
        vm.inspection.visit(vm, 0)
        _ = vm.inspection.notice.sink { _ in }
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
}
