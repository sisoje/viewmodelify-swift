import SwiftUI

@attached(extension, conformances: View, names: arbitrary)
@attached(member, names: arbitrary)
public macro ViewModelify() = #externalMacro(module: "ViewModelifyMacros", type: "ViewModelify")
