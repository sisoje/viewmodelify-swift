import SwiftUI
import ViewModelify

@ViewModelify
@propertyWrapper struct MainModel: DynamicProperty {
    @State var value = 0
}
