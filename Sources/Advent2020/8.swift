import AdventCommon
import Algorithms
import Regex

/// https://adventofcode.com/2020/day/8
public struct Day8: AdventDay {

  public static let year = 2020
  public static let day = 8
  public static let answer = AdventAnswer(partOne: 1801, partTwo: 2060)

  enum Instruction: RegexRepresentable {
    static var regex: Regex = #"(?<instruction>(acc|jmp|nop)) (?<sign>\+|\-)(?<value>[0-9]+)"#

    case acc(Int)
    case jmp(Int)
    case nop(Int)

    init?(match: Match) {
      let sign = match["sign"]!
      let multiplier = sign == "-" ? -1 : 1
      let value = match["value", as: Int.self]! * multiplier

      switch match["instruction"]! {
      case "acc": self = .acc(value)
      case "jmp": self = .jmp(value)
      case "nop": self = .nop(value)
      default: return nil
      }
    }
  }

  public static func solve(input: String) throws -> AdventAnswer {
    let instructions = Instruction.matches(in: input)
    return AdventAnswer(
      partOne: executeProgram(instructions: instructions).accumulator,
      partTwo: accumulatorValueAfterCorrectTermination(instructions: instructions)
    )
  }

  private static func executeProgram(instructions: [Instruction]) -> (success: Bool, accumulator: Int) {
    var visitedIndices = Set<Int>()
    var accumulator = 0
    var index = 0

    repeat {
      visitedIndices.insert(index)

      let instruction = instructions[index]
      switch instruction {
      case .acc(let value):
        accumulator += value
        index += 1
      case .jmp(let value):
        index += value
      case .nop:
        index += 1
      }
    } while !visitedIndices.contains(index) && index < instructions.count

    let success = index == instructions.count
    return (success, accumulator)
  }

  private static func accumulatorValueAfterCorrectTermination(instructions: [Instruction]) -> Int {
    return instructions.enumerated().firstNonNil { elt in
      switch elt.element {
        // `acc` can't change
      case .acc: return nil

        // For both `jmp` and `nop`, attempt to replace instruction and execute program successfully!
      case .jmp(let value):
        var newInstructions = instructions
        newInstructions[elt.offset] = .nop(value)
        let result = executeProgram(instructions: newInstructions)
        return result.success ? result.accumulator : nil

      case .nop(let value):
        var newInstructions = instructions
        newInstructions[elt.offset] = .jmp(value)
        let result = executeProgram(instructions: newInstructions)
        return result.success ? result.accumulator : nil
      }
    }!
  }
}
