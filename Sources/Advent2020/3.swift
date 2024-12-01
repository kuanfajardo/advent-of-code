import AdventCommon
import Regex

/// https://adventofcode.com/2020/day/3
public struct Day3: AdventDay {
  
  public static let year = 2020
  public static let day = 3
  public static let answer = AdventAnswer(partOne: 284, partTwo: 3510149120)

  // MARK: Models
  
  enum Space: Character {
    case tree = "#"
    case free = "."
  }
  
  struct Row: RegexRepresentable {
    let spaces: [Space]
    
    static let regex: Regex = #"(?m)^(?<spaces>[#\.]+)$"#
    
    init(match: Match) {
      self.spaces = match["spaces"]!.map { Space(rawValue: $0)! }
    }
    
    subscript(column: Int) -> Space {
      spaces[column % spaces.count]
    }
  }
  
  typealias Slope = (columns: Int, rows: Int)
  
  class Ride {
    
    // MARK: Constants
    let rows: [Row]
    let slope: Slope
    
    // MARK: Running State
    var row = 0
    var column = 0
    var numTreesHit = 0
    
    init(rows: [Row], slope: Slope) {
      self.rows = rows
      self.slope = slope
    }
    
    private func move() -> Bool {
      guard
        row < rows.count,
        row + slope.rows < rows.count
      else {
        return false
      }
      
      row += slope.rows
      column += slope.columns
      return true
    }
    
    func ride() -> Int {
      while move() {
        if self.rows[row][column] == .tree {
          numTreesHit += 1
        }
      }
      return numTreesHit
    }
  }
  
  // MARK: Logic
  
  public static func solve(input: String) throws -> AdventAnswer {
    let rows = Row.matches(in: input)
    
    let partOneSlope = (columns: 3, rows: 1)
    let partTwoSlopes: [Slope] = [
      (columns: 1, rows: 1),
      partOneSlope,
      (columns: 5, rows: 1),
      (columns: 7, rows: 1),
      (columns: 1, rows: 2),
    ]
    
    return AdventAnswer(
      partOne: numTreesHit(ridingDown: rows, using: partOneSlope),
      partTwo: partTwoSlopes
        .map { numTreesHit(ridingDown: rows, using: $0) }
        .reduce(1, *)
    )
  }
  
  private static func numTreesHit(ridingDown rows: [Row], using slope: Slope) -> Int {
    Ride(rows: rows, slope: slope).ride()
  }
}
