import SwiftUI

@attached(extension, conformances: Inspectified, View, names: arbitrary)
@attached(member, names: arbitrary)
public macro ViewModelify() = #externalMacro(module: "ViewModelifyMacros", type: "ViewModelify")

@attached(extension, conformances: Inspectified, names: arbitrary)
@attached(member, names: arbitrary)
public macro ViewInspectify() = #externalMacro(module: "ViewModelifyMacros", type: "ViewInspectify")
