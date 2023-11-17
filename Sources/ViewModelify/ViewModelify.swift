import SwiftUI

@attached(extension, conformances: View, names: arbitrary)
@attached(member, names: arbitrary)
public macro ModelifyAppear() = #externalMacro(module: "ViewModelifyMacros", type: "ModelifyAppear")

@attached(extension, conformances: View, names: arbitrary)
@attached(member, names: arbitrary)
public macro ModelifyReceive() = #externalMacro(module: "ViewModelifyMacros", type: "ModelifyReceive")
