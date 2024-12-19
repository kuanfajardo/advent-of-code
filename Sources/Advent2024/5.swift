//
//  5.swift
//  Advent
//
//  Created by Juan Fajardo on 12/17/24.
//

import AdventCommon
import Algorithms

public struct Day5: AdventDay {
    
  public static let year: Int = 2024
  public static let day: Int = 5
  public static let answer = AdventAnswer(partOne: 5747, partTwo: 5502)
  
  static let temp =
    """
    47|53
    97|13
    97|61
    97|47
    75|29
    61|13
    75|53
    29|13
    97|29
    53|29
    61|53
    97|53
    61|29
    47|13
    75|47
    97|75
    47|61
    75|61
    47|29
    75|13
    53|13

    75,47,61,53,29
    97,61,53,29,13
    75,29,13
    75,97,47,61,53
    61,13,29
    97,13,75,29,47
    """
  
  struct PageOrderingRule {
    let lhs: Int
    let rhs: Int
    
    init(rawLHS: Substring, rawRHS: Substring) throws {
      guard let lhs = Int(String(rawLHS)), let rhs = Int(String(rawRHS)) else {
        throw AdventError.malformedInput(input: rawLHS)
      }
      self.lhs = lhs
      self.rhs = rhs
    }
  }
  
  public static func solve(input: String) throws -> AdventAnswer {
    let pageOrderingRegex = /(?<lhs>\d+)\|(?<rhs>\d+)/
    let lines = input.components(separatedBy: .newlines)
    let pageOrderingRules: [PageOrderingRule] = try lines
      .compactMap { $0.wholeMatch(of: pageOrderingRegex) }
      .map { try PageOrderingRule(rawLHS: $0.lhs, rawRHS: $0.rhs) }
    let updates = lines
      .filter { $0.wholeMatch(of: pageOrderingRegex) == nil }
      .map { $0.components(separatedBy: ",").compactMap(Int.init) }
      .filter { !$0.isEmpty }

    return .init(
      partOne: updates
        .filter { self.isUpdateOrdered($0, following: pageOrderingRules) }
        .map { self.middlePageNumber(of: $0) }
        .reduce(0, +)
      ,
      partTwo: updates
        .filter { !self.isUpdateOrdered($0, following: pageOrderingRules) }
        .map { self.fixUpdate($0, following: pageOrderingRules) }
        .map { self.middlePageNumber(of: $0) }
        .reduce(0, +)
    )
  }
  
  static func isUpdateOrdered(_ update: [Int], following rules: [PageOrderingRule]) -> Bool {
    let elements = Set(update)
    let positions: [Int: Int] = update.enumerated().reduce(into: [:]) { $0[$1.element] = $1.offset }
    return rules
      .filter { elements.contains($0.lhs) && elements.contains($0.rhs) }
      .allSatisfy {
        positions[$0.lhs]! < positions[$0.rhs]!
      }
  }
  
  static func middlePageNumber(of update: [Int]) -> Int {
    return update[update.count / 2]
  }
  
  static func fixUpdate(_ update: [Int], following rules: [PageOrderingRule]) -> [Int] {
    let pages = Set(update)
    let relevantRules = rules.filter { pages.contains($0.lhs) && pages.contains($0.rhs) }
    var pagesByNumberOfOtherPagesLessThan = [Int: Int](uniqueKeysWithValues: pages.map { ($0, 0) })
    for rule in relevantRules {
      pagesByNumberOfOtherPagesLessThan[rule.rhs]! += 1
    }
    return pagesByNumberOfOtherPagesLessThan.sorted { $0.value < $1.value }.map(\.key)
  }
}
