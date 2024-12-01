import AdventCommon
import Regex

/// https://adventofcode.com/2020/day/2
public struct Day2: AdventDay {

  public static let year = 2020
  public static let day = 2
  public static let answer = AdventAnswer(partOne: 600, partTwo: 245)

  struct Entry: RegexRepresentable {
    let min: Int
    let max: Int
    let letter: String
    let password: String

    static let regex: Regex = #"(?xm)^(?<min>[0-9]+)-(?<max>[0-9]+)\s(?<letter>[a-z]):\s(?<password>[a-z]+)$"#

    init(match: Match) {
      self.min = match["min", as: Int.self]!
      self.max = match["max", as: Int.self]!
      self.letter = match["letter"]!
      self.password = match["password"]!
    }
  }

  // MARK: Logic

  public static func solve(input: String) throws -> AdventAnswer {
    let entries = Entry.matches(in: input)
    return AdventAnswer(
      partOne: numValidPasswordsByCount(in: entries),
      partTwo: numValidPasswordsByPosition(in: entries)
    )
  }

  // Part One
  static func numValidPasswordsByCount(in entries: [Entry]) -> Int {
    return entries
      .filter {
        let count = $0.letter.matches(in: $0.password).count
        return ($0.min...$0.max).contains(count)
      }
      .count
  }

  // Part Two
  static func numValidPasswordsByPosition(in entries: [Entry]) -> Int {
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
