import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

func theAnswer() async -> Int { 42 }

async let a = theAnswer()
