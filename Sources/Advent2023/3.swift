//
//  3.swift
//
//
//  Created by Juan Fajardo on 12/10/23.
//

import AdventCommon

public struct Day3: AdventDay {
  
  public static let year = 2023
  
  public static let day = 3
  
  public static let answer = AdventAnswer(partOne: 556_057, partTwo: 82_824_352)
  
  typealias Number = Reference<Int>
  typealias Symbol = Reference<Character>
  
  enum GridElement: Hashable {
    case number(Reference<Int>)
    case symbol(Reference<Character>)
    case none
    
    static func number(_ value: Int) -> GridElement {
      .number(Reference(value))
    }
    
    static func symbol(_ value: Character) -> GridElement {
      .symbol(Reference(value))
    }
  }
  
  public static func solve(input: String) throws -> AdventAnswer {
    let rows: [[GridElement]] = input.components(separatedBy: .newlines).map { row in
      row.chunked {
        $0.isNumber && $1.isNumber
      }
      .flatMap {
        if let number = Int($0) {
          return [GridElement](
            repeating: .number(number),
            count: $0.count
          )
        } else if $0 == "." {
          return [.none]
        } else {
          return [.symbol($0.first!)]
        }
      }
    }
    
    let grid = Grid<GridElement>(rows: rows)

    let symbolsWithCoordinates: [(Symbol, Coordinate)] = grid.compactMap {
      guard case .symbol(let symbol) = $0.value else { return nil }
      return (symbol, $0.coordinate)
    }
    
    let _symbolsWithAdjacentNumbers = symbolsWithCoordinates.map { (symbol, coordinate) in
      let adjacentCoordinates = grid.coordinatesAdjacent(
        to: coordinate,
        includeDiagonals: true
      )
      
      let adjacentNumbers: [Number] = adjacentCoordinates.compactMap {
        guard case .number(let number) = grid[$0] else { return nil }
        return number
      }
  
      return (symbol, Set(adjacentNumbers))
    }
    
    let symbolsWithAdjacentNumbers =
      [Symbol: Set<Number>](uniqueKeysWithValues: _symbolsWithAdjacentNumbers)
    
    let partNumbers = symbolsWithAdjacentNumbers
      .map(\.value)
      .reduce(into: Set<Number>()) { $0.formUnion($1) }
    
    let gears = symbolsWithAdjacentNumbers
      .filter { $0.key.value == "*" }
      .filter { $0.value.count == 2 }
      
    
    return AdventAnswer(
      partOne: partNumbers
        .map(\.value)
        .reduce(0, +),
      partTwo: gears
        .map { Array($0.value) }
        .map { $0[0].value * $0[1].value }
        .reduce(0, +)
    )
  }
}
