//
//  10.swift
//
//
//  Created by Juan Fajardo on 12/18/23.
//

import AdventCommon
import Algorithms

public struct Day10: AdventDay {
  
  public static var year: Int { 2023 }
  
  public static var day: Int { 10 }
  
  public static let answer = AdventAnswer(partOne: 6690, partTwo: 525)
  
  enum Pipe: Character, Hashable {
    case vertical = "|"
    case horizontal = "-"
    case northeast = "L"
    case northwest = "J"
    case southwest = "7"
    case southeast = "F"
    case ground = "."
    case start = "S"
  }
  
  typealias GridEntry = Grid<Pipe>.Entry
  
  enum Direction {
    case north, east, south, west
    
    static prefix func ~(operand: Direction) -> Direction {
      switch operand {
      case .north: return .south
      case .south: return .north
      case .east: return .west
      case .west: return .east
      }
    }
  }
  
  public static func solve(input: String) throws -> AdventAnswer {
    let rows = input.components(separatedBy: .newlines).map { $0.compactMap { Pipe(rawValue: $0) } }
    var grid = Grid(rows: rows)
    let start = grid.first { $0.value == .start }!

    let (loop, startPipe) = self.findLoop(in: grid, startingAt: start)
    grid[start.coordinate] = startPipe
    
    return AdventAnswer(
      partOne: loop.count / 2,
      partTwo: self.numberOfTiles(insideLoop: loop, withinGrid: grid)
    )
  }
  
  // MARK: Part 1
  
  static func findLoop(in grid: Grid<Pipe>, startingAt start: GridEntry) -> (Set<Coordinate>, Pipe) {
    let top = (
      coordinate: grid.top(of: start.coordinate)!,
      directionToPreviousCoordinate: Direction.south
    )
    let bottom = (
      coordinate: grid.bottom(of: start.coordinate)!,
      directionToPreviousCoordinate: Direction.north
    )
    let left = (
      coordinate: grid.left(of: start.coordinate)!,
      directionToPreviousCoordinate: Direction.west
    )
    let right = (
      coordinate: grid.right(of: start.coordinate)!, 
      directionToPreviousCoordinate: Direction.east
    )
      
    let _loop: [Coordinate] = [top, bottom, left, right].lazy.firstNonNil {
      try? visit(grid: grid, start: start.coordinate, firstCoordinate: $0.coordinate, comingFrom: $0.directionToPreviousCoordinate)
    }!
    let loop = Set(_loop)
    
    let startNeighbors: Set<Coordinate> = [
      _loop[1],
      _loop[_loop.count - 2]  // Start is at both beginning and end.
    ]

    let startPipe: Pipe
    if startNeighbors == [top.coordinate, bottom.coordinate] {
      startPipe = .vertical
    } else if startNeighbors == [top.coordinate, left.coordinate] {
      startPipe = .northwest
    } else if startNeighbors == [top.coordinate, right.coordinate] {
      startPipe = .northeast
    } else if startNeighbors == [left.coordinate, right.coordinate] {
      startPipe = .horizontal
    } else if startNeighbors == [left.coordinate, bottom.coordinate] {
      startPipe = .southwest
    } else if startNeighbors == [right.coordinate, bottom.coordinate] {
      startPipe = .southeast
    } else {
      fatalError("Unknown start pipe.")
    }
        
    return (loop, startPipe)
  }
  
  enum LoopError: Error {
    case alreadyVisited
    case badCoordinate
    case invariantViolated
  }
  
  static func visit(
    grid: Grid<Pipe>,
    start: Coordinate,
    firstCoordinate: Coordinate,
    comingFrom directionToPreviousCoordinate: Direction
  ) throws -> [Coordinate] {
    var loop = [start]
    var coordinate = firstCoordinate
    var directionToPreviousCoordinate = directionToPreviousCoordinate
    var visited: Set<Coordinate> = [start]

    while true {
      loop.append(coordinate)

      if coordinate == start {
        return loop
      }

      if visited.contains(coordinate) {
        throw LoopError.alreadyVisited
      }

      visited.insert(coordinate)
      
      let directionToNextCoordinate: Direction
      let value: Pipe = grid[coordinate]
      switch (value, directionToPreviousCoordinate) {
      case (.horizontal, .west), (.northeast, .north), (.southeast, .south):
        directionToNextCoordinate = .east
      case (.horizontal, .east), (.northwest, .north), (.southwest, .south):
        directionToNextCoordinate = .west
      case (.vertical, .north), (.southeast, .east), (.southwest, .west):
        directionToNextCoordinate = .south
      case (.vertical, .south), (.northeast, .east), (.northwest, .west):
        directionToNextCoordinate = .north
      default:
        throw LoopError.invariantViolated
      }
      
      let nextCoordinate: Coordinate?
      switch directionToNextCoordinate {
      case .north: nextCoordinate = grid.top(of: coordinate)
      case .south: nextCoordinate = grid.bottom(of: coordinate)
      case .west: nextCoordinate = grid.left(of: coordinate)
      case .east: nextCoordinate = grid.right(of: coordinate)
      }
      
      guard let nextCoordinate else { throw LoopError.badCoordinate }
      
      coordinate = nextCoordinate
      directionToPreviousCoordinate = ~directionToNextCoordinate
    }
  }
  
  // MARK: Part 2
  
  indirect enum RayTracingState {
    case outside
    case inside
    case pending(current: RayTracingState, expecting: Pipe)
    
    mutating func flip() {
      switch self {
      case .outside: self = .inside
      case .inside: self = .outside
      case .pending(let current, _):
        self = current
        self.flip()
      }
    }
  }
  
  // https://en.wikipedia.org/wiki/Point_in_polygon#Ray_casting_algorithm
  static func numberOfTiles(insideLoop loop: Set<Coordinate>, withinGrid grid: Grid<Pipe>) -> Int {
    var tilesInside = 0
    for row in grid.rows {
      var state: RayTracingState = .outside
      for entry in row {
        if loop.contains(entry.coordinate) {
          switch entry.value {
          case .horizontal: break
          case .vertical: state.flip()
          case .northeast: state = .pending(current: state, expecting: .southwest)
          case .southeast: state = .pending(current: state, expecting: .northwest)
          case .northwest, .southwest:
            guard case .pending(let current, let expecting) = state else {
              fatalError("Not possible.")
            }
            if entry.value == expecting {
              state.flip()
            } else {
              state = current
            }

          case .ground, .start:
            fatalError("Not possible.")
          }
        } else {
          if case .inside = state {
            tilesInside += 1
          }
        }
      }
    }
    
    return tilesInside
  }
}
