import Algorithms
import AdventCommon
import Regex

/// https://adventofcode.com/2020/day/1
public struct Day1: AdventDay {

  public static let year = 2020
  public static let day = 1

  public static func solve(input: String) throws -> AdventAnswer {
    let numbers = Int.matches(in: input)
    return AdventAnswer(
      partOne: try findProductOfNumbersThatAddTo2020(in: numbers, count: 2),  // 877971
      partTwo: try findProductOfNumbersThatAddTo2020(in: numbers, count: 3)  // 203481432
    )
  }

  private static func findProductOfNumbersThatAddTo2020(in numbers: [Int], count: Int) throws -> Int {
    let pair = numbers.combinations(ofCount: count).first { array in
      array[0..<count].reduce(0, +) == 2020
    }

    guard let pair = pair else { throw AdventError.noSolutionFound }
    return pair.reduce(1, *)
  }
}
