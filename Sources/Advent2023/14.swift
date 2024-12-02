//
//  File.swift
//  
//
//  Created by Juan Fajardo on 12/1/24.
//

import AdventCommon
import Algorithms

public struct Day14: AdventDay {
  
  public static let year = 2023
  public static let day = 14
  public static let answer = AdventAnswer(partOne: 110779, partTwo: 86069)
  
  static let temp =
    """
    O....#....
    O.OO#....#
    .....##...
    OO.#O....O
    .O.....O#.
    O.#..O.#.#
    ..O..#O..O
    .......O..
    #....###..
    #OO..#....
    """
  
  enum Entry: Character, CustomStringConvertible {
    case empty = "."
    case cubeRock = "#"
    case roundRock = "O"
    
    var description: String { String(self.rawValue) }
  }
  
  public static func solve(input: String) throws -> AdventAnswer {
    let grid = Grid.make(adventInput: input, entryType: Entry.self)
    return .init(
      partOne: self.part1(grid: grid),
      partTwo: self.part2(grid: grid)
    )
  }
  
  private static func part1(grid: Grid<Entry>) -> Int {
    var grid = grid
    self.tiltGrid(&grid, inDirection: .top)
    return self.totalLoadOnNorthBeam(of: grid)
  }
  
  private static func part2(grid: Grid<Entry>) -> Int {
    var grid = grid
    var previousGrids: [Grid<Entry>: Int] = [
      grid: 0
    ]

    var previousCycles: [Int: Grid<Entry>] = [
      0: grid
    ]
    
    let numCycles = 1_000_000_000
    
    for i in 1...numCycles {
      self.tiltGrid(&grid, inDirection: .top)
      self.tiltGrid(&grid, inDirection: .left)
      self.tiltGrid(&grid, inDirection: .bottom)
      self.tiltGrid(&grid, inDirection: .right)

      if let j = previousGrids[grid] {
        let loopLength = i - j
        let distanceLeft = numCycles - i
        let cycleIndex = distanceLeft % loopLength
        let gridIndex = j + cycleIndex
        grid = previousCycles[gridIndex]!
        break
      } else {
        previousGrids[grid] = i
        previousCycles[i] = grid
      }
    }
    return self.totalLoadOnNorthBeam(of: grid)
  }

  private static func tiltGrid(
    _ grid: inout Grid<Entry>,
    inDirection direction: Grid<Entry>.Direction
  ) {
    while true {
      var didEdit = false
      for entry in grid where entry.value == .roundRock {
        guard
          let newCoordinate = grid.coordinate(inDirection: direction, of: entry.coordinate),
          grid[newCoordinate] == .empty
        else {
          continue
        }

        grid[newCoordinate] = .roundRock
        grid[entry.coordinate] = .empty
        didEdit = true
      }
      
      if !didEdit {
        break
      }
    }
  }
  
  private static func totalLoadOnNorthBeam(of grid: Grid<Entry>) -> Int {
    return grid.valueRows.enumerated().map { i, row in
      let distanceFromSouth = grid.numRows - i
      let numRocksInRow = row.filter { $0 == .roundRock }.count
      return numRocksInRow * distanceFromSouth
    }
    .reduce(0, +)
  }
}

extension Grid {
  
  public static func make(
    adventInput input: String,
    entryType: Element.Type
  ) -> Grid<Element> where Element: RawRepresentable, Element.RawValue == Character {
    let rows = input.components(separatedBy: .newlines)
    let typedRows = rows.map { row in
      row.map { Element(rawValue: $0)! }
    }
    return Grid(rows: typedRows)
  }
}
