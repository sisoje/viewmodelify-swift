import SwiftUI
import ViewModelify

@InspectedView
struct TestView {
    var inspectedBody: some View {
        Text("text")
    }
}

@InspectedViewModifier
struct TestModifier {
    func inspectedBody(content: Content) -> some View {
        content.disabled(true)
    }
}

@ViewModelify
@propertyWrapper struct MainModel: DynamicProperty {
    @State var value = 0
}
