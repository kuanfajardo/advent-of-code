import AdventCommon
import Algorithms
import Regex
import Foundation

/// https://adventofcode.com/2022/day/5
public struct Day5: AdventDay {

  public static let year = 2022
  public static let day = 5
  
  public static let answer = AdventAnswer.unsolved // (partOne: "QMBMJDFTD", partTwo: "NBTVTJNFJ")

  public static func solve(input: String) throws -> AdventAnswer {
    let lines = input.components(separatedBy: .newlines)
    let splitLines = lines.split(separator: "")
    let crateLines = Array(splitLines[0])
    let instructionLines = Array(splitLines[1])
    
    let stacks = self.makeStacks(from: crateLines)
    let instructions = self.makeInstructions(from: instructionLines)
        
    let part1Stacks = self.performInstructions(instructions, on: stacks) { instruction, stacks in
      for _ in (0..<instruction.numberToMove) {
        let crateToMove = stacks[instruction.source - 1].removeLast()
        stacks[instruction.destination - 1].append(crateToMove)
      }
    }
    
    let part2Stacks = self.performInstructions(instructions, on: stacks) { instruction, stacks in
      let stacksToMove = (0..<instruction.numberToMove).map { _ in stacks[instruction.source - 1].removeLast() }
      stacks[instruction.destination - 1].append(contentsOf: stacksToMove.reversed())
    }
        
    return AdventAnswer(
      partOne: topCratesString(from: part1Stacks),
      partTwo: topCratesString(from: part2Stacks)
    )
  }
  
  // MARK: Entities
  
  struct Crate: RegexRepresentable, CustomStringConvertible {

    static let regex: Regex = #"\[(?<letter>\w)\]"#
    
    let letter: Character
    
    init?(match: Match) {
      guard let letter = try? match.captureGroup(named: "letter", as: Character.self) else { return nil }
      self.letter = letter
    }
    
    var description: String { String(self.letter) }
  }

  struct Instruction: RegexRepresentable, CustomStringConvertible {
    
    static let regex: Regex = #"move (?<numberToMove>\d+) from (?<source>\d) to (?<destination>\d)"#
    
    let numberToMove: Int
    let source: Int
    let destination: Int
    
    init?(match: Match) {
      self.numberToMove = try! match.captureGroup(named: "numberToMove", as: Int.self)
      self.source = try! match.captureGroup(named: "source", as: Int.self)
      self.destination = try! match.captureGroup(named: "destination", as: Int.self)
    }
    
    var description: String {
      "move \(self.numberToMove) from \(self.source) to \(self.destination)"
    }
  }

  // MARK: Logic
  
  static func makeStacks(from stackLines: [String]) -> [[Crate]] {
    var crateLines = stackLines
    let stackNumbersLine = crateLines.removeLast()
    let numberOfStacks = Int(String(stackNumbersLine.last!))!
    
    let stackLineRegexString = [String](repeating: #"([\s\w\[\]]{3})"#, count: numberOfStacks).joined(by: " ")
    let stackLineRegex = NSRegularExpression(String(stackLineRegexString))
    
    let minLineLength = numberOfStacks * 3 + (numberOfStacks - 1)
    let grid = crateLines
      .map { $0.padding(toLength: minLineLength, withPad: " ", startingAt: 0) }
      .compactMap { stackLineRegex.firstMatch(in: $0) }
      .map { match in
        match.allCaptureGroups().map {
          Crate.firstMatch(in: $0)
        }
      }

    var stacks = [[Crate]](repeating: [], count: numberOfStacks)
    for i in (0..<grid.count).reversed() {
      for j in (0..<grid[i].count).reversed() {
        guard let crate = grid[i][j] else { continue }
        stacks[j] = stacks[j] + [crate]
      }
    }

    return stacks
  }
  
  static func makeInstructions(from lines: [String]) -> [Instruction] {
    lines.compactMap { Instruction.firstMatch(in: $0) }
  }
  
  static func performInstructions(
    _ instructions: [Instruction],
    on _stacks: [[Crate]],
    move: (Instruction, inout [[Crate]]) -> Void
  ) -> [[Crate]] {
    var stacks = _stacks
    for instruction in instructions {
      move(instruction, &stacks)
    }
    return stacks
  }
  
  static func topCratesString(from stacks: [[Crate]]) -> String {
    stacks.compactMap(\.last).map(String.init(describing:)).reduce("", +)
  }
  
  // MARK: Debugging
  
  func printStacks(_ stacks: [[Crate]]) {
    let str = stacks
      .enumerated()
      .map { "\($0.offset + 1) " + String($0.element.map(String.init(describing:)).joined(by: " ")) }
      .joined(by: "\n")

    print(String(str))
  }
}
