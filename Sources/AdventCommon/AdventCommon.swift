import Foundation
import LASwift
import Regex

// MARK: Advent Types

public struct AdventAnswer: CustomStringConvertible, Equatable {
  
  // MARK: Properties

  public let partOne: AnyEquatable

  public let partTwo: AnyEquatable
  
  // MARK: Initialization
  
  public init<T: Equatable, S: Equatable>(partOne: T, partTwo: S) {
    self.partOne = AnyEquatable(partOne)
    self.partTwo = AnyEquatable(partTwo)
  }
  
  // MARK: Special
  
  public static let unsolved = AdventAnswer(partOne: "", partTwo: "")
  
  // MARK: CustomStringConvertible
  
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
  
  /// The method that solves the day's problem.
  ///
  /// - Parameter input: The parsed input text.
  static func solve(input: String) throws -> AdventAnswer
  
  /// The known answer, to serve as a test case once initially solved.
  static var answer: AdventAnswer { get }
}

public enum AdventError: Error {
  case noSolutionFound
  case malformedInput(input: any StringProtocol = "")
  
  public static var malformedInput: AdventError { .malformedInput() }
}

/// A dummy type used to return an answer for days where the answer
/// is a side effect (i.e. something printed out on the console and
/// interpreted by the user).
public struct SideEffectAnswer: Equatable {
  
  /// Use this initializer when returning an `AdventAnswer` in `solve`,
  /// with the side effect in the block parameter.
  public init(_ sideEffect: () -> Void) {
    sideEffect()
  }
  
  /// Use this initializer in the `AdventDay.answer` property, to
  /// document the expected answer regardless of the side effect.
  public init(_ answer: Any) {}
}

public struct NonCheckableAnswer: Equatable {
  
  public init(_ answer: Any) {}
}

// MARK: Parsing

let inputDirectory = URL(fileURLWithPath: "/Users/juanfajardo/Desktop/Advent/Resources/Advent")
let inputDirectory_icloud = URL(fileURLWithPath: "//Users/juanfajardo/Library/Mobile Documents/com~apple~CloudDocs/Desktop/Advent/Resources/Advent")

extension AdventDay {

  public static func run() throws -> AdventAnswer {
    let inputFile = inputDirectory_icloud
      .appendingPathComponent("\(self.year)", isDirectory: true)
      .appendingPathComponent("input_\(self.day).txt", isDirectory: false)

    let input = try String(contentsOf: inputFile).trimmingCharacters(in: .whitespacesAndNewlines)
    return try self.solve(input: input)
  }
}
