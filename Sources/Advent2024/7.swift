//
//  7.swift
//  Advent
//
//  Created by Juan Fajardo on 12/20/24.
//

import AdventCommon

public struct Day7: AdventDay {
  
  public static let year = 2024
  public static let day = 7
  public static let answer = AdventAnswer(partOne: 2941973819040, partTwo: 249943041417600)
  
  static let temp =
    """
    190: 10 19
    3267: 81 40 27
    83: 17 5
    156: 15 6
    7290: 6 8 6 15
    161011: 16 10 13
    192: 17 8 14
    21037: 9 7 18 13
    292: 11 6 16 20
    """
  
  struct Equation: CustomDebugStringConvertible {
    let testValue: Int
    let operands: [Int]
    
    init(testValue: Int, operands: [Int]) {
      self.testValue = testValue
      self.operands = operands
    }
    
    var debugDescription: String {
      "\(self.testValue): \(self.operands)"
    }
  }
  
  public static func solve(input: String) throws -> AdventAnswer {
    let regex = /(?<testValue>\d+): (?<operands>.*)/
    let equations = try input.components(separatedBy: .newlines)
      .map {
        guard let match = try regex.wholeMatch(in: $0) else {
          throw AdventError.malformedInput(input: $0)
        }
        return match
      }
      .map {
        Equation(
          testValue: try Int.fromMatchGroup($0.testValue),
          operands: try $0.operands.components(separatedBy: " ").map(Int.fromMatchGroup)
        )
      }
    
    return .init(
      partOne: self.sumOfEquationsThatCanBeSolved(equations, using: [Add.self, Multiply.self]),
      partTwo: self.sumOfEquationsThatCanBeSolved(
        equations, using: [Add.self, Multiply.self, Join.self]
      )
    )
  }
  
  private static func sumOfEquationsThatCanBeSolved(
    _ equations: [Equation],
    using operators: [Operator.Type]
  ) -> Int {
    equations
      .filter { self.canEquationBeSolved($0, using: operators) }
      .map(\.testValue)
      .reduce(0, +)
  }
  
  private static func canEquationBeSolved(
    _ equation: Equation, using operators: [Operator.Type]
  ) -> Bool {
    // Base case.
    if equation.operands.count == 2 {
      return operators.contains { op in
        op.verifyEquation(
          lhs: equation.operands[0],
          rhs: equation.operands[1],
          result: equation.testValue
        )
      }
    }
    
    // Recursive case.
    var newOperands = equation.operands
    let removedOperand = newOperands.popLast()!
    return operators.compactMap {
      $0.undo(result: equation.testValue, operand: removedOperand)
    }.map {
      Equation(testValue: $0, operands: newOperands)
    }.contains {
      self.canEquationBeSolved($0, using: operators)
    }
  }
}

// MARK: Operators

protocol Operator {
  static func verifyEquation(lhs: Int, rhs: Int, result: Int) -> Bool
  static func undo(result: Int, operand: Int) -> Int?
}

struct Add: Operator {

  static func verifyEquation(lhs: Int, rhs: Int, result: Int) -> Bool {
    lhs + rhs == result
  }
  
  static func undo(result: Int, operand: Int) -> Int? {
    result - operand
  }
}

struct Multiply: Operator {

  static func verifyEquation(lhs: Int, rhs: Int, result: Int) -> Bool {
    lhs * rhs == result
  }
  
  static func undo(result: Int, operand: Int) -> Int? {
    guard result % operand == 0 else { return nil }
    return result / operand
  }
}

struct Join: Operator {

  static func verifyEquation(lhs: Int, rhs: Int, result: Int) -> Bool {
    String(lhs) + String(rhs) == String(result)
  }
  
  static func undo(result: Int, operand: Int) -> Int? {
    let resultString = String(result)
    let operandString = String(operand)
    guard resultString.hasSuffix(operandString) else { return nil }
    let undoResultStringLength = resultString.count - operandString.count
    let undoResultString = String(Array(resultString)[0..<undoResultStringLength])
    return Int(undoResultString)
  }
}
