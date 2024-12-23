import AdventCommon
import Algorithms
import Regex

/// https://adventofcode.com/2020/day/9
public struct Day9: AdventDay {

  public static let year = 2020
  public static let day = 9
  public static let answer = AdventAnswer(partOne: 3199139634, partTwo: 438559930)

  public static func solve(input: String) throws -> AdventAnswer {
    let numbers = Int.matches(in: input)

    let firstInvalidNumber = firstInvalidNumber(in: numbers)
    let contiguousSummands = try firstContiguousListOfNumbers(in: numbers, thatAddTo: firstInvalidNumber)

    return AdventAnswer(
      partOne: firstInvalidNumber,
      partTwo: contiguousSummands.minAndMax().map { $0.min + $0.max }!
    )
  }

  private static func firstInvalidNumber(in data: [Int]) -> Int {
    return data
      .windows(ofCount: 26)
      .firstNonNil { window in
        let preamble = window.prefix(25)
        let number = window.last!

        let isValid = preamble
          .combinations(ofCount: 2)
          .lazy
          .map { $0[0] + $0[1] }
          .first { $0 == number }
        != nil

        return isValid ? nil : number
      }!
  }

  private static func firstContiguousListOfNumbers(in data: [Int], thatAddTo target: Int) throws -> [Int] {
    var startIndex = 0

    while startIndex < data.count {
      var sum = 0
      var movingIndex = startIndex
      while sum < target && movingIndex < data.count {
        sum += data[movingIndex]
        if sum == target {
          return Array(data[startIndex...movingIndex])
        }
        movingIndex += 1
      }
      startIndex += 1
    }

    throw AdventError.noSolutionFound
  }
}
