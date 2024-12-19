//
//  6.swift
//  Advent
//
//  Created by Juan Fajardo on 12/17/24.
//

import AdventCommon

public struct Day6: AdventDay {
  
  public static let year = 2024
  public static let day = 6
  public static let answer = AdventAnswer(partOne: 4752, partTwo: 1719)
  
  static let temp =
    """
    ....#.....
    .........#
    ..........
    ..#.......
    .......#..
    ..........
    .#..^.....
    ........#.
    #.........
    ......#...
    """
  
  enum Entry: Character {
    case empty = "."
    case blocked = "#"
    case `guard` = "^"
  }
  
  public static func solve(input: String) throws -> AdventAnswer {
    let grid = Grid.make(adventInput: input, entryType: Entry.self)
    return .init(
      partOne: try self.part1(grid: grid),
      partTwo: self.part2(grid: grid)
    )
  }
  
  enum SimulationResult: Equatable {
    case exit(visited: Set<DirectedCoordinate>)
    case infiniteLoop
  }
  
  private static func part1(grid: Grid<Entry>) throws -> Int {
    guard case .exit(let visited) = self.runSimulation(grid: grid) else {
      throw AdventError.noSolutionFound
    }
    return Set(visited.map(\.coordinate)).count
  }
  
  private static func part2(grid: Grid<Entry>) -> Int {
    return grid
      .filter { $0.value == .empty }
      .filter {
        var newGrid = grid
        newGrid[$0.coordinate] = .blocked
        return self.runSimulation(grid: newGrid) == .infiniteLoop
      }
      .count
  }
  
  private static func runSimulation(grid: Grid<Entry>) -> SimulationResult {
    let start = DirectedCoordinate(
      coordinate: grid.first { $0.value == .guard }!.coordinate,
      direction: .top
    )
    var visited = Set<DirectedCoordinate>()
    var coordinate = start
    while let nextCoordinate = self.nextCoordinate(after: coordinate, in: grid) {
      guard !visited.contains(nextCoordinate) else {
        return .infiniteLoop
      }
      visited.insert(nextCoordinate)
      coordinate = nextCoordinate
    }
    return .exit(visited: visited)
  }

  private static func nextCoordinate(after coordinate: DirectedCoordinate, in grid: Grid<Entry>) -> DirectedCoordinate? {
    let availableRotations: [Direction.RotationDegrees] = [._0, ._90, ._180, ._270]
    for rotation in availableRotations {
      let direction = coordinate.direction.rotated(by: rotation, clockwise: true)
      let next = grid.coordinate(
        inDirection: direction,
        of: coordinate.coordinate
      )
      
      if let next {
        switch grid[next] {
        case .blocked:
          continue
        case .empty, .guard:
          return DirectedCoordinate(coordinate: next, direction: direction)
        }
      } else {
        // Went off the grid, done!
        return nil
      }
    }

    fatalError("Unreachable!")
  }
}
