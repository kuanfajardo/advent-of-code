import AdventCommon
import Algorithms
import Regex

/// https://adventofcode.com/2020/day/8
public struct Day8: AdventDay {

  public static let day = 8

  enum Instruction: RegexRepresentable {
    static var regex: Regex = #"(?<instruction>(acc|jmp|nop)) (?<sign>\+|\-)(?<value>[0-9]+)"#

    case acc(Int)
    case jmp(Int)
    case nop(Int)

    init(match: Match) throws {
      let sign = try match.captureGroup(named: "sign")
      let multiplier = sign == "-" ? -1 : 1
      let value = try match.captureGroup(named: "value", as: Int.self) * multiplier

      switch try match.captureGroup(named: "instruction") {
      case "acc": self = .acc(value)
      case "jmp": self = .jmp(value)
      case "nop": self = .nop(value)
      default: throw AdventError.malformedInput
      }
    }
  }

  public static func run(input: String) throws -> Any {
    let instructions = try Instruction.matches(in: input)
    return (
      partOne: executeProgram(instructions: instructions).accumulator,  // 1801
      partTwo: accumulatorValueAfterCorrectTermination(instructions: instructions)  // 2060
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
