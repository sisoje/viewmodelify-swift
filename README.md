# viewmodelify-swift
It starts with a value. An Int value.\
And a View. With a frame and colors and shit... well, we will see about that...

# Unlearning the View
Now put a value into the SwiftUI and your mind is blown in two lines of code, like this:
```
extension Int: View {
    var body: some View {
        Text("I am \(self)")
    }
}
```
All value types and only value types can be SwiftUI Views with that Apple magic!

### Business logic
What is this body then? Is it a business logic? It converts value to a String and then constructs Text struct value so it has to be the busisness-logic. But Text is also a View!?
### How can business logic return a View?
Why do we have business-logic inside the View? Hey Apple what is this really a View? So confusing...

# Learning the Model
At least it works. You can see the view stack of integer-views on the screen and the code is clean. Uncle Bob would not agree, but its clean:
```
struct ContentView: View {
    var body: some View {
        VStack {
            1
            2
            3
        }
    }
}
```
In order to have more context we better wrap this int value to a struct and its still a value-type:
```
struct AgeModel {
  let age: Int
}
```
### Model = View
And look, our model is a View like every other struct:
```
extension AgeModel: View {
  var body: some View {
    Text("My age is \(age)")
  }
}
```
### There are no Views its all Models!
Where are the frames colors and shit? WTF Apple!?

# Get down to the bussiness
Now we need to move things a bit with some state:
```
struct AgeModel {
  @State var age = 21
}
```
And add some more business-logic to the mishmash:
```
extension AgeModel: View
  var body: some View {
       Button("My \(age + 1). bithday party") { age += 1 }
  }
}
```
Oh no! Now we have more business-logic and the state inside the View...

### Give us patterns Apple or we are doomed!
This looks like a crap to a clean-coder dev. Our business-logic is increasing the `age` in the middle of the View. How do we fix this Apple crap!?

# Unlearning the MV*
Real devs need a pattern, a **solid** name for it, and then stick to that pattern no matter what. Could we make it look like a good old MVVM?
### It has to be a **MF** pattern?
Its a **M**odel with a body **F**unction. But that name should be banned.
### Is it a new **SF** pattern from Apple?
We have a **S**tate and a **F**unction. Apple loves **SF** that would be a perfect name.\
Now we miss MV* completely. All great devs use some MV* pattern. Lets couple state and functions together to a mishmash class and call it a view-model:
```
class SFViewmodel: ObservableObject {
    @Published var age = 21
    func makeBirthdayParty() { age += 1 }
}
```
But wait, our button is also just a value, a struct, a model! It is also part of our business-logic so lets complete our viewmodel:
```
extension SFViewmodel {
    var body: some View { Button("My \(age + 1). bithday party", action: makeBirthdayParty) }
}
```
### ViewModel = Model = View!
Look, we did a complete View -> ViewModel rewrite. We reinvented SwiftUI only now it is a reference-type crap, with memory leaks and shit! Yes there is a referrence cycle there already!

### But its testablah
Maybe, but it can never be a SwiftUI view because its a class, a reference-type. We can not inject environment into a class. We can inject environment only into a value that is a SwiftUI view. So its not even properly testable in SwiftUI. Apple does not support this crap.

### But Apple made ObservableObject for a reason
Yes, Apple made ObservableObject when we want to create a state that outlives the current view so other views can attach to that state using ObservedObject or EnvironmentObject. Apple did not make ObservableObject so you can copy code from a struct and paste it to a class and make a crappy replica of SwiftUI.

# Apple killed MVVM
What if we could write this viewmodel as a value type and have it decoupled from the parent view?
### Decoupled is good, right?
Well, not always, you need to glue decoupled parts together eventually, and glue can be messy... But it makes Uncle Bob happy because you can **test** decoupled parts in isolation.
### Values decoupled
Here is how to make a value-type model with the full-blown support from Apple:
```
@propertyWrapper struct AgeModel: DynamicProperty {
    @State var age: Int = 21
    func makeBirthdayParty() { age += 1 }
    var wrappedValue: Self { self }
}
```
In this way we make it composable (and testable). Now shove this model into any view. Here is a nice View:
```
struct NiceView: View {
  @AgeModel var model
  var body: some View {
    Button { Button("My \(model.age + 1). bithday party") { model.makeBirthdayParty() } }
  }
}
```
### Clean state
State needs to be as clean as possible, cleaner than Uncle Bobs definition of clean. We can inject some logic as dependency and make state even cleaner.
```
@propertyWrapper struct AgeModel: DynamicProperty {
    @Environment(\.agingFunction) var agingFunction
    @State var age: Int = 21
    func makeBirthdayParty() { age = agingFunction(age) }
}
```
As Apple says it just works!

# Testing
How do we test our model that is actually a view? Real devs never test views!
### What are we testing?
There is no View remember. We will test values and states.
### Unit tests
Great job was done by Alex implementing ViewInspector, so we can make some unit-tests with SwitUI views because they are just models.
### Setting up Viewinspector
First make ViewInspector happy by adding inspect callback.
```
var inspect: ((Self) -> Void)? // for testing
```

Then, every model is automatically conformed to the View for testing purposes:
```
extension AgeModel: View {
  var body: some View { EmptyView().onAppear { inspect?(self) } }
}
```
Now tests are easy to implement.

# Conclusion
- You can isolate most of the business-logic into a property wrapper.
- You can inject dependencies with environment.
- You can test it using ViewInspector without polluting the View.
- You can reuse the same code in multiple views.

# Usage
To hide boilerplate code we use swift macros so every model has boilerplate lines automatically. Just use attached macro `ViewModelify` in your code and attach it to the property wrapper that is your decoupled model:
```
@ViewModelify
@propertyWrapper struct AgeModel: DynamicProperty {
    @State var age: Int = 21
    func makeBirthdayParty() { age += 1 }
}
```
### Note that `wrappedValue` will be generated also
After adding the macro our `AgeModel` will act as a SwiftUI view in the tests so we can test it using ViewInspector
