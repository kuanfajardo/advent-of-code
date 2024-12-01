import AdventCommon
import Algorithms
import Regex

/// https://adventofcode.com/2022/day/6
public struct Day6: AdventDay {

  public static let year = 2022
  public static let day = 6

  public static let answer = AdventAnswer(
    partOne: NonCheckableAnswer(1896),
    partTwo: NonCheckableAnswer(3452)
  )

  public static func solve(input: String) throws -> AdventAnswer {
    let characters = Array(input)

    return AdventAnswer(
      partOne: NonCheckableAnswer(
        characters.windows(ofCount: 4).firstIndex { Set($0).count == 4 }!
      ),
      partTwo: NonCheckableAnswer(
        characters.windows(ofCount: 14).firstIndex { Set($0).count == 14 }!
      )
    )
  }
}
