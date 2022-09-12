import Foundation
import RegexBuilder

do {
    let input = "My name is Taylor Swift"

    let regex = try! NSRegularExpression(
        pattern: "My name is (\\w*)",
        options: .caseInsensitive
    )

    let matches = regex.matches(
        in: input,
        options: [],
        range: NSRange(location: 0, length: input.utf16.count)
    )

    if let match = matches.first {
        let range = match.range(at: 1)
        if let swiftRange = Range(range, in: input) {
            let name = input[swiftRange]
        }
    }
}

do {
    // let regex = /My name is (.*)/

    // 動的なパターン生成
    // let regex = try Regex("My name is \(nameFormat)")

    let input = "My name is Taylor Swift"

    // コンパイル時にシンタックスエラーが出るため、tryが不要になっている
    let regex: Regex<(Substring, name: Substring)> = /My name is (?<name>.*)/.ignoresCase()

    let matches = input.matches(of: regex)
    if let match = matches.first {
        match.name
        match.0
        match.1
    }
}

do {
    let input = "2022-08-29T12:34:56 - 三百七十二万レシピ https://cookpad.com/"

    let formatter = NumberFormatter()
    formatter.locale = Locale(identifier: "ja_JP")
    formatter.numberStyle = .spellOut

    let date = Reference(Date.self), quantity = Reference(Int?.self)
    let item = Reference(Substring.self), url = Reference(URL.self)

    let regex = Regex {
        Capture(.iso8601(timeZone: .gmt), as: date)

        /\s-\s/

        Capture(OneOrMore(.digit), as: quantity) { number -> Int? in
            formatter.number(from: String(number))?.intValue
        }

        Capture(OneOrMore(.word), as: item)
        One(.whitespace)
        Capture(.url(scheme: .required), as: url)
    }

    let match = input.firstMatch(of: regex)!
    type(of: match)
    match[date]
    match[quantity]
    match[item]
    match[url]
}
