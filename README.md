# viewmodelify-swift helpers for ViewInspector

### SwiftUI.View is just a value
SwiftUI.View does not have properties like a standard view.
There is no frame, no color, nothing that a view should have.
It is just a protocol that you can conform ANY value to.
It does not even have to be a struct. It is just a value.

### Business logic
All functionality that is inside the SwiftUI.View conforming value is some business logic.
The `body` property is also some business logic. We usually keep `body` inside the SwiftUI.View struct. We never decouple `body` into some piece of junk code just so we could test it.
However we can decouple some of the business logic out of the SwiftUI.View into a separate unit of code, but we have to do it properly.

### Decoupling with Observable classes
In his [SwiftData](https://www.hackingwithswift.com/quick-start/swiftdata/how-to-use-mvvm-to-separate-swiftdata-from-your-views) article, Paul Hudson clearly shows the failure of Observable classes with SwiftData and states:
> a number of people have said outright that they think MVVM is dead with SwiftData

Actually, this kind of class type abusement called MVVM should have been dead long time ago in SwiftUI. I described it in more detail here: [From SwiftUI to MVVM
](https://medium.com/@redhotbits/from-swiftui-vanilla-to-mvvm-like-a-pro-470b22f304c9).

### Decoupling with DynamicProperty structs
Unlike Observable classes the DynamicProperty structs will fully work inside SwiftUI view hierachies. We can decouple some of the business logic out of the SwiftUI.View without breaking stuff:
```
@propertyWrapper struct SwiftDataModel: DynamicProperty {
    @Environment(\.modelContext) private var modelContext
    @Query var items: [Item]
    func addItem() {}
}

struct SwiftDataView: View {
  @SwiftDataModel var model
  var body: some View {
    VStack {
      Text("There are \(model.items.count) items")
      Button("Add item", action: model.addItem)
    }
  }
}
```
We can test our model in the same way as we would test a view because it is a struct, a value - so it can conform to SwiftUI.View!

### Macros
For models we use @ViewModelify:
```
@ViewModelify
@propertyWrapper struct SwiftDataModel: DynamicProperty {
    @Environment(\.modelContext) private var modelContext
    @Query var items: [Item]
    func addItem() {}
}
```
For views we use @InspectedView:
```
@InspectedView
struct SomeView {
    var inspectedBody: some View {
        Text("text")
    }
}
```
For view modifiers we use @InspectedViewModifier:
```
@InspectedViewModifier
struct TestModifier {
    func inspectedBody(content: Content) -> some View {
        content.disabled(true)
    }
}
```

### Boilerplate code
This package implements some of the boilerplate for out APP target:
- Inspection class
- applyViewInspectorModifiers

### InspectionEmissary
Only thing left for you to add in your TEST target is:
```
import ViewModelify
import ViewInspector
extension Inspection: InspectionEmissary { }
```
