// - SEEALSO: https://github.com/OpenCombine/OpenCombine/blob/ff31c4337524760d8f342ee0659cd4c4b080a82f/Sources/OpenCombine/Concurrency/GENERATED-Publisher+Concurrency.swift

import Combine
import Foundation
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

class Model: ObservableObject {
    @Published var count = 0
}

struct MyAsyncPublisher<Upstream: Publisher>: AsyncSequence where Upstream.Failure == Never {
    typealias Element = Upstream.Output
    typealias AsyncIterator = Iterator

    struct Iterator: AsyncIteratorProtocol {
        typealias Element = Upstream.Output

        fileprivate let inner: Inner

        mutating func next() async -> Element? {
            await withTaskCancellationHandler(
                handler: { [inner] in inner.cancel() },
                operation: { [inner] in await inner.next() }
            )
        }
    }

    private let publisher: Upstream

    init(_ publisher: Upstream) {
        self.publisher = publisher
    }

    func makeAsyncIterator() -> Iterator {
        let inner = Iterator.Inner()
        publisher.subscribe(inner)
        return Iterator(inner: inner)
    }
}

extension MyAsyncPublisher.Iterator {

    fileprivate final class Inner: Subscriber, Cancellable {

        typealias Input = Upstream.Output
        typealias Failure = Upstream.Failure

        private enum State {
            case awaitingSubscription
            case subscribed(Subscription)
            case terminal
        }

        private let lock = NSLock()
        private var pending: [UnsafeContinuation<Input?, Never>] = []
        private var state = State.awaitingSubscription
        private var pendingDemand = Subscribers.Demand.none

        func receive(subscription: Subscription) {
            lock.lock()

            guard case .awaitingSubscription = state else {
                lock.unlock()
                subscription.cancel()
                return
            }

            state = .subscribed(subscription)
            let pendingDemand = self.pendingDemand
            self.pendingDemand = .none
            lock.unlock()

            if pendingDemand != .none {
                subscription.request(pendingDemand)
            }
        }

        func receive(_ input: Upstream.Output) -> Subscribers.Demand {
            print("receive input")

            lock.lock()

            guard case .subscribed = state else {
                let pending = self.pending.take()
                lock.unlock()
                pending.resumeAllWithNil()
                return .none
            }

            precondition(
                !pending.isEmpty,
                "Received an output without requesting demand"
            )
            let continuation = pending.removeFirst()
            lock.unlock()
            continuation.resume(returning: input)
            return .none
        }

        func receive(completion: Subscribers.Completion<Failure>) {
            print("receive completion")

            lock.lock()
            state = .terminal
            let pending = self.pending.take()
            lock.unlock()
            pending.resumeAllWithNil()
        }

        func cancel() {
            print("cancel")

            lock.lock()
            let pending = self.pending.take()
            guard case .subscribed(let subscription) = state else {
                state = .terminal
                lock.unlock()
                pending.resumeAllWithNil()
                return
            }
            state = .terminal
            lock.unlock()
            subscription.cancel()
            pending.resumeAllWithNil()
        }
        
        fileprivate func next() async -> Input? {
            print("next")
            // - NOTE: ここは何故Unsafe?
            return await withUnsafeContinuation { continuation in
                lock.lock()

                switch state {
                case .awaitingSubscription:
                    // - NOTE: continuationを外出しする
                    pending.append(continuation)
                    pendingDemand += 1 // - NOTE: ??
                    lock.unlock()
                case .subscribed(let subscription):
                    // - NOTE: continuationを外出しする
                    pending.append(continuation)
                    lock.unlock()
                    subscription.request(.max(1)) // - NOTE: ??
                case .terminal:
                    lock.unlock()
                    continuation.resume(returning: nil)
                }
            }
        }
    }
}

extension Sequence {
    func resumeAllWithNil<Output, Failure: Error>()
        where Element == UnsafeContinuation<Output?, Failure> {
            for continuation in self {
                continuation.resume(returning: nil)
            }
    }
}

extension Array {
    mutating func take() -> Self {
        let taken = self
        self = .init()
        return taken
    }
}

let model = Model()
let asyncPublisher = MyAsyncPublisher(model.$count)

for await value in asyncPublisher {
    print("result: \(value)")

    // 初期値が2回呼ばれてるが、バグ？👾
    // result: 1
    // result: 1
}

model.count = 1
model.count = 10
model.count = 100
