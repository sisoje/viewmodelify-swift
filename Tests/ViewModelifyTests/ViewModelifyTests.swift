import Combine
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import SwiftUI
@testable import ViewModelify
import XCTest

// Macro implementations build for the host, so the corresponding module is not available when cross-compiling. Cross-compiled tests may still make use of the macro itself in end-to-end tests.
#if canImport(ViewModelifyMacros)

#else

@ViewInspectify
struct v: View {
    var body: some View {
        Text("hey")
            .applyViewInspectorModifiers(self)
    }
}

class t: XCTestCase {
    func testMAcros() {

        
        let t = v().body
        
    }
}

#endif

