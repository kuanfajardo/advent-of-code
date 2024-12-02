//
//  115.swift
//
//
//  Created by Juan Fajardo on 12/2/24.
//

import AdventCommon
import RegexBuilder
import Collections

public struct Day15: AdventDay {
  
  public static let year = 2023
  public static let day = 15
  public static let answer = AdventAnswer(partOne: 514281, partTwo: 244199)
  
  static let temp = "rn=1,cm-,qp=3,cm=2,qp-,pc=4,ot=9,ab=5,pc-,pc=6,ot=7"
  
  public static func solve(input: String) throws -> AdventAnswer {
    let rawInstructions = input.trimmingCharacters(in: .newlines).components(separatedBy: ",")
    
    return .init(
      partOne: rawInstructions.map(HASH).reduce(0, +),
      partTwo: try self.part2(rawInstructions: rawInstructions)
    )
  }
  
  // MARK: Part 2
  
  struct Instruction {
    
    enum Operation {
      case remove
      case insert(focalLength: Int)
      
      init(rawOperation: Substring, rawFocalLength: Substring?) throws {
        switch rawOperation {
        case "-":
          self = .remove
        case "=":
          self = .insert(focalLength: Int(rawFocalLength!)!)
        default:
          throw AdventError.malformedInput(input: rawOperation)
        }
      }
    }
    
    let label: String
    let operation: Operation
    var box: Int { HASH(self.label) }
  }
  
  private static func part2(rawInstructions: [String]) throws -> Int {
    let regex = /(?<label>\w+)(?<operation>-|=)(?<focalLength>\d)?/

    let instructions = try rawInstructions.map {
      guard let match = $0.wholeMatch(of: regex) else { throw AdventError.malformedInput(input: $0) }
      return Instruction(
        label: String(match.label),
        operation: try .init(
          rawOperation: match.operation,
          rawFocalLength: match.focalLength
        )
      )
    }
    
    var map = [Int: OrderedDictionary<String, Int>](
      uniqueKeysWithValues: (0...255).map { (key: $0, value: [:]) }
    )

    for instruction in instructions {
      switch instruction.operation {
      case .remove:
        map[instruction.box]!.removeValue(forKey: instruction.label)
      case .insert(let focalLength):
        map[instruction.box]![instruction.label] = focalLength
      }
    }
    
    func focusingPower(of label: String) -> Int {
      let box = HASH(label)
      let index = map[box]!.index(forKey: label)!
      let focalLength = map[box]!.values[index]
      return (box + 1) * (index + 1) * focalLength
    }
    
    return map.values.flatMap(\.keys).map(focusingPower(of:)).reduce(0, +)
  }
}


func HASH(_ string: String) -> Int {
  string.map {
    Int($0.asciiValue!)
  }.reduce(into: 0) { currentValue, asciiValue in
    currentValue += asciiValue
    currentValue *= 17
    currentValue %= 256
  }
}
