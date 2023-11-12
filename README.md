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
Int value as a view really works. You can see the stack of integer-views on the screen and the code is clean. Uncle Bob would not agree, but its clean:
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
Where are the frames colors and shit? How do we make view-model when there is no view?

### Virtual views 
Note that Apple developed SwifUI by using ideas from ELM/MVU architecture. Some call ELM views "virtual views", maybe we can call them too?

# States
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
Now we have more business-logic and the state inside the View...

### Give us patterns Apple or we are doomed!
This looks like a crap to a clean-coder dev. Our business-logic is increasing the `age` in the middle of the View. How do we fix this Apple crap?

# Apple killed MVVM
Real devs need a pattern, a **solid** name for it, and then stick to that pattern no matter what.\
SwiftUI view is actually a **M**odel with a body **F**unction.
### It has to be a **MF** pattern?
But that name should be banned. We also have a **S**tate and a **F**unction.
### Is it a new **SF** pattern from Apple?
That would be a perfect name for Apple they love SF, but thats not a good practice.
### Introducing VM in SwiftUI
All great devs use some kind of MV* pattern. MVVM proved to be a great success. Lets couple state and functions together to a mishmash class and call it a view-model:
```
class SFViewmodel: ObservableObject {
    @Published var age = 21
    func makeBirthdayParty() { age += 1 }
}
```
Our button is also just a value, a model. It is part of our business-logic so lets complete our viewmodel:
```
extension SFViewmodel {
    var body: some View { Button("My \(age + 1). bithday party", action: makeBirthdayParty) }
}
```
### ViewModel = Model = View!
Look, our view is now empty, everything is in the view model. We reinvented SwiftUI only now it is a reference-type crap, with memory leaks and shit! We captured `self` in the button already. Its very easy to make leaks.

### But its testablah
Maybe, but it is a class, a reference-type. We can not inject environment inside a class. We can inject environment only into a value type that is inside SwiftUI view hierarchy. Whats the point of testing something that does not work properly?

### But Apple made ObservableObject for a reason
Yes, Apple made ObservableObject when we want to use a state that outlives the current view so we can attach to that state using ObservedObject or EnvironmentObject. Apple did not make ObservableObject so you can copy code from a struct and paste it to a class.

# Decoupling
As our projekct grows some view will get bigger and it would be good to decouple some parts out of the view.
### Decoupled is good, right?
Well, not always, because you need to glue decoupled parts together eventually, and glue can be messy... But it makes Uncle Bob happy because you can **test** decoupled parts in isolation.
### Decouple without breaking
Decoupling using ObservableObject proved to be a major fail. We have to find a way that does not break things.
### DynamicProperty
DynamicProperty allows us to use value types and will work inside view hierachies:
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
There is no View remember. There is no VIEW-model either. We will test SwiftUI views as they are - values with states.
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
To hide boilerplate code we use swift macros so every model has boilerplate lines automatically. Use macro `ViewModelify` in your code and attach it to the property wrapper that is your model:
```
@ViewModelify
@propertyWrapper struct AgeModel: DynamicProperty {
    @State var age: Int = 21
    func makeBirthdayParty() { age += 1 }
}
```
### Note that model `wrappedValue` will be generated also
Wrapped value is always this:
```
var wrappedValue: Self { self }
```
After adding the macro our `AgeModel` will act as a SwiftUI view in the tests so we can test it using ViewInspector
