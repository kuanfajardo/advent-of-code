//
//  16.swift
//
//
//  Created by Juan Fajardo on 12/2/24.
//

import AdventCommon

public struct Day16: AdventDay {
  
  public static let year = 2023
  public static let day = 16
  public static let answer = AdventAnswer(partOne: 7996, partTwo: 8239)
  
  static let temp =
    #"""
    .|...\....
    |.-.\.....
    .....|-...
    ........|.
    ..........
    .........\
    ..../.\\..
    .-.-/..|..
    .|....-|.\
    ..//.|....
    """#
  
  struct Entry: Hashable {
    
    enum Object: Character {
      case forwardMirror = #"\"#
      case backwardMirror = "/"
      case verticalSplitter = "|"
      case horizontalSplitter = "-"
      case empty = "."
    }
    
    let object: Object
    var isEnergized = false
  }
  
  public static func solve(input: String) throws -> AdventAnswer {
    let grid = Grid.make(
      adventInput: input,
      entryType: Entry.self,
      inputType: Entry.Object.self
    ) {
      Entry(object: $0)
    }

    return .init(
      partOne: self.numberOfEnergizedTiles(in: grid, startingAt: .init(coordinate: .zero, direction: .right)),
      partTwo: self.part2(grid: grid)
    )
  }
  
  private static func numberOfEnergizedTiles(
    in grid: Grid<Entry>,
    startingAt start: DirectedCoordinate
  ) -> Int {
    var grid = grid
    var visitedCoordinates = Set<DirectedCoordinate>()
    
    func visit(coordinate: Coordinate, direction: Direction) {
      let directedCoordinate = DirectedCoordinate(coordinate: coordinate, direction: direction)
      guard !visitedCoordinates.contains(directedCoordinate) else {
        return
      }
      
      visitedCoordinates.insert(directedCoordinate)
      
      grid[coordinate].isEnergized = true
      
      let nextCoordinateDirections: [Direction]
      switch grid[coordinate].object {
      case .empty:
        nextCoordinateDirections = [direction]
        
      case .backwardMirror:  // "/"
        switch direction {
        case .top: nextCoordinateDirections = [.right]
        case .left: nextCoordinateDirections = [.bottom]
        case .bottom: nextCoordinateDirections = [.left]
        case .right: nextCoordinateDirections = [.top]
        default:
          fatalError("Unsupported direction.")
        }
        
      case .forwardMirror:  // "\"
        switch direction {
        case .top: nextCoordinateDirections = [.left]
        case .left: nextCoordinateDirections = [.top]
        case .bottom: nextCoordinateDirections = [.right]
        case .right: nextCoordinateDirections = [.bottom]
        default:
          fatalError("Unsupported direction.")
        }
        
      case .horizontalSplitter:
        switch direction {
        case .top, .bottom:
          nextCoordinateDirections = [.left, .right]
        default:
          nextCoordinateDirections = [direction]
        }
        
      case .verticalSplitter:
        switch direction {
        case .left, .right:
          nextCoordinateDirections = [.top, .bottom]
        default:
          nextCoordinateDirections = [direction]
        }
      }
      
      for nextCoordinateDirection in nextCoordinateDirections {
        guard let nextCoordinate = grid.coordinate(inDirection: nextCoordinateDirection, of: coordinate) else {
          continue
        }
        visit(coordinate: nextCoordinate, direction: nextCoordinateDirection)
      }
    }
    
    visit(coordinate: start.coordinate, direction: start.direction)
    
    return grid.map(\.value.isEnergized).filter { $0 == true }.count
  }
  
  // MARK: Part 2
  
  private static func part2(grid: Grid<Entry>) -> Int {
    let possibleStarts =
      grid.topEdge.map { DirectedCoordinate(coordinate: $0, direction: .bottom) }
      + grid.leftEdge.map { DirectedCoordinate(coordinate: $0, direction: .right) }
      + grid.bottomEdge.map { DirectedCoordinate(coordinate: $0, direction: .top) }
      + grid.rightEdge.map { DirectedCoordinate(coordinate: $0, direction: .left) }
      
    return possibleStarts.map { self.numberOfEnergizedTiles(in: grid, startingAt: $0) }.max()!
  }
}
