import AdventCommon
import Advent2020
import Advent2021
import ArgumentParser
import Foundation

let adventDay = Advent2021.Day9.self

@main
struct Runner: ParsableCommand {

  enum Error: Swift.Error {
    case inputFileNotFound(String)
  }

  @Argument(help: "The path to the input directory.", transform: URL.init(fileURLWithPath:))
  var inputDirectory: URL?

  func run() throws {
    let inputFilename = "input_\(adventDay.day).txt"
    guard let inputFile = inputDirectory?.appendingPathComponent(inputFilename, isDirectory: false)
    else {
      throw Error.inputFileNotFound("\(String(describing: inputDirectory?.path))/\(inputFilename)")
    }

    let input = try String(contentsOf: inputFile)
    let result = try adventDay.run(input: input)

    print(result)
  }
}
