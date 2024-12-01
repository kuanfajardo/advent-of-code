//
//  9.swift
//
//
//  Created by Juan Fajardo on 12/18/23.
//

import AdventCommon

public struct Day9: AdventDay {
  
  public static var year: Int { 2023 }
  
  public static var day: Int { 9 }
  
  public static let answer = AdventAnswer(partOne: 1_877_825_184, partTwo: 1_108)
  
  public static func solve(input: String) throws -> AdventAnswer {
    let sequences = input.components(separatedBy: .newlines).map {
      $0.components(separatedBy: .whitespaces).map { Int($0)! }
    }

    let previousAndNext = sequences.map { self.extrapolate(sequence: $0) }
    return AdventAnswer(
      partOne: previousAndNext.map(\.next).reduce(0, +),
      partTwo: previousAndNext.map(\.previous).reduce(0, +)
    )
  }
  
  static func extrapolate(sequence: [Int]) -> (previous: Int, next: Int) {
    if sequence == [Int](repeating: 0, count: sequence.count) {
      return (previous: 0, next: 0)
    } else {
      let differences = sequence.adjacentPairs().map { $0.1 - $0.0 }
      let previousAndNext = extrapolate(sequence: differences)
      return (
        previous: sequence.first! - previousAndNext.previous,
        next: sequence.last! + previousAndNext.next
      )
    }
  }
}
