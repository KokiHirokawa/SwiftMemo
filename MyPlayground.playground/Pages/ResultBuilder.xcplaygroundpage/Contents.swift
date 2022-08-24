// - SEEALSO: https://llcc.hatenablog.com/entry/2020/03/22/151751

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Text("1")
            Text("2")
        }
    }
}

struct ContentView_Copy: View {
    var body: some View {
        VStack {
            ViewBuilder.buildBlock(
                Text("1"),
                Text("2")
            )
        }
    }
}

// - SEEALSO: https://developer.apple.com/documentation/swiftui/viewbuilder/buildblock(_:_:)

@resultBuilder
struct MyStruct {
    static func buildBlock(_ v1: Int) -> Int {
        v1
    }
    
    static func buildBlock(
        _ v1: Int,
        _ v2: Int
    ) -> Int {
        v1 + v2
    }
    
    static func buildBlock(
        _ v1: Int,
        _ v2: Int,
        _ v3: Int
    ) -> Int {
        v1 + v2 + v3
    }
}

func myFunc(@MyStruct closure: () -> Int) -> Int {
    closure()
}

myFunc {
    1
    2
}
