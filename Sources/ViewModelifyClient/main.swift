import Combine
import SwiftUI
import ViewModelify

@ModelifyAppear
struct ModelAppear {
    let int: Int
}

struct Inspection<T> {
    let notice = PassthroughSubject<Int, Never>()
    func visit(_ t: T, _ x: Int) {}
}

@ModelifyReceive
struct ModelReceive {
    let int: Int
}
