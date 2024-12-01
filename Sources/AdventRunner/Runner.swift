import AdventCommon
import Advent2020
import Advent2021
import Advent2022
import Advent2023
import Advent2024
import ArgumentParser
import Foundation

let inputDirectory = URL(fileURLWithPath: "/Users/juanfajardo/Desktop/Advent/Resources/Advent")
let inputDirectory_icloud = URL(fileURLWithPath: "//Users/juanfajardo/Library/Mobile Documents/com~apple~CloudDocs/Desktop/Advent/Resources/Advent")

// Update this to run a different advent day!
let adventDay = Advent2021.Day13.self

@main
struct Runner: ParsableCommand {

  func run() throws {
    let inputFile = inputDirectory_icloud
      .appendingPathComponent("\(adventDay.year)", isDirectory: true)
      .appendingPathComponent("input_\(adventDay.day).txt", isDirectory: false)

    let input = try String(contentsOf: inputFile).trimmingCharacters(in: .whitespacesAndNewlines)
    let result = try adventDay.solve(input: input)

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
