import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest
@testable import ViewModelify
import SwiftUI

// Macro implementations build for the host, so the corresponding module is not available when cross-compiling. Cross-compiled tests may still make use of the macro itself in end-to-end tests.
#if canImport(ViewModelifyMacros)

#endif

@ViewModelify
@propertyWrapper struct ViewModel: DynamicProperty {}

final class ViewModelifyTests: XCTestCase {
    func testMacro() throws {
        #if canImport(ViewModelifyMacros)
        let vm = ViewModel()
        XCTAssertNil(vm.inspect)
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
}
