import Algorithms
import AdventCommon
import Regex

/// https://adventofcode.com/2021/day/1
public struct Day1: AdventDay {

  public static let year = 2021
  public static let day = 1

  public static func solve(input: String) throws -> AdventAnswer {
    let measurements = Int.matches(in: input)
    return AdventAnswer(
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
