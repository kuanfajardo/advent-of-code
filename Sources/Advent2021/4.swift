import AdventCommon
import Regex

public struct Day4: AdventDay {

  public static let day = 4

  struct BingoBoard {
    var lines: [Set<Int>]
    var unmarkedNumbers: Set<Int>

    init<S: Sequence>(numbers: S) where S.Element == Int {
      var rows = [Set<Int>](repeating: [], count: 5)
      var columns = [Set<Int>](repeating: [], count: 5)
      for (index, number) in numbers.enumerated() {
        rows[index / 5].insert(number)
        columns[index % 5].insert(number)
      }

      self.lines = rows + columns
      self.unmarkedNumbers = Set(numbers)
    }

    mutating func markAsDrawn(_ drawnNumber: Int) -> Int? {
      for (index, var line) in lines.enumerated() {
        if line.remove(drawnNumber) != nil {
          lines[index] = line
          unmarkedNumbers.remove(drawnNumber)
          if line.isEmpty { return drawnNumber * unmarkedNumbers.reduce(0, +) }
        }
      }
      return nil
    }
  }

  public static func run(input: String) throws -> Any {
    guard let lineBreakIndex = input.firstIndex(of: "\n") else { throw AdventError.malformedInput }
    let bingoNumbers = Int.matches(in: String(input.prefix(upTo: lineBreakIndex)))
    let boards = input[lineBreakIndex...]
      .components(separatedBy: .whitespacesAndNewlines)
      .filter { !$0.isEmpty }
      .map { Int($0)! }
      .chunks(ofCount: 25)
      .map { BingoBoard(numbers: $0) }

    let scores = try boards.map { board -> (numbersDrawn: Int, score: Int) in
      var board = board
      for (i, number) in bingoNumbers.enumerated() {
        if let score = board.markAsDrawn(number) {
          return (i, score)
        }
      }
      throw AdventError.noSolutionFound
    }

    let minMax = scores.minAndMax { lhs, rhs in
      lhs.numbersDrawn < rhs.numbersDrawn
    }!

    return (
      partOne: minMax.min.score,  // 54275
      partTwo: minMax.max.score  // 13158
    )
  }
}
