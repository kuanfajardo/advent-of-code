//
//  File.swift
//  
//
//  Created by Juan Fajardo on 12/10/23.
//

import AdventCommon

fileprivate typealias Regex = _StringProcessing.Regex

/// https://adventofcode.com/2023/day/1
public struct Day1: AdventDay {
  
  public static let day = 1
  
  public static let year = 2023
  
  public static func solve(input: String) throws -> AdventCommon.AdventAnswer {
    let lines = input.components(separatedBy: .newlines).filter { !$0.isEmpty }
    return .init(
      partOne: try self.partOne(lines: lines),  // 54159
      partTwo: try self.partTwo(lines: lines)  // 53866
    )
  }
  
  public static func partOne(lines: [String]) throws -> Int {
    let regex: _StringProcessing.Regex = try Regex(#"\d"#, as: (Substring.self))
    return try lines.map {
      guard
        let firstDigit = try regex.firstMatch(in: $0)?.output,
        let lastDigit = try regex.firstMatch(in: String($0.reversed()))?.output
      else {
        throw AdventError.malformedInput(input: $0)
      }
      return Int(firstDigit + lastDigit)!
    }.reduce(0, +)
  }
  
  public static func partTwo(lines: [String]) throws -> Int {
    let forwardRegexComponents = [#"\d"#] + NonZeroDigit.allCases.map(\.stringValue)
    let forwardRegex = try Regex(
      forwardRegexComponents.joined(separator: "|"),
      as: (Substring.self)
    )

    let backwardsRegexComponents = [#"\d"#] + NonZeroDigit.allCases.map(\.stringValue).map {
      String($0.reversed())
    }
    let backwardsRegex = try Regex(
      backwardsRegexComponents.joined(separator: "|"),
      as: (Substring.self)
    )
             
    return try lines.map {
      guard
        let rawFirstDigit = try forwardRegex.firstMatch(in: $0)?.output,
        let rawLastDigit = try backwardsRegex.firstMatch(in: String($0.reversed()))?.output
      else {
        throw AdventError.malformedInput(input: $0)
      }
      
      let firstDigit = try Int(rawFirstDigit) ?? self.integer(from: rawFirstDigit)
      let lastDigit = try Int(rawLastDigit) ?? self.integer(from: String(rawLastDigit.reversed()))
      
      return firstDigit * 10 + lastDigit
    }.reduce(0, +)
  }
  
  static func integer<S: StringProtocol>(from string: S) throws -> Int {
    guard let integer = NonZeroDigit(stringValue: string)?.rawValue else {
      throw AdventError.malformedInput(input: string)
    }
    return integer
  }
  
  enum NonZeroDigit: Int, CaseIterable {
    case one = 1, two, three, four, five, six, seven, eight, nine
    
    init?<S: StringProtocol>(stringValue: S) {
      switch stringValue {
      case "one": self = .one
      case "two": self = .two
      case "three": self = .three
      case "four": self = .four
      case "five": self = .five
      case "six": self = .six
      case "seven": self = .seven
      case "eight": self = .eight
      case "nine": self = .nine
      default: return nil
      }
    }
    
    var stringValue: String {
      switch self {
      case .one: return "one"
      case .two: return "two"
      case .three: return "three"
      case .four: return "four"
      case .five: return "five"
      case .six: return "six"
      case .seven: return "seven"
      case .eight: return "eight"
      case .nine: return "nine"
      }
    }
  }
}

