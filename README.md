# viewmodelify-swift helpers for ViewInspector

### SwiftUI.View is just a value
SwiftUI.View does not have properties of a standard view.
There is no frame, no color, nothing that a view should have.
It is just a protocol that you can conform ANY value to.
It does not even have to be a struct.

### Business logic
All functionality that is inside the SwiftUI.View conforming value is some business logic.
The `body` property is also some business logic. We usually keep `body` inside the SwiftUI.View struct. We do not decouple it to some piece of junk code just so we could test it.
However we can decouple some of the business logic out of the SwiftUI.View into a separate unit of code, but we have to do it properly.

### Decoupling using Observable classes
The process of abusing Observable classes is described here: [From SwiftUI “vanilla” to MVVM like a “pro”
](https://medium.com/@redhotbits/from-swiftui-vanilla-to-mvvm-like-a-pro-470b22f304c9).

### Decoupling using structs
Unlike Observable classes the DynamicProperty structs will fully work inside SwiftUI view hierachies. We can decouple some of the business logic out of the SwiftUI.View without breaking stuff:
```
@ViewModelify
@propertyWrapper struct SwiftDataModel: DynamicProperty {
    @Environment(\.modelContext) private var modelContext
    @Query var items: [Item]
    func addItem() {}
}

@ViewInspectify
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

### Macros
We can test both our view and our model in the same way:
- For models we use @ViewModelify macro
- For views we use @ViewInspectify macro

### Boilerplate code
This package implements some of the boilerplate:
- Inspection class
- applyViewInspectorModifiers

### InspectionEmissary
Only thing left for you to add in your TEST target is:
```
extension Inspection: InspectionEmissary { }
```
This may be not needed in future.
