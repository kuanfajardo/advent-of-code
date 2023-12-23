//
//  11.swift
//
//
//  Created by Juan Fajardo on 12/22/23.
//

import AdventCommon
import Algorithms

public struct Day11: AdventDay {
  
  public static var year: Int { 2023 }
  
  public static var day: Int { 11 }
  
  enum Space: Character, Equatable, Hashable {
    case galaxy = "#"
    case empty = "."
  }
  
  public static func solve(input: String) throws -> AdventAnswer {
    let rows = input.components(separatedBy: .newlines).map {
      $0.map { Space(rawValue: $0)! }
    }

    let emptyRowIndices: [Int] = rows.enumerated()
      .filter { (index, row) in
        !row.contains(where: { $0 == .galaxy })
      }
      .map(\.offset)

    let columns = invertArray(rows)
    let emptyColumnIndices: [Int] = columns.enumerated()
      .filter { (_, column) in
        !column.contains(where: { $0 == .galaxy })
      }
      .map(\.offset)
    
    let grid = Grid(rows: rows)
    let galaxies = Array(grid).filter { $0.value == .galaxy }
    
    func sumOfShortestDistances(expansionRate: Int) -> Int {
      var sum = 0
      for combo in galaxies.combinations(ofCount: 2) {
        sum += self.shortestDistance(
          from: combo[0].coordinate,
          to: combo[1].coordinate,
          emptyRowIndices: emptyRowIndices,
          emptyColumnIndices: emptyColumnIndices,
          expansionRate: expansionRate
        )
      }
      return sum
    }
    
    return AdventAnswer(
      partOne: sumOfShortestDistances(expansionRate: 2),  // 9_648_398
      partTwo: sumOfShortestDistances(expansionRate: 1_000_000)  // 618_800_410_814
    )
  }

  static func shortestDistance(
    from source: Coordinate,
    to destination: Coordinate,
    emptyRowIndices: [Int],
    emptyColumnIndices: [Int],
    expansionRate: Int
  ) -> Int {
    func computeExpandedDelta(dimension: KeyPath<Coordinate, Int>, emptyIndices: [Int]) -> Int {
      let (min, max) = [destination[keyPath: dimension], source[keyPath: dimension]].minAndMax()!
      let numExpansions = emptyIndices.filter { (min..<max).contains($0) }.count
      let delta = max - min + numExpansions * (expansionRate - 1)
      return delta
    }
    
    let deltaX = computeExpandedDelta(dimension: \.x, emptyIndices: emptyColumnIndices)
    let deltaY = computeExpandedDelta(dimension: \.y, emptyIndices: emptyRowIndices)
    
    let (minDelta, maxDelta) = [deltaX, deltaY].minAndMax()!
    return minDelta * 2 + (maxDelta - minDelta)
  }
}
