import AdventCommon
import Algorithms
import Regex

/// https://adventofcode.com/2022/day/6
public struct Day6: AdventDay {

  public static let year = 2022
  public static let day = 6

  public static func solve(input: String) throws -> AdventAnswer {
    let characters = Array(input)

    return AdventAnswer(
      partOne: characters.windows(ofCount: 4).firstIndex { Set($0).count == 4 }!,  // 1896
      partTwo: characters.windows(ofCount: 14).firstIndex { Set($0).count == 14 }!  // 3452
    )
  }
}
