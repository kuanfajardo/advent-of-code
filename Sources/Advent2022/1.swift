import AdventCommon
import Algorithms

/// https://adventofcode.com/2022/day/1
public struct Day1: AdventDay {

  public static let day = 1

  public static func run(input: String) throws -> Any {
    let rawInventory = input.components(separatedBy: .newlines).map(Int.init)
    let inventories = rawInventory.split(separator: nil)
    
    let inventorySums = inventories.map { inventory in
      inventory.compactMap { $0 }.reduce(0, +)
    }
    
    return (
      partOne: inventorySums.max()!,
      partTwo: inventorySums.max(count: 3).reduce(0, +)
    )
  }
}
