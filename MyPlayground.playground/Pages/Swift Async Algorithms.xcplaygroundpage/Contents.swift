import AsyncAlgorithms

let stream = AsyncStream<Int> { continuation in
    continuation.yield(1)
    continuation.yield(2)
    continuation.yield(3)
}

let stream2 = AsyncStream<String> { continuation in
    continuation.yield("🍎")
    continuation.yield("🍒")
    continuation.yield("🥐")
}

for await (num, str) in zip(stream, stream2) {
    print(num, str)
}
