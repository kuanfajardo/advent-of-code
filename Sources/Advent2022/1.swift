import AdventCommon
import Algorithms

/// https://adventofcode.com/2022/day/1
public struct Day1: AdventDay {

  public static let year = 2022
  public static let day = 1
  
  public static let answer = AdventAnswer(partOne: 69206, partTwo: 197400)

  public static func solve(input: String) throws -> AdventAnswer {
    let rawInventory = input.components(separatedBy: .newlines).map(Int.init)
    let inventories = rawInventory.split(separator: nil)
    
    let inventorySums = inventories.map { inventory in
      inventory.compactMap { $0 }.reduce(0, +)
    }
    
    return AdventAnswer(
      partOne: inventorySums.max()!,
      partTwo: inventorySums.max(count: 3).reduce(0, +)
    )
  }
}
