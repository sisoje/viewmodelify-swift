import SwiftUI
import ViewModelify

@ViewInspectify
struct SomeView: View {
    var body: some View { EmptyView().applyViewInspectorModifiers(self) }
}


@ViewModelify
@propertyWrapper struct MainModel: DynamicProperty {
    @State var value = 0
}


