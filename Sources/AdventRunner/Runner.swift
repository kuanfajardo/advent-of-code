import AdventCommon
import Advent2020
import Advent2021
import Advent2022
import Advent2023
import Advent2024
import ArgumentParser
import Foundation

// Update this to run a different advent day!
let adventDay = Advent2024.Day6.self

@main
struct Runner: ParsableCommand {

  func run() throws {
    let result = try adventDay.run()
    print(
      """
      PART 1: \(self.textForResult(expected: adventDay.answer.partOne, actual: result.partOne))
      PART 2: \(self.textForResult(expected: adventDay.answer.partTwo, actual: result.partTwo))
      """
    )
  }
  
  private func textForResult(expected: AnyEquatable, actual: AnyEquatable) -> String {
    if expected == actual {
      return "✅ \(actual)"
    } else {
      return "❌ \(actual) (expected \(expected))"
    }
  }
}
