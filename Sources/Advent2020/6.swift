import AdventCommon
import Regex

/// https://adventofcode.com/2020/day/6
public struct Day6: AdventDay {
  
  public static let year = 2020
  public static let day = 6
  public static let answer = AdventAnswer(partOne: 6585, partTwo: 3276)
  
  struct GroupFormResponse: RegexRepresentable {
    static let regex: Regex = #"(?<body>[a-z\n]*?)\n\n"#
    
    let forms: [[Character]]
    
    init(match: Match) {
      let body = match["body"]!
      
      let formRegex: Regex = #"(?m)^(?<form>[a-z]+)$"#
      self.forms = formRegex.matches(in: body)
        .compactMap { $0["form"] }
        .map { Array($0) }
    }
  }
  
  public static func solve(input: String) throws -> AdventAnswer {
    let groupFormResponses = GroupFormResponse.matches(in: input)
    
    // Part One
    let allUniqueYesesCount = groupFormResponses
      .map { response in
        response.forms
          .flatMap { $0 }
          .reduce(into: Set<Character>()) { $0.insert($1) }
      }
      .map(\.count)
      .reduce(0, +)
    
    // Part Two
    let allInclusiveYesesCount = groupFormResponses
      .map { response in
        "abcdefghijklmnopqrstuvwxyz".filter { letter in
          response.forms.allSatisfy { $0.contains(letter) }
        }
      }
      .map(\.count)
      .reduce(0, +)
    
    return AdventAnswer(
      partOne: allUniqueYesesCount,
      partTwo: allInclusiveYesesCount
    )
  }
}
