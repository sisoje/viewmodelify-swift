import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest
@testable import ViewModelify
import SwiftUI
import Combine

// Macro implementations build for the host, so the corresponding module is not available when cross-compiling. Cross-compiled tests may still make use of the macro itself in end-to-end tests.
#if canImport(ViewModelifyMacros)

#endif

@ModelifyAppear
@propertyWrapper struct ModelAppear: DynamicProperty {}

struct Inspection<T> {
    let notice = PassthroughSubject<Int, Never>()
    func visit(_ t: T, _ x: Int) {}
}

@ModelifyReceive
@propertyWrapper struct ModelReceive: DynamicProperty {}

final class ViewModelifyTests: XCTestCase {
    func testAppear() throws {
        #if canImport(ViewModelifyMacros)
        let vm = ModelAppear()
        vm.inspect?(vm)
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
    func testReceive() throws {
        #if canImport(ViewModelifyMacros)
        let vm = ModelReceive()
        vm.inspection.visit(vm, 0)
        _ = vm.inspection.notice.sink { _ in }
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
}
