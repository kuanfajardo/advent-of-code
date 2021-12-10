import Algorithms
import AdventCommon
import Regex

/// https://adventofcode.com/2021/day/1
public struct Day1: AdventDay {

  public static let day = 1

  public static func run(input: String) throws -> Any {
    let measurements = try Int.matches(in: input)
    return (
      partOne: measurements
        .adjacentPairs()
        .filter { $0.1 > $0.0 }
        .count,  // 1655

      partTwo: measurements
        .windows(ofCount: 3)
        .map { $0.reduce(0, +) }
        .adjacentPairs()
        .filter { $0.1 > $0.0 }
        .count  // 1683
    )
  }
}
