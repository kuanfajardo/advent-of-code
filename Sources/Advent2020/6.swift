import AdventCommon
import Regex

/// https://adventofcode.com/2020/day/6
public struct Day6: AdventDay {
  
  public static let day = 6
  
  struct GroupFormResponse: RegexRepresentable {
    static let regex: Regex = #"(?<body>[a-z\n]*?)\n\n"#
    
    let forms: [[Character]]
    
    init(match: Match) throws {
      let body = try match.captureGroup(named: "body")
      
      let formRegex: Regex = #"(?m)^(?<form>[a-z]+)$"#
      self.forms = try formRegex.matches(in: body)
        .map { try $0.captureGroup(named: "form") }
        .map { Array($0) }
    }
  }
  
  public static func run(input: String) throws -> Any {
    let groupFormResponses = try GroupFormResponse.matches(in: input)
    
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
    
    return (
      partOne: allUniqueYesesCount,  // 6585
      partTwo: allInclusiveYesesCount  // 3276
    )
  }
}
