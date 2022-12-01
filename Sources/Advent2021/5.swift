import AdventCommon
import Regex

public struct Day5: AdventDay {

  public static let day = 5

  struct Line: RegexRepresentable {
    static let regex: Regex = #"(?<x1>[0-9]+),(?<y1>[0-9]+) -> (?<x2>[0-9]+),(?<y2>[0-9]+)"#

    let x1: Int
    let y1: Int
    let x2: Int
    let y2: Int

    var slope: Double {
      Double(y2 - y1) / Double(x2 - x1)
    }

    var yIntercept: Double {
      Double(y2) - (slope * Double(x2))
    }

    var isHorizontal: Bool { y1 == y2 }
    var isVertical: Bool { x1 == x2 }

    init(match: Match) {
      self.x1 = match["x1", as: Int.self]!
      self.y1 = match["y1", as: Int.self]!
      self.x2 = match["x2", as: Int.self]!
      self.y2 = match["y2", as: Int.self]!
    }
  }

  struct Grid: CustomStringConvertible {
    // 1000 x 1000 grid
    var rows = [[Int]](repeating: [Int](repeating: 0, count: 1000), count: 1000)

    mutating func draw(_ line: Line) {
      if line.isVertical {
        let (minY, maxY) = [line.y1, line.y2].minAndMax()!
        for y in minY...maxY {
          rows[y][line.x2] += 1
        }
      } else {
        let (minX, maxX) = [line.x1, line.x2].minAndMax()!
        for x in minX...maxX {
          let y = line.slope * Double(x) + line.yIntercept
          // Problem given is that all slopes are integral, so `y` will always be integral.
          rows[Int(y)][x] += 1
        }
      }
    }

    var description: String {
      String(rows.map { row in
        row.map { String($0 )}.joined(by: " ")
      }.joined(separator: "\n"))
    }
  }

  public static func run(input: String) throws -> Any {
    let lines = Line.matches(in: input)
    return (
      partOne: numberOfPointsWithMoreThanTwoLines(lines: lines.filter { $0.isVertical || $0.isHorizontal }),  // 3990
      partTwo: numberOfPointsWithMoreThanTwoLines(lines: lines)  // 21305
    )
  }

  private static func numberOfPointsWithMoreThanTwoLines(lines: [Line]) -> Int {
    var grid = Grid()
    lines.forEach {
      grid.draw($0)
    }
    return grid.rows.flatMap { $0 }.filter { $0 >= 2 }.count
  }
}
