//
//  AdventDay.swift
//  
//
//  Created by Juan Fajardo on 12/5/24.
//

import Algorithms
import AdventCommon

public struct Day4: AdventDay {
  
  public static let year = 2024
  public static let day = 4
  public static let answer = AdventAnswer(partOne: 2578, partTwo: 1972)
  
  static let temp =
    """
    MMMSXXMASM
    MSAMXMSMSA
    AMXSXMAAMM
    MSAMASMSMX
    XMASAMXAMM
    XXAMMXXAMA
    SMSMSASXSS
    SAXAMASAAA
    MAMMMXMMMM
    MXMXAXMASX
    """
  
  public static func solve(input: String) throws -> AdventAnswer {
    let grid = Grid.make(adventInput: input, entryType: Character.self)
    
    return .init(
      partOne: self.part1(grid: grid),
      partTwo: self.part2(grid: grid)
    )
  }
  
  // MARK: Part 1
  
  private static func part1(grid: Grid<Character>) -> Int {
    return product(
      grid.filter { $0.value == "X" }.map(\.coordinate),
      Direction.allCases
    ).filter { xCoordinate, direction in
      if let mCoordinate = grid.coordinate(inDirection: direction, of: xCoordinate),
         grid[mCoordinate] == "M",
         let aCoordinate = grid.coordinate(inDirection: direction, of: mCoordinate),
         grid[aCoordinate] == "A",
         let sCoordinate = grid.coordinate(inDirection: direction, of: aCoordinate),
         grid[sCoordinate] == "S"
      {
        return true
      } else {
        return false
      }
    }
    .count
  }
  
  // MARK: Part 2
  
  private static func part2(grid: Grid<Character>) -> Int {
    let aCoordinatesInMAS =
      product(
        grid.filter { $0.value == "M" }.map(\.coordinate),
        Direction.diagonals
      ).compactMap { mCoordinate, direction -> Coordinate? in
        guard let aCoordinate = grid.coordinate(inDirection: direction, of: mCoordinate),
           grid[aCoordinate] == "A",
           let sCoordinate = grid.coordinate(inDirection: direction, of: aCoordinate),
           grid[sCoordinate] == "S"
        else {
          return nil
        }
        return aCoordinate
      }
  
    let bag = Bag(aCoordinatesInMAS)
    return bag.filter { $0.value == 2 }.count
  }
}
