//
//  AdventDay.swift
//  
//
//  Created by Juan Fajardo on 12/3/24.
//

import AdventCommon

public struct Day3: AdventDay {
  
  public static let year = 2024
  public static let day = 3
  public static let answer = AdventAnswer(partOne: 170778545, partTwo: 82868252)
  
  static let temp1 =
    "xmul(2,4)%&mul[3,7]!@^do_not_mul(5,5)+mul(32,64]then(mul(11,8)mul(8,5))"
  
  static let temp2 =
    "xmul(2,4)&mul[3,7]!^don't()_mul(5,5)+mul(32,64](mul(11,8)undo()?mul(8,5))"
  
  public static func solve(input: String) throws -> AdventAnswer {
    return .init(
      partOne: self.part1(input: input),
      partTwo: self.part2(input: input)
    )
  }
  
  private static func part1(input: String) -> Int {
    input.matches(of: /mul\((?<lhs>\d+),(?<rhs>\d+)\)/)
      .map { Int($0.lhs)! * Int($0.rhs)! }
      .reduce(0, +)
  }

  enum Instruction {
    case multiply(lhs: Int, rhs: Int)
    case enable
    case disable
  }
  
  private static func part2(input: String) -> Int {
    let instructions: [Instruction] = input.matches(
      of: /(mul\((?<lhs>\d+),(?<rhs>\d+)\))|(?<enable>do\(\))|(?<disable>don't\(\))/
    )
    .map {
      if let lhs = $0.lhs, let rhs = $0.rhs {
        return .multiply(lhs: Int(lhs)!, rhs: Int(rhs)!)
      } else if $0.enable != nil {
        return .enable
      } else if $0.disable != nil {
        return .disable
      } else {
        fatalError()
      }
    }
    
    return instructions.reduce(into: (sum: 0, isEnabled: true)) { result, instruction in
      switch instruction {
      case .enable:
        result.isEnabled = true
      case .disable:
        result.isEnabled = false
      case .multiply(let lhs, let rhs):
        guard result.isEnabled else { return }
        result.sum += lhs * rhs
      }
    }.sum
  }
}
