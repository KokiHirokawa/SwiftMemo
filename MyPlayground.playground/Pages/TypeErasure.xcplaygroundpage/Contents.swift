// - SEEALSO: https://qiita.com/omochimetaru/items/5d26b95eb21e022106f0

// Type Erasure
// あるprotocolを満たす複数の型があるとき、それらのどれでも代入できる互換性のある型

protocol AnimalProtocol {
    func eat(food: String)
}

do {
    class Cat: AnimalProtocol {
        func eat(food: String) {
            print("mogumogu \(food)")
        }
    }

    var a: AnimalProtocol = Cat()

    // protocol自体は自身のprotocolを満たさないため...

    func g<X: AnimalProtocol>(_ x: X) {
        x.eat(food: "🍡")
    }
    // g(a) 🙅‍♂️

    // type 'any AnimalProtocol' cannot conform to 'AnimalProtocol'
    // only concrete types such as structs, enums and classes can conform to protocols

    class AnimalHouse<X: AnimalProtocol> {}
    // AnimalHouse<AnimalProtocol>() 🙅‍♂️

    class AnyAnimal: AnimalProtocol {
        private let base: AnimalProtocol

        init(_ base: AnimalProtocol) {
            self.base = base
        }

        func eat(food: String) {
            base.eat(food: food)
        }
    }

    var animal = AnyAnimal(a)
    g(animal)
}

protocol AnimalProtocolHasAssociatedType {
    associatedtype Food

    func eat(food: Food)
}

do {
    class Dog: AnimalProtocolHasAssociatedType {
        func eat(food: String) {
            print("mogumogu \(food)")
        }
    }

    class AnyAnimal<Food>: AnimalProtocolHasAssociatedType {
        // private let base: AnimalProtocolHasAssociatedType<Food>
        // Cannot specialize protocol type 'AnimalProtocolHasAssociatedType'

        private let _eat: (Food) -> Void

        init<X: AnimalProtocolHasAssociatedType>(_ base: X) where X.Food == Food {
            self._eat = { base.eat(food: $0) }
        }

        func eat(food: Food) {
            _eat(food)
        }
    }

    let dog = Dog()
    let animal = AnyAnimal<String>(dog)

    struct AnimalHouse<AnimalProtocoHasAssocitedType> {}
}

protocol AnimalProtocolIncludeSelf {
    associatedtype Food

    func eat(food: Food)
    func spawn() -> Self
    func fight(_ x: Self)
}

do {
    class Cat: AnimalProtocolIncludeSelf {
        required init() {}

        func eat(food: String) {
            print("mogumogu \(food)")
        }

        func spawn() -> Self {
            type(of: self).init()
        }

        func fight(_ x: Cat) {}
    }

    class AnyAnimalBox<Food> {
        func eat(food: Food) { fatalError("abstract") }
        func spawn() -> AnyAnimalBox<Food> { fatalError("abstract") }
        func fight(_ x: AnyAnimalBox<Food>) { fatalError("abstract") }
    }

    class AnimalBox<X: AnimalProtocolIncludeSelf>: AnyAnimalBox<X.Food> {
        private let base: X

        init(_ base: X) {
            self.base = base
        }

        override func eat(food: X.Food) {
            base.eat(food: food)
        }

        override func spawn() -> AnyAnimalBox<X.Food> {
            AnimalBox<X>(base.spawn())
        }

        override func fight(_ x: AnyAnimalBox<X.Food>) {
            base.fight((x as! AnimalBox<X>).base)
        }
    }

    final class AnyAnimal<Food>: AnimalProtocolIncludeSelf {
        private let box: AnyAnimalBox<Food>

        init<X: AnimalProtocolIncludeSelf>(_ base: X) where X.Food == Food {
            self.box = AnimalBox<X>(base)
        }

        private init(box: AnyAnimalBox<Food>) {
            self.box = box
        }

        func eat(food: Food) {
            box.eat(food: food)
        }

        func spawn() -> AnyAnimal<Food> {
            AnyAnimal<Food>(box: box.spawn())
        }

        func fight(_ x: AnyAnimal<Food>) {
            box.fight(x.box)
        }
    }
}
