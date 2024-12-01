import AdventCommon
import Algorithms

/// https://adventofcode.com/2022/day/8
public struct Day8: AdventDay {
  
  public static let year = 2022
  public static let day = 8
  
  public static let answer = AdventAnswer(partOne: 1681, partTwo: 201684)
  
  struct Coordinate: Hashable, CustomStringConvertible {
    let x: Int
    let y: Int
    
    var description: String { "(\(self.x), \(self.y))" }
  }
  
  public static func solve(input: String) throws -> AdventAnswer {
    let temp =
    """
    30373
    25512
    65332
    33549
    35390
    """
    
    let rows = temp.components(separatedBy: .newlines).filter { !$0.isEmpty }.map { $0.map(String.init).compactMap(Int.init) }
    let grid = Grid(rows: rows)
    
    var visibility = [Grid<Int>.Entry: Bool]()
    
    outer: for entry in grid {
      if entry.x == 0 || entry.y == 0 || entry.x == grid.numColumns - 1 || entry.y == grid.numRows - 1 {
        visibility[entry] = true
        continue
      }

      print("NEw\(entry)")
      var coordinate = Coordinate(x: entry.x, y: entry.y)
      while let top = grid.top(of: coordinate) {
        print("t\(top)")
        if entry.value <= grid[top] { break }
        if top.y == 0 {
          visibility[entry] = true
          continue outer
        }
        coordinate = top
      }
      
      coordinate = Coordinate(x: entry.x, y: entry.y)
      while let top = grid.left(of: coordinate) {
        print("l\(top)")
        if entry.value <= grid[top] { break }
        if top.x == 0 {
          visibility[entry] = true
          continue outer
        }
        coordinate = top
      }
      
      coordinate = Coordinate(x: entry.x, y: entry.y)
      while let top = grid.bottom(of: coordinate) {
        print("b\(top)")
        if entry.value <= grid[top] { break }
        if top.x == grid.numColumns - 1 {
          visibility[entry] = true
          continue outer
        }
        coordinate = top
      }
      
      coordinate = Coordinate(x: entry.x, y: entry.y)
      while let top = grid.right(of: coordinate) {
        print("e\(top)")
        if entry.value <= grid[top] { break }
        if top.y == grid.numRows - 1 {
          visibility[entry] = true
          continue outer
        }
        coordinate = top
      }
    }
    
    print(visibility)
    /*
    
    for row in grid.rows {
      var leftTreeLine = -1
      for entry in row {
        if entry.value > leftTreeLine {
          leftTreeLine = entry.value
          visibility[entry] = true
        }
      }
      
      var rightTreeLine = -1
      for entry in row.reversed() {
        if entry.value > rightTreeLine {
          rightTreeLine = entry.value
          visibility[entry] = true
        }
      }
    }
    
    for column in grid.columns {
      var topTreeLine = -1
      for entry in column {
        if entry.value > topTreeLine {
          topTreeLine = entry.value
          visibility[entry] = true
        }
      }
      
      var bottomTreeLine = -1
      for entry in column.reversed() {
        if entry.value > bottomTreeLine {
          bottomTreeLine = entry.value
          visibility[entry] = true
        }
      }
    }*/
    
    // Part 2:
    
    let visibilities: [Int] = grid.map {
      let coordinate = Coordinate(x: $0.x, y: $0.y)
      let height = $0.value
      
      func visibility(step: (Coordinate) -> Coordinate?) -> Int {
        var coordinate = coordinate
        var visibility = 0
        while let next = step(coordinate) {
          visibility += 1
          coordinate = next
          if height <= grid[next] { break }
        }
        return visibility
      }
        
      return visibility(step: grid.top(of:))
        * visibility(step: grid.left(of:))
        * visibility(step: grid.bottom(of:))
        * visibility(step: grid.right(of:))
    }
    
    return AdventAnswer(
      partOne: visibility.filter { $0.value }.count,
      partTwo: visibilities.max()!
    )
  }
  
  struct Grid<Element: Hashable>: Sequence {
    
    struct Entry: Hashable {
      let x: Int
      let y: Int
      let value: Element
    }
    
    let _rows: [[Element]]
    let _columns: [[Element]]
    
    init(rows: [[Element]]) {
      self._rows = rows
      self._columns = invertArray(rows)
      self.numRows = rows.count
      self.numColumns = rows[0].count
    }
    
    let numRows: Int
    let numColumns: Int
    
    subscript(coordinate: Coordinate) -> Element {
      return self._columns[coordinate.x][coordinate.y]
    }
    
    var rows: [[Entry]] {
      self._rows.enumerated().map { (y, row) in
        row.enumerated().map { (x, value) in
          Entry(x: x, y: y, value: value)
        }
      }
    }
    
    var columns: [[Entry]] {
      self._columns.enumerated().map { (x, column) in
        column.enumerated().map { (y, value) in
          Entry(x: x, y: y, value: value)
        }
      }
    }
    
    func makeIterator() -> IndexingIterator<[Entry]> {
      product(0..<self.numColumns, 0..<self.numRows)
        .map { (x, y) in Entry(x: x, y: y, value: self._columns[x][y]) }
        .makeIterator()
    }
    
    func top(of coordinate: Coordinate) -> Coordinate? {
      coordinate.y > 0 ? Coordinate(x: coordinate.x, y: coordinate.y - 1) : nil
    }
    
    func left(of coordinate: Coordinate) -> Coordinate? {
      coordinate.x > 0 ? Coordinate(x: coordinate.x - 1, y: coordinate.y) : nil
    }
    
    func bottom(of coordinate: Coordinate) -> Coordinate? {
      coordinate.y < self.numRows - 1 ? Coordinate(x: coordinate.x, y: coordinate.y + 1) : nil
    }
    
    func right(of coordinate: Coordinate) -> Coordinate? {
      coordinate.x < self.numColumns - 1 ? Coordinate(x: coordinate.x + 1, y: coordinate.y) : nil
    }
  }
}

public func invertArray<S>(_ array: [[S]]) -> [[S]] {
  let numRows = array.count
  let numColumns = array[0].count
  var inverted = Array<Array<S?>>.init(repeating: Array(repeating: nil, count: numRows), count: numColumns)
  
  product(0..<numRows, 0..<numColumns).forEach {(i, j) in
    inverted[j][i] = array[i][j]
  }
  
  return inverted.map { row in row.map { $0! } }
}
