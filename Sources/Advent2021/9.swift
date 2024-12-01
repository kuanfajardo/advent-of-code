import AdventCommon
import Regex
import Algorithms

public struct Day9: AdventDay {

  public static let year = 2021
  public static let day = 9
  public static let answer = AdventAnswer(partOne: 566, partTwo: 891684)

  struct FloorMap {

    struct Coordinate: Hashable {
      let x: Int
      let y: Int

      init(x: Int, y: Int) {
        self.x = x
        self.y = y
      }

      init(_ tuple: (Int, Int)) {
        self.x = tuple.0
        self.y = tuple.1
      }
    }

    // MARK: Stored Properties
    
    let rows: [[Int]]

    // MARK: Computed Properties

    var numRows: Int { rows.count }
    var numColumns: Int { rows.first!.count }

    // MARK: Coordinate API

    subscript(coordinate: Coordinate) -> Int {
      rows[coordinate.y][coordinate.x]
    }

    func isValidCoordinate(_ coordinate: Coordinate) -> Bool {
      (0..<numColumns).contains(coordinate.x) && (0..<numRows).contains(coordinate.y)
    }

    // MARK: CustomStringConvertible

    var description: String {
      String(rows.map(String.init).joined(separator: "\n"))
    }
  }

  public static func solve(input: String) throws -> AdventAnswer {
    let rows = input.components(separatedBy: .newlines).filter { !$0.isEmpty }.map { rowString in
      rowString.map { Int($0)! }
    }

    let floorMap = FloorMap(rows: rows)

    let lowHeightCoordinates = product(0..<floorMap.numColumns, 0..<floorMap.numRows)
      .map(FloorMap.Coordinate.init)
      .filter { coordinate in
        adjacentCoordinates(of: coordinate, in: floorMap)
          .map { floorMap[$0] }
          .allSatisfy {
            floorMap[coordinate] < $0
          }
      }

    return AdventAnswer(
      partOne: lowHeightCoordinates.map { floorMap[$0] + 1 }.reduce(0, +),
      partTwo: lowHeightCoordinates
        .map { sizeOfBasin(lowPoint: $0, in: floorMap) }
        .max(count: 3)
        .reduce(1, *)
    )
  }

  // MARK: Neighbor-Visiting Logic

  private static func adjacentCoordinates(
    of coordinate: FloorMap.Coordinate, in floorMap: FloorMap) -> [FloorMap.Coordinate]
  {
    let adjacentDeltas: [(Int, Int)] = [
      (-1, 0), (1, 0), (0, -1), (0, 1)
    ]

    return adjacentDeltas
      .map { FloorMap.Coordinate(x: coordinate.x + $0, y: coordinate.y + $1) }
      .filter { floorMap.isValidCoordinate($0) }
  }

  private static func sizeOfBasin(lowPoint: FloorMap.Coordinate, in floorMap: FloorMap) -> Int {
    // Set of already-visited coordinates.
    var visited = Set<FloorMap.Coordinate>()

    func findBasin(around coordinate: FloorMap.Coordinate) -> [FloorMap.Coordinate] {
      // Base cases
      if floorMap[coordinate] == 9 { return [] }
      if visited.contains(coordinate) { return [] }

      visited.insert(coordinate)

      return adjacentCoordinates(of: coordinate, in: floorMap)
        .map { findBasin(around: $0) }
        .reduce([], +) + [coordinate]
    }

    let basin = findBasin(around: lowPoint)
    return basin.count
  }
}

extension Int {

  init?(_ character: Character) {
    switch character {
    case "0": self = 0
    case "1": self = 1
    case "2": self = 2
    case "3": self = 3
    case "4": self = 4
    case "5": self = 5
    case "6": self = 6
    case "7": self = 7
    case "8": self = 8
    case "9": self = 9
    default: return nil
    }
  }
}
