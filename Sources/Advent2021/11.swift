import AdventCommon
import Algorithms

public struct Day11: AdventDay {

  public static let year = 2021
  public static let day = 11

  struct OctopusGrid: CustomStringConvertible {

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

    var rows: [[Int]]

    // MARK: Computed Properties

    var numRows: Int { rows.count }
    var numColumns: Int { rows.first!.count }

    // MARK: Coordinate API

    subscript(coordinate: Coordinate) -> Int {
      get {
//        print(coordinate)
        return rows[coordinate.y][coordinate.x] }
      set { rows[coordinate.y][coordinate.x] = newValue }
    }

    func isValidCoordinate(_ coordinate: Coordinate) -> Bool {
      (0..<numColumns).contains(coordinate.x) && (0..<numRows).contains(coordinate.y)
    }

    func coordinatesAdjacent(to coordinate: Coordinate) -> [Coordinate] {
      let adjacentDeltas = product(-1...1, -1...1)
      return adjacentDeltas
        .map { Coordinate(x: coordinate.x + $0, y: coordinate.y + $1) }
        .filter { $0 != coordinate }
        .filter { self.isValidCoordinate($0) }
    }

    // MARK: CustomStringConvertible

    var description: String {
      String(rows.map(String.init).joined(separator: "\n"))
    }

    // MARK: Methods

    func simulatingStep() -> (OctopusGrid, Int) {
      var newGrid = self

      // Part 1: Increment all by 1
      product(0..<newGrid.numColumns, 0..<newGrid.numRows).map(Coordinate.init).forEach {
        newGrid[$0] += 1
      }

      // Part 2: Flash!
      var flashCount = 0
      var didFlash = false
      var flashedCoordinates = Set<Coordinate>()

      repeat {
        didFlash = false
        product(0..<newGrid.numColumns, 0..<newGrid.numRows).map(Coordinate.init).forEach {
          guard newGrid[$0] > 9, !flashedCoordinates.contains($0) else { return }

          flashCount += 1
          didFlash = true
          flashedCoordinates.insert($0)

          newGrid.coordinatesAdjacent(to: $0).forEach { adjacentCoordinate in
            newGrid[adjacentCoordinate] += 1
          }
        }
      } while didFlash

      // Part 3: Anything over 9 -> down to 0
      product(0..<newGrid.numColumns, 0..<newGrid.numRows).map(Coordinate.init).forEach {
        if newGrid[$0] > 9 {
          newGrid[$0] = 0
        }
      }

      return (newGrid, flashCount)
    }
  }

  public static func solve(input: String) throws -> AdventAnswer {
    let rows = input.components(separatedBy: .newlines)
      .filter { !$0.isEmpty }
      .map { line in
        line.map { Int($0)! }
      }

    let grid = OctopusGrid(rows: rows)
    
    return AdventAnswer(
      partOne: totalFlashCountAfter100Steps(startingGrid: grid),  // 1620
      partTwo: firstStepAtWhichAllOctupusesFlash(startingGrid: grid)
    )
  }

  static func totalFlashCountAfter100Steps(startingGrid: OctopusGrid) -> Int {
    var grid = startingGrid
    var totalFlashCount = 0
    var step = 0

    while step < 100 {
      let (newGrid, roundFlashCount) = grid.simulatingStep()
      grid = newGrid
      totalFlashCount += roundFlashCount
      step += 1
    }

    return totalFlashCount
  }

  static func firstStepAtWhichAllOctupusesFlash(startingGrid: OctopusGrid) -> Int {
    var grid = startingGrid
    var step = 0

    func didAllOctupusesJustFlash() -> Bool {
      grid.rows.allSatisfy { octupusEnergyLevels in
        octupusEnergyLevels.allSatisfy { $0 == 0 }
      }
    }

    while !didAllOctupusesJustFlash() {
      let (newGrid, _) = grid.simulatingStep()
      grid = newGrid
      step += 1
    }

    return step
  }
}
