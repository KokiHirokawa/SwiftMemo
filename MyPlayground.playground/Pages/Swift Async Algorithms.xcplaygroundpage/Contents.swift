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

let stream3 = AsyncStream<Int> { continuation in
    continuation.yield(4)
    continuation.yield(5)
    continuation.yield(6)
}

for await num in merge(stream, stream3) {
    print(num)
}

let batches = stream.chunked(by: .repeating(every: .milliseconds(500)))
for await nums in batches {
    print(nums)
}
