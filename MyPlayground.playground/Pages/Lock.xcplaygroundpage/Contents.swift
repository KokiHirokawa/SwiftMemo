import Foundation

class Sample {
    private let lock = NSLock()
    private let recursiveLock = NSRecursiveLock()
    
    private var _counter = 0
    var counter: Int {
        get {
            defer { lock.unlock() }
            lock.lock()
            return _counter
        }
        set {
            defer { lock.unlock() }
            lock.lock()
            _counter = newValue
        }
    }
}

extension Sample {
    func sayEvenNumberDeadlock() {
        defer { lock.unlock() }
        lock.lock()
 
        // Deadlock
        // 同じスレッドで再帰的にlockするとデッドロックが引き起こされる
        if counter.isMultiple(of: 2) {
            print(counter)
        }
    }
    
    func sayEvenNumber() {
        defer { recursiveLock.unlock() }
        recursiveLock.lock()

        // NSRecursiveLockの場合は、同一スレッドからのロックであればデッドロックを引き起こさない
        if counter.isMultiple(of: 2) {
            print(counter)
        }
    }
}

let instance = Sample()
instance.sayEvenNumber()
