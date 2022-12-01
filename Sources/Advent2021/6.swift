import AdventCommon
import LASwift
import Regex

public struct Day6: AdventDay {

  public static let year = 2021
  public static let day = 6

  public static func solve(input: String) throws -> AdventAnswer {
    let fishAges = Int.matches(in: input)
    return AdventAnswer(
      partOne: numberOfLanternfish(afterDays: 80, startingFishAges: fishAges), // 374927
      partTwo: numberOfLanternfish(afterDays: 256, startingFishAges: fishAges)  // 1687617803407
    )
  }

  private static func numberOfLanternfish(afterDays days: Int, startingFishAges ages: [Int]) -> Int {
    let transform = Matrix([
      [0, 1, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 1, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 1, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 1, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 1, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 1, 0, 0],
      [1, 0, 0, 0, 0, 0, 0, 1, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 1],
      [1, 0, 0, 0, 0, 0, 0, 0, 0],
    ])

    let bag = Bag(ages)
    let startingCountsArray = (0...8).map { bag[$0] }
    let startDistribution = Matrix(startingCountsArray)

    let finalDistribution = (transform ^ days) * startDistribution
    return Int(finalDistribution.flat.reduce(0, +))
  }
}
