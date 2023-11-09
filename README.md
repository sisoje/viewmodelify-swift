# viewmodelify-swift
It starts with a value.
An int value.\
And a View.
With a frame, colors and shit... well, not so fast you Android kid.

# Unlearning the View
Now put a value into the SwiftUI magic and blow the minds of all the Android devs in two lines of code like this:
```
extension Int: View {
    var body: some View {
        Text("I am \(self)")
    }
}
```
All value types and only value types are actually views with that Apple magic! But are they? Where are the frames and colors and shit? I better shut up and pretend its a View now...

# Learning the (SwiftUI) View
Yes it really works, you can see the view on the screen:
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
struct Age {
  let age: Int
}
```
And look, its still a View:
```
extension Age: View {
  var body: some View {
    Text("My age is \(age)")
  }
}
```
So now Android devs are even more confused and we have only started...

# Get down to the bussiness
Now we need to move things a bit with some business logic, lets make full blown mishmash:
```
struct AgeView: View {
  @State var age = 21
  var body: some View {
    Button("Bithday party") { age += 1 }
    Text("My age is \(age)")
  }
}
```

Oh shit, now we have the business logic and a state inside the View that is not even a View! Now this looks like a crap to an Android dev. Aging is our business-logic. And State is inside the View! But wait View is also just a value so how do we fix this Apple crap!? You have to give us patterns Apple or we are doomed!

# Unlearning the MVVM
We must find a patterm or Uncle Bob will be mad at us, but how when:
- There is no View - there is only a Value, a Model!? Is it M pattern?
- There is no Model - everything is a View!? Is it V pattern?
- Is the whole body actually a business logic blob? Is it MVU? Maybe, but lets pretend its not...

So basically we have a Model and the Logic that creates the View.
Now, lets move state and non-ui logic mishmash and call it a view-model:
```
struct StateLogicMishMash {
    @State var age = 21
    func makeBirthdayParty() { age += 1 }
}
```
Now we could make an `ObservableObject` class out of it and turn our code into a complete uncomposable-uninjectable-unrefactorable crap that we call view-model. With memory-leaks and shit.\
But hey our view-model crap will be (supposedly) testable and will make Uncle Bob happy... or better not!?

# Reinventing the MVVM
Now this mishmash view-model looks like a value, so we can make it a View?\
Yes we could make it a View, but we want to decouple things you know, decoupled is good, right? Well, not always, but it makes Uncle Bob happy because you can test it in isolation.\
Lets keep it a value, and make it look like view-model, for the Android crowd, with the full-blown support from Apple:
```
@propertyWrapper struct AgeViewModel: DynamicProperty {
    @State var age: Int = 21
    func makeBirthdayParty() { age += 1 }
}
```
And now wrap it into a nice View:
```
struct NiceView: View {
  @AgeViewModel var vm
  var body: some View {
    Button("Bithday party") { vm.makeBirthdayParty() }
    Text("My age is \(vm.age)")
  }
}
```
Not too bad, but we have more to cover... We still have state and logic mishmash. State needs to be as clean as possible, cleaner than Uncle Bobs definition of clean, if there is such a definition!? 

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

# Testing value-model that is actually a View!?
How do we test this? After all, tests make Uncle Bob happy, unit-tests most of all. But wait we dont test Views? It makes Uncle Bob cry damn you Apple...

# ViewInspector
Now great job was done by Alex implementing ViewInspector - or better call it Value-inspector, so dont cry Uncle Bob, we gonna make some tests.\
First make ViewInspector happy by adding:
```
var inspect: ((Self) -> Void)?
```

Then interpret value-model as a View just for the test:
```
extension AgeViewModel: View {
  var body: some View { EmptyView().onAppear { inspect?(self) } }
}
```
And make an easy test.

# Swift macros
To hide boilerplate code we use swift macros so every model has these two lines:
```
var wrappedValue: Self { self } // for production
var inspect: ((Self) -> Void)? // for testing
```
And every model is automatically conformed to the view - for testing purposes.

# end



