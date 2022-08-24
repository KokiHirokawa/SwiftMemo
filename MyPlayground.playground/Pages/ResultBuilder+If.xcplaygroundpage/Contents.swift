@resultBuilder
struct AddBuilder {
    static func buildBlock() -> Int {
        0
    }
    
    static func buildBlock(_ num: Int) -> Int {
        num
    }
    
    static func buildBlock(
        _ n1: Int,
        _ n2: Int
    ) -> Int {
        n1 + n2
    }
    
    static func buildBlock(
        _ n1: Int,
        _ n2: Int,
        _ n3: Int
    ) -> Int {
        n1 + n2 + n3
    }
    
    static func buildEither(first component: Int) -> Int {
        component
    }
    
    static func buildEither(second component: Int) -> Int {
        component
    }
}

func add(@AddBuilder closure: () -> Int) -> Int {
    closure()
}

// 0
add {}

// 3
add {
    1
    2
}

// 6
add {
    1
    2
    3
}

let num = (1...100).randomElement()!
add {
    if num < 5 {
        num
    } else if num < 50 {
        num * 10
    } else {
        num * 100
    }
}
