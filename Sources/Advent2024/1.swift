//
//  1.swift
//
//
//  Created by Juan Fajardo on 11/30/24.
//

import AdventCommon
import RegexBuilder

public struct Day1: AdventDay {
  
  public static let year = 2024
  
  public static let day = 1

  public static func solve(input: String) throws -> AdventAnswer {
    let entry1Ref = Reference(Int.self)
    let entry2Ref = Reference(Int.self)
    let regex = Regex {
      TryCaptureInt(as: entry1Ref)
      OneOrMore(.whitespace)
      TryCaptureInt(as: entry2Ref)
    }
    
    let (list1, list2): ([Int], [Int]) = try input.components(separatedBy: .newlines)
      .map {
        guard let match = try regex.wholeMatch(in: $0) else { throw AdventError.malformedInput(input: $0) }
        return (match[entry1Ref], match[entry2Ref])
      }
      .reduce(into: ([], [])) { lists, entries in
        lists.0.append(entries.0)
        lists.1.append(entries.1)
      }
    
    // Part 2.
    let numbersInList1 = Set(list1)
    let list2Bag = Bag(list2)

    return .init(
      partOne: zip(list1.sorted(), list2.sorted()).map { abs($0.0 - $0.1) }.reduce(0, +),
      partTwo: numbersInList1.map { $0 * list2Bag[$0] }.reduce(0, +)
    )
  }
  
  public static let answer = AdventAnswer(partOne: 2_430_334, partTwo: 28_786_472)
}
