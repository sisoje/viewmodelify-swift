# viewmodelify-swift
It starts with a value. An Int value.\
And a View. With a frame, colors and shit... well, we will see about that...

# Unlearning the View
Now put a value into the SwiftUI and your mind is blown in two lines of code, like this:
```
extension Int: View {
    var body: some View {
        Text("I am \(self)")
    }
}
```
All value types and only value types are potential SwiftUI Views with that Apple magic!

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
We must find a patterm or Uncle Bob will be mad at us, but how? There is no View there is only a Model!? A **M**odel with a body **F**unction...
### Then it has to be a **MF** pattern?
Wait there is no such thing as MF pattern... Lets see, we have a **S**tate and a **F**unction!?
### Is it a new **SF** pattern from Apple?
Now we miss MV* completely. How can we have a pattern without MV*? All great devs use some MV* pattern. Lets couple some state and some functions together to a mishmash class and call it a view-model:
```
class SFViewmodel: ObservableObject {
    @Published var age = 21
    func makeBirthdayParty() { age += 1 }
}
```
But wait, our button is also just a value, a struct, a model! It is also part of our business-logic so lets complete our viewmodel:
```
extension SFViewmodel {
    var button: some View { Button("My \(age + 1). bithday party", action: makeBirthdayParty) }
}
```
Congrats! We reinvented SwiftUI but its a reference-type crap, with memory leaks and shit!

### But its testablah!?
Hey, we can not even inject environment here. So its not even testable. Apple does not support this crap. Just stop it already!

# Apple killed MVVM
What if we could keep this viewmodel as a value type and have it decoupled from the view? Just for fun...
### Decoupled is good, right?
Well, not always, you need to glue decoupled parts together eventually, and glue can be messy... But it makes Uncle Bob happy because you can **test** decoupled parts in isolation.
### Values decoupled
Here is how to make a value-type model with the full-blown support from Apple:
```
@propertyWrapper struct AgeModel: DynamicProperty {
    @State var age: Int = 21
    func makeBirthdayParty() { age += 1 }
}
```
In this way we make it composable (and testable). Now shove this model into any view, here is a nice View:
```
struct NiceView: View {
  @AgeModel var vm
  var body: some View {
    Button { Button("My \(vm.age + 1). bithday party") { vm.makeBirthdayParty() } }
  }
}
```
### Clean state
State needs to be as clean as possible, cleaner than Uncle Bobs definition of clean. We can inject some logic as dependency and make state cleaner.
```
@propertyWrapper struct AgeModel: DynamicProperty {
    @Environment(\.agingFunction) var agingFunction
    @State var age: Int = 21
    func makeBirthdayParty() { age = agingFunction(age) }
}
```
As Apple says it just works!

# Testing
How do we test our model that is actually a view? Good devs never test views! It makes Uncle Bob mad. Damn you Apple...
### What are we testing?
There is no View remember. We test values and states.
### Unit tests
Great job was done by Alex implementing ViewInspector, so we can make some unit-tests with SwitUI views because they are not views.
### Setting up Viewinspector
First make ViewInspector happy by adding inspect callback. To hide boilerplate code we use swift macros so every model has these two lines automatically:
```
var wrappedValue: Self { self } // for production
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
