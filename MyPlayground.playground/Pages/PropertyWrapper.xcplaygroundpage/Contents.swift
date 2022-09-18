// - SEEALSO: https://dev.classmethod.jp/articles/property-wrappers/

@propertyWrapper
enum Lazy<Value> {
    case uninitialized(() -> Value)
    case initialized(Value)

    init(wrappedValue: @autoclosure @escaping () -> Value) {
        self = .uninitialized(wrappedValue)
    }

    var wrappedValue: Value {
        mutating get {
            switch self {
            case .uninitialized(let initializer):
                let value = initializer()
                self = .initialized(value)
                return value
            case .initialized(let value):
                return value
            }
        }
        set {
            self = .initialized(newValue)
        }
    }
}

extension Lazy {
    mutating func reset(_ newValue: @autoclosure @escaping () -> Value) {
        self = .uninitialized(newValue)
    }
}

class Controller {
    @Lazy var foo = 2000

    func reset() {
        _foo.reset(0)
    }
}

let c = Controller()
c.foo
c.foo = 3000
c.foo
c.reset()
c.foo
