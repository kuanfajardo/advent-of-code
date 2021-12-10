import AdventCommon
import Regex

/// https://adventofcode.com/2020/day/2
public struct Day2: AdventDay {

  public static let day = 2

  struct Entry: RegexRepresentable {
    let min: Int
    let max: Int
    let letter: String
    let password: String

    static let regex: Regex = #"(?xm)^(?<min>[0-9]+)-(?<max>[0-9]+)\s(?<letter>[a-z]):\s(?<password>[a-z]+)$"#

    init(match: Match) throws {
      self.min = try match.captureGroup(named: "min", as: Int.self)
      self.max = try match.captureGroup(named: "max", as: Int.self)
      self.letter = try match.captureGroup(named: "letter")
      self.password = try match.captureGroup(named: "password")
    }
  }

  // MARK: Logic

  public static func run(input: String) throws -> Any {
    let entries = try Entry.matches(in: input)
    return (
      partOne: numValidPasswordsByCount(in: entries),  // 600
      partTwo: numValidPasswordsByPosition(in: entries)  // 245
    )
  }

  // Part One
  static func numValidPasswordsByCount(in entries: [Entry]) -> Any {
    return entries
      .filter {
        let count = Regex(pattern: $0.letter).matches(in: $0.password).count
        return ($0.min...$0.max).contains(count)
      }
      .count
  }

  // Part Two
  static func numValidPasswordsByPosition(in entries: [Entry]) -> Any {
    return entries
      .filter {
        let char = Character($0.letter)
        let char1 = $0.password[$0.min - 1]
        let char2 = $0.password[$0.max - 1]
        // != between Bool is same as XOR
        return (char1 == char) != (char2 == char)
      }
      .count
  }
}


extension Regex: ExpressibleByStringInterpolation {
  public init<K: RegexKey>(stringInterpolation: MyStringInterpolation<K>) {
    self.init(pattern: stringInterpolation.pattern)
  }

  public struct MyStringInterpolation<K: RegexKey>: StringInterpolationProtocol {

    var pattern: String = ""

    public init(literalCapacity: Int, interpolationCount: Int) {
      pattern.reserveCapacity(literalCapacity * 2)
    }

    public mutating func appendLiteral(_ literal: String) {
      pattern.append(literal)
    }

    public mutating func appendInterpolation(_ value: K, _ pattern: String) {
      appendLiteral("(?<\(value.stringValue)>\(pattern))")
    }
  }
}

extension KeyedRegex: ExpressibleByStringLiteral, ExpressibleByStringInterpolation {
  public init(stringLiteral value: String) {
    self.init(pattern: value)
  }

  public init(stringInterpolation: MyStringInterpolation<K>) {
    self.init(pattern: stringInterpolation.pattern)
  }

  public struct MyStringInterpolation<K: RegexKey>: StringInterpolationProtocol {

    var pattern: String = ""

    public init(literalCapacity: Int, interpolationCount: Int) {
      pattern.reserveCapacity(literalCapacity * 2)
    }

    public mutating func appendLiteral(_ literal: String) {
      pattern.append(literal)
    }

    public mutating func appendInterpolation(_ value: K, _ pattern: String) {
      appendLiteral("(?<\(value.stringValue)>\(pattern))")
    }
  }
}
