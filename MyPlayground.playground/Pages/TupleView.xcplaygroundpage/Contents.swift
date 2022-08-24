// - SEEALSO: https://swiftontap.com/tupleview

import SwiftUI

struct ContentView: View {
    var body: some View {
        FirstView {
            Text("I am first 🥇")
            Text("Hey stop ignoring me ☹️")
        }
    }
}

struct FirstView<First: View>: View {
    let first: First
    
    init<Second: View>(@ViewBuilder content: () -> TupleView<(First, Second)>) {
        let views = content().value
        self.first = views.0
    }
    
    var body: some View {
        first
    }
}

let view = ContentView()
view.body
