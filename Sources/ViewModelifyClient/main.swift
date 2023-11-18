import SwiftUI
import ViewModelify

@ViewInspectify
struct SomeViewModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .applyViewInspectorModifiers(self)
    }
}

@ViewInspectify
struct SomeView: View {
    var body: some View {
        EmptyView()
            .applyViewInspectorModifiers(self)
    }
}

@ViewModelify
@propertyWrapper struct MainModel: DynamicProperty {
    @State var value = 0
}


