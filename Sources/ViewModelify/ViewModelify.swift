import SwiftUI

@attached(extension, conformances: InspectedViewProtocol, names: arbitrary)
@attached(member, names: arbitrary)
public macro ViewModelify() = #externalMacro(module: "ViewModelifyMacros", type: "ViewModelify")

@attached(extension, conformances: InspectedViewProtocol, names: arbitrary)
@attached(member, names: arbitrary)
public macro InspectedView() = #externalMacro(module: "ViewModelifyMacros", type: "InspectedView")

@attached(extension, conformances: InspectedViewModifierProtocol, names: arbitrary)
@attached(member, names: arbitrary)
public macro InspectedViewModifier() = #externalMacro(module: "ViewModelifyMacros", type: "InspectedViewModifier")
