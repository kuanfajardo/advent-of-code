import Foundation
import LASwift
import Regex

// MARK: Advent Types

public struct AdventAnswer: CustomStringConvertible {
  let partOne: Any
  let partTwo: Any
  
  public init(partOne: Any, partTwo: Any) {
    self.partOne = partOne
    self.partTwo = partTwo
  }
  
  public var description: String {
    """
    Answer:
      - PART 1: \(self.partOne)
      - PART 2: \(self.partTwo)
    """
  }
}

public protocol AdventDay {
  static var day: Int { get }
  static var year: Int { get }
  static func solve(input: String) throws -> AdventAnswer
}

public enum AdventError: Error {
  case noSolutionFound
  case malformedInput(input: any StringProtocol = "")
  
  public static var malformedInput: AdventError { .malformedInput() }
}
