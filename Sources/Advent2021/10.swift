import AdventCommon
import Collections
import Algorithms

public struct Day10: AdventDay {

  public static let day = 10

  enum Chunk {
    case bracket
    case curlyBrace
    case parentheses
    case angleBracket
  }

  enum Character: String, CustomStringConvertible {
    case leftBracket = "["
    case rightBracket = "]"

    case leftCurlyBrace = "{"
    case rightCurlyBrace = "}"

    case leftParentheses = "("
    case rightParentheses = ")"

    case leftAngleBracket = "<"
    case rightAngleBracket = ">"

    var description: String { rawValue }

    var errorScore: Int {
      switch self {
      case .leftBracket, .leftParentheses, .leftCurlyBrace, .leftAngleBracket: return 0
      case .rightParentheses: return 3
      case .rightBracket: return 57
      case .rightCurlyBrace: return 1197
      case .rightAngleBracket: return 25137
      }
    }

    var autocompleteScore: Int {
      switch self {
      case .leftBracket, .leftParentheses, .leftCurlyBrace, .leftAngleBracket: return 0
      case .rightParentheses: return 1
      case .rightBracket: return 2
      case .rightCurlyBrace: return 3
      case .rightAngleBracket: return 4
      }
    }
  }

  enum LineState {
    case corrupted(illegalCharacter: Character)
    case incomplete(completionSequence: [Character])
  }

  public static func run(input: String) throws -> Any {
    let lines = input.components(separatedBy: .newlines).map { line in
      line.map { Character(rawValue: String($0))! }
    }

    let (incomplete, corrupted) = lines
      .map(parse(_:))
      .partitioned {
        if case LineState.corrupted = $0 { return true }
        else { return false }
      }

    return (
      partOne: totalSyntaxErrorScore(corruptedLines: corrupted),  // 296535
      partTwo: medianAutocompleteScore(incompleteLines: incomplete)  // 4245130838
    )
  }

  // Part 1
  static func totalSyntaxErrorScore(corruptedLines: [LineState]) -> Int {
    let illegalCharacters: [Character] = corruptedLines.compactMap {
      guard case LineState.corrupted(let illegalCharacter) = $0 else { return nil }
      return illegalCharacter
    }

    return illegalCharacters.map(\.errorScore).reduce(0, +)
  }

  // Part 2
  static func medianAutocompleteScore(incompleteLines: [LineState]) -> Int {
    let completionSequences: [[Character]] = incompleteLines.compactMap {
      guard case LineState.incomplete(let completionSequence) = $0 else { return nil }
      return completionSequence
    }

    let sortedAutocompleteScores = completionSequences
      .map { sequence in
        sequence.reduce(0) { runningScore, character in
          runningScore * 5 + character.autocompleteScore
        }
      }
      .sorted()

    let medianIndex = sortedAutocompleteScores.count / 2
    return sortedAutocompleteScores[medianIndex]
  }

  static func parse(_ _input: [Character]) -> LineState {
    var input = Deque(_input)
    var unclosedChunks = [Chunk]()

    while let next = input.popFirst() {
      switch next {
      case .leftAngleBracket:
        unclosedChunks.append(.angleBracket)
      case .leftBracket:
        unclosedChunks.append(.bracket)
      case .leftParentheses:
        unclosedChunks.append(.parentheses)
      case .leftCurlyBrace:
        unclosedChunks.append(.curlyBrace)

      case .rightAngleBracket:
        guard unclosedChunks.removeLast() == .angleBracket else {
          return .corrupted(illegalCharacter: next)
        }
      case .rightBracket:
        guard unclosedChunks.removeLast() == .bracket else {
          return .corrupted(illegalCharacter: next)
        }
      case .rightParentheses:
        guard unclosedChunks.removeLast() == .parentheses else {
          return .corrupted(illegalCharacter: next)
        }
      case .rightCurlyBrace:
        guard unclosedChunks.removeLast() == .curlyBrace else {
          return .corrupted(illegalCharacter: next)
        }
      }
    }

    let completionSequence: [Character] = unclosedChunks.reversed().map {
      switch $0 {
      case .bracket: return .rightBracket
      case .parentheses: return .rightParentheses
      case .curlyBrace: return .rightCurlyBrace
      case .angleBracket: return .rightAngleBracket
      }
    }

    return .incomplete(completionSequence: completionSequence)
  }
}
