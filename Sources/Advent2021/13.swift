import AdventCommon
import Regex
import Algorithms

public struct Day13: AdventDay {

  public static let day = 13

  struct Fold: RegexRepresentable {
    enum Axis: String, ExpressibleByCaptureGroup {
      case x, y
    }

    let axis: Axis
    let position: Int

    static let regex: Regex = #"fold along (?<axis>x|y)=(?<position>\d+)"#

    init(match: Match) throws {
      self.axis = try match.captureGroup(named: "axis", as: Axis.self)
      self.position = try match.captureGroup(named: "position", as: Int.self)
    }
  }

  struct Dot: RegexRepresentable, Hashable, CustomStringConvertible, Comparable {
    let x: Int
    let y: Int

    static let regex: Regex = #"(?<x>\d+),(?<y>\d+)"#

    init(match: Match) throws {
      self.x = try match.captureGroup(named: "x", as: Int.self)
      self.y = try match.captureGroup(named: "y", as: Int.self)
    }

    init(x: Int, y: Int) {
      self.x = x
      self.y = y
    }

    var description: String { "(\(x),\(y))" }

    static func < (lhs: Day13.Dot, rhs: Day13.Dot) -> Bool {
      return lhs.x != rhs.x ? lhs.x < rhs.x : lhs.y < rhs.y
    }
  }

  struct Paper {
    let dots: Set<Dot>

    func folded(across fold: Fold) -> Paper {
      func transform(dot: Dot, across fold: Fold) -> Dot {
        switch fold.axis {
        case .x where dot.x > fold.position:
          return Dot(x: 2 * fold.position - dot.x, y: dot.y)

        case .y where dot.y > fold.position:
          return Dot(x: dot.x, y: 2 * fold.position - dot.y)

        default:
          return dot
        }
      }

      let dots = Set(dots.map { transform(dot: $0, across: fold) })
      return Paper(dots: dots)
    }

    func folded(across folds: [Fold]) -> Paper {
      folds.reduce(self) { $0.folded(across: $1) }
    }

    func draw() {
      let maxX = dots.map(\.x).max()!
      let maxY = dots.map(\.y).max()!
      var rows = [[String]](repeating: [String](repeating: " ", count: maxX + 1), count: maxY + 1)

      dots.forEach {
        rows[$0.y][$0.x] = "#"
      }

      let representation = rows.map { $0.joined(separator: "") }.joined(separator: "\n")
      print(representation)
    }
  }

  public static func run(input: String) throws -> Any {
    let dots = try Dot.matches(in: input)
    let folds = try Fold.matches(in: input)

    let startingPaper = Paper(dots: Set(dots))

    return (
      partOne: startingPaper.folded(across: folds[0]).dots.count,
      partTwo: startingPaper.folded(across: folds).draw() // HLBUBGFR
    )
  }
}

extension RawRepresentable where RawValue == String {
  init?(_ value: String) {
    self.init(rawValue: value)
  }
}
