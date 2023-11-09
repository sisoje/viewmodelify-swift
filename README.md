# viewmodelify-swift
It starts with a value.
An int value.\
And a View.
With a frame, colors and stuff... well, we will see about that...

# Unlearning the View
Now put a value into the SwiftUI magic and blow the minds in two lines of code like this:
```
extension Int: View {
    var body: some View {
        Text("I am \(self)")
    }
}
```
All value types and only value types are potential SwiftUI Views with that Apple magic!\
But are they Views? Where are the frames and colors and shit? I better shut up and pretend its a View now.\
What is this body then? Is it a business logic? It converts value to a String and then constructs Text-struct so it has to be the busisness-logic. But Text is also a View!?\
How can business logic return a View? And why we have business-logic inside the View? What is this View anyway?\
So confusing...

# Learning the (SwiftUI) View
At least it really works, you can see the view stack of integers on the screen:
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
In order to have more control we better wrap this int-value to a struct so it has a meaning and its still a value-type:
```
struct AgeModel {
  let age: Int
}
```
And look, our model is a View like every other struct:
```
extension AgeModel: View {
  var body: some View {
    Text("My age is \(age)")
  }
}
```

# Get down to the bussiness
Now we need to move things a bit with some state:
```
struct AgeModel {
  @State var age = 21
}
```
And add some REAL business-logic to the mishmash:
```
extension AgeModel: View
  var body: some View {
       Button("My \(age + 1). bithday party") { age += 1 }
  }
}
```
Oh no, now we have the REAL business-logic and the state inside the View, even though that View is also a Model, but now its a View, a View without frame colors and stuff...\
This looks like a crap to a clean-coder. Our REAL business-logic is increasing age in the middle of the View. And we have State there! But wait View is also just a value so how do we fix this Apple crap!?\
You have to give us patterns Apple or we are doomed!

# Unlearning the MVVM
We must find a patterm or Uncle Bob will be mad at us, but how? There is no View there is only a Model!? A Model and a body Function...
### Then it has to be a MF pattern?
Wait there is no such thing as MF pattern. Our model is also a view and it updates itself. So we have State and a Function!?
### Its an SF pattern from Apple?
Now we miss V completely. All great devs use MVVM and we want to be great devs, so lets couple S+F togetherto a mishmash and call it a view-model:
```
struct StateLogicMishMash {
    @State var age = 21
    func makeBirthdayParty() { age += 1 }
}
```
Now we could make an `ObservableObject` class out of it and turn our code into a complete uncomposable-uninjectable-unrefactorable crap that we call view-model. With memory-leaks and shit.\
But hey our view-model crap will be (supposedly) testable and will make Uncle Bob happy... But will it make Apple happy?\
What if we add folowwing as a part of our business logic:
```
extension StateLogicMishMash {
    var button: Button { Button("My \(age + 1). bithday party") { makeBirthdayParty() } }
}
```
Then our View is empty and we have nowhere to go. Its a full circle, everything is a View, everything is a Model, and everything has business-logic!

# Reinventing the MVVM
Now this mishmash view-model looks like a value, so we can make it a View.\
Bbut we want to decouple things you know, decoupled is good, right? Well, not always, but it makes Uncle Bob happy because you can *test* it in isolation.\
Lets keep it a value, and make it look like view-model, for the MVVM crowd, with the full-blown support from Apple:
```
@propertyWrapper struct AgeModel: DynamicProperty {
    @State var age: Int = 21
    func makeBirthdayParty() { age += 1 }
}
```
In this way we make it more composable. Similar like our int value from beggining.\
Now wrap it into a nice View:
```
struct NiceView: View {
  @AgeModel var vm
  var body: some View {
    Button { Button("My \(vm.age + 1). bithday party") { makeBirthdayParty() } }
  }
}
```
Not too bad, but we have more to cover... We still have state and logic mishmash. State needs to be as clean as possible, cleaner than Uncle Bobs definition of clean, if there is such a definition!?\
Wish there was a way to inject logic from outside and keep State as clean as possible.

# Dependency injection
Do you still want that reference type viewmodel?\
Well Apple did screw you up. You can inject shit into your reference type viewmodel. You can only inject stuff into the View.\
For example lets say we need to inject aging-behaviour:
```
@propertyWrapper struct AgeViewModel: DynamicProperty {
    @Environment(\.agingFunction) var agingFunction
    @State var age: Int = 21
    func makeBirthdayParty() { age = agingFunction(age) }
}
```
It works automatically with value-type model that can also be a View, just inject your aging function into the View.

# Unit testing with Swift macros
How do we test our value-model that is actually a View!? But wait we dont test Views!? It makes Uncle Bob mad. Damn you Apple...\
Now great job was done by Alex implementing ViewInspector - or better call it State-inspector, so we gonna make some unit-tests.\
First make ViewInspector happy by adding inspect callback. To hide boilerplate code we use swift macros so every view-model has these two lines automatically:
```
var wrappedValue: Self { self } // for production
var inspect: ((Self) -> Void)? // for testing
```

Then, every view-model is automatically conformed to the View for testing purposes:
```
extension AgeViewModel: View {
  var body: some View { EmptyView().onAppear { inspect?(self) } }
}
```
Now tests are easy to implement.

# Conclusion
- You can isolate something that looks like a view-model and contains state with the business-logic.
- You can inject dependencies with environment.
- You can test it using ViewInspector without polluting the View.
- You can reuse the same code in multiple views.
