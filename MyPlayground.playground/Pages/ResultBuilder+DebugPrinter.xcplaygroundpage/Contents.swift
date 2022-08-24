// - SEEALSO: https://qiita.com/noppefoxwolf/items/26e140f874d79d52fb35

struct User: CustomDebugStringConvertible {
    let id: String
    let name: String
    let age: Int
    
    var debugDescription: String {
        "\(id)\n\(name)\n\(age)"
    }
}

@resultBuilder
struct DebugPrinter {
    static func buildBlock<T: CustomDebugStringConvertible>(
        _ component: T,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) -> T {
        print(file, function, line, component.debugDescription)
        return component
    }
}

let flag = false

@DebugPrinter
func getCurrentUser() -> User {
    User(id: "123", name: "Bob", age: 12)
}

getCurrentUser()
