import AdventCommon
import Algorithms
import Foundation
import Regex

/// https://adventofcode.com/2022/day/14
public struct Day14: AdventDay {

  public static let year = 2022
  public static let day = 14

  public static func solve(input: String) throws -> AdventAnswer {
    let coordinateRegex: Regex = #"(\d+,\d+)"#
    let lines = input.components(separatedBy: .newlines).filter { !$0.isEmpty }
      .compactMap { coordinateRegex.firstMatch(in: $0) }
      .map {
        $0.allCaptureGroups().map { group in
          let components = group.components(separatedBy: ",")
          return Coordinate(x: Int(components[0])!, y: Int(components[1])!)
        }
      }
      .map { Line(coordinates: $0) }
    
    
    
    return AdventAnswer(
      partOne: lines,
      partTwo: 2
    )
  }
}

struct Line {
  let coordinates: [Coordinate]
  
  init(coordinates: [Coordinate]) {
    self.coordinates = coordinates
  }
}
