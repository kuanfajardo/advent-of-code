//
//  13.swift
//
//
//  Created by Juan Fajardo on 11/30/24.
//

import AdventCommon

public struct Day13: AdventDay {
  
  public static let year = 2023
  
  public static let day = 13
  
  public static let answer = AdventAnswer.unsolved
  
  public static let temp =
    """
    #.##..##.
    ..#.##.#.
    ##......#
    ##......#
    ..#.##.#.
    ..##..##.
    #.#.##.#.

    #...##..#
    #....#..#
    ..##..###
    #####.##.
    #####.##.
    ..##..###
    #....#..#
    """

  public enum Entry: Character, CustomDebugStringConvertible, Equatable {
    case ash = "."
    case rock = "#"
    
    public var debugDescription: String { "\(self.rawValue)" }
    
    var smudged: Entry {
      switch self {
      case .ash: .rock
      case .rock: .ash
      }
    }
  }
  
  public static func solve(input: String) throws -> AdventAnswer {
    let patterns = input
      .components(separatedBy: .newlines)
      .split(separator: "")
      .map { pattern in
        pattern.map { row in
          row.map { char in
            Entry(rawValue: char)!
          }
        }
      }
      .map(Grid.init(rows:))

    return .init(
      partOne: try patterns.map(self.firstMirrorLine(for:)).map(\.score).reduce(0, +),  // 28895
      partTwo: try patterns.map(self.firstMirrorLineWithSmudge(for:)).map(\.score).reduce(0, +)  // 31603
    )
  }
  
  enum MirrorLine: Equatable {
    case horizontal(index: Int)
    case vertical(index: Int)
    
    var score: Int {
      switch self {
      case .horizontal(let index): index * 100
      case .vertical(let index): index
      }
    }
  }
  
  // MARK: Part 1

  private static func firstMirrorLine(for grid: Grid<Entry>) throws -> MirrorLine {
    guard let mirrorLine = self.firstMirrorLine(for: grid, where: { _ in true }) else {
      throw "No mirror line found"
    }
    return mirrorLine
  }
  
  // MARK: Part 2
  
  private static func firstMirrorLineWithSmudge(for originalGrid: Grid<Entry>) throws -> MirrorLine {
    let originalMirrorLine = try self.firstMirrorLine(for: originalGrid)

    var grid = originalGrid

    for coordinate in grid.coordinates {
      // 1. "Smudge" the value of the current coordinate.
      grid[coordinate] = grid[coordinate].smudged
      
      // 2. Calculate any new potential mirror lines, otherwise, revert smudge.
      if let newMirrorLine = self.firstMirrorLine(for: grid, where: { $0 != originalMirrorLine }) {
        return newMirrorLine
      } else {
        grid[coordinate] = grid[coordinate].smudged
      }
    }
    
    throw "No mirror line found"
  }
  
  private static func firstMirrorLine(
    for grid: Grid<Entry>,
    where predicate: (MirrorLine) -> Bool
  ) -> MirrorLine? {
    if let index = self.firstMirrorLineIndex(
      for: grid.valueRows,
      where: { predicate(.horizontal(index: $0)) }
    ) {
      return .horizontal(index: index)
    } else if let index = self.firstMirrorLineIndex(
      for: grid.valueColumns,
      where: { predicate(.vertical(index: $0)) }
    ) {
      return .vertical(index: index)
    } else {
      return nil
    }
  }
  
  // MARK: Shared
  
  private static func firstMirrorLineIndex(
    for grid: [[Entry]],
    where predicate: (Int) -> Bool
  ) -> Int? {
    let count = grid.count
    for possibleSplitBeforeIndex in 1..<count {
      let size = min(possibleSplitBeforeIndex, count - possibleSplitBeforeIndex)
      let before = grid[possibleSplitBeforeIndex - size..<possibleSplitBeforeIndex]
      let after = grid[possibleSplitBeforeIndex..<possibleSplitBeforeIndex + size].reversed()
      let areEqual = zip(before, after).lazy.allSatisfy { $0 == $1 }
      if areEqual && predicate(possibleSplitBeforeIndex) {
        return possibleSplitBeforeIndex
      }
    }

    return nil
  }
}

extension String: Error {}
