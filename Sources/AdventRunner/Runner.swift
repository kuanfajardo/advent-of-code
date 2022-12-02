import AdventCommon
import Advent2020
import Advent2021
import Advent2022
import ArgumentParser
import Foundation

let inputDirectory = URL(fileURLWithPath: "/Users/juanfajardo/Desktop/Advent/Resources/Advent")

// Update this to run a different advent day!
let adventDay = Advent2022.Day2.self

@main
struct Runner: ParsableCommand {

  func run() throws {
    let inputFile = inputDirectory
      .appendingPathComponent("\(adventDay.year)", isDirectory: true)
      .appendingPathComponent("input_\(adventDay.day).txt", isDirectory: false)

    let input = try String(contentsOf: inputFile)
    let result = try adventDay.solve(input: input)

    print(result)
  }
}
