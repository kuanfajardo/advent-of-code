import Algorithms

public struct Coordinate: Hashable, CustomStringConvertible {
  public let x: Int
  public let y: Int
  
  public init(x: Int, y: Int) {
    self.x = x
    self.y = y
  }
  
  public var description: String { "(\(self.x), \(self.y))" }
}

public struct Grid<Element: Hashable>: Sequence, CustomDebugStringConvertible, Equatable, Hashable {
  
  public struct Entry: Hashable {
    public let coordinate: Coordinate
    public let value: Element
    
    init(x: Int, y: Int, value: Element) {
      self.coordinate = Coordinate(x: x, y: y)
      self.value = value
    }
    
    public var x: Int { self.coordinate.x }
    public var y: Int { self.coordinate.y }
  }
  
  var _rows: [[Element]]
  var _columns: [[Element]]

  public init(rows: [[Element]]) {
    self._rows = rows
    self._columns = invertArray(rows)
    self.numRows = rows.count
    self.numColumns = rows[0].count
  }
  
  public init(columns: [[Element]]) {
    self._rows = invertArray(columns)
    self._columns = columns
    self.numRows = columns[0].count
    self.numColumns = columns.count
  }
  
  
  public let numRows: Int
  public let numColumns: Int
  
  public subscript(coordinate: Coordinate) -> Element {
    get { return self._columns[coordinate.x][coordinate.y] }
    set { self[coordinate.x, coordinate.y] = newValue }
  }
  
  public func entry(at coordinate: Coordinate) -> Entry {
    return Entry(x: coordinate.x, y: coordinate.y, value: self[coordinate])
  }
  
  public subscript(x: Int, y: Int) -> Element {
    get { self._columns[x][y] }
    set {
      self._columns[x][y] = newValue
      self._rows[y][x] = newValue
    }
  }

  public var rows: [[Entry]] {
    self._rows.enumerated().map { (y, row) in
      row.enumerated().map { (x, value) in
        Entry(x: x, y: y, value: value)
      }
    }
  }
  
  public var columns: [[Entry]] {
    self._columns.enumerated().map { (x, column) in
      column.enumerated().map { (y, value) in
        Entry(x: x, y: y, value: value)
      }
    }
  }
  
  public var valueRows: [[Element]] { self._rows }
  
  public var valueColumns: [[Element]] { self._columns }
  
  // MARK: Sequence
  
  public func makeIterator() -> Iterator {
    Iterator(numRows: self.numRows, numColumns: self.numColumns, columns: self._columns)
  }
  
  public struct Iterator: IteratorProtocol {
    
    let numRows: Int
    let numColumns: Int
    let columns: [[Element]]
    
    var nextX = 0
    var nextY = 0
    
    public mutating func next() -> Entry? {
      let isXValid = self.nextX < self.numColumns
      let isYValid = self.nextY < self.numRows
      
      guard isXValid && isYValid else { return nil }
      
      let returnValue = Entry(
        x: self.nextX,
        y: self.nextY,
        value: self.columns[self.nextX][self.nextY]
      )

      if self.nextX + 1 < self.numColumns {
        self.nextX += 1
      } else {
        self.nextX = 0
        self.nextY += 1
      }
      
      return returnValue
    }
  }
  
  public var coordinates: [Coordinate] {
    product(0..<self.numColumns, 0..<self.numRows)
      .map(Coordinate.init(x:y:))
  }
  
  // MARK: NESW (Coordinates)
  
  public func top(of coordinate: Coordinate) -> Coordinate? {
    coordinate.y > 0 ? Coordinate(x: coordinate.x, y: coordinate.y - 1) : nil
  }
  
  public func left(of coordinate: Coordinate) -> Coordinate? {
    coordinate.x > 0 ? Coordinate(x: coordinate.x - 1, y: coordinate.y) : nil
  }
  
  public func bottom(of coordinate: Coordinate) -> Coordinate? {
    coordinate.y < self.numRows - 1 ? Coordinate(x: coordinate.x, y: coordinate.y + 1) : nil
  }
  
  public func right(of coordinate: Coordinate) -> Coordinate? {
    coordinate.x < self.numColumns - 1 ? Coordinate(x: coordinate.x + 1, y: coordinate.y) : nil
  }
  
  // MARK: Diagonal
  
  public func topLeft(of coordinate: Coordinate) -> Coordinate? {
    guard let top = self.top(of: coordinate) else { return nil }
    return self.left(of: top)
  }
  
  public func topRight(of coordinate: Coordinate) -> Coordinate? {
    guard let top = self.top(of: coordinate) else { return nil }
    return self.right(of: top)
  }
  
  public func bottomLeft(of coordinate: Coordinate) -> Coordinate? {
    guard let bottom = self.bottom(of: coordinate) else { return nil }
    return self.left(of: bottom)
  }
  
  public func bottomRight(of coordinate: Coordinate) -> Coordinate? {
    guard let bottom = self.bottom(of: coordinate) else { return nil }
    return self.right(of: bottom)
  }
  
  // MARK: Direction-Agnostic
  
  public enum Direction {
    case top, left, bottom, right, topLeft, topRight, bottomLeft, bottomRight
  }
  
  public func coordinate(
    inDirection direction: Direction,
    of coordinate: Coordinate
  ) -> Coordinate? {
    let method: (Coordinate) -> Coordinate? = switch direction {
    case .top: self.top(of:)
    case .bottom: self.bottom(of:)
    case .left: self.left(of:)
    case .right: self.right(of:)
    case .topLeft: self.topLeft(of:)
    case .topRight: self.topRight(of:)
    case .bottomLeft: self.bottomLeft(of:)
    case .bottomRight: self.bottomRight(of:)
    }
    return method(coordinate)
  }
  
  // MARK: Adjacent
  
  public func coordinatesAdjacent(to coordinate: Coordinate, includeDiagonals: Bool) -> [Coordinate] {
    var possibleAdjacents = [
      self.top(of: coordinate),
      self.bottom(of: coordinate),
      self.left(of: coordinate),
      self.right(of: coordinate),
    ]
    
    if includeDiagonals {
      possibleAdjacents.append(contentsOf: [
        self.topLeft(of: coordinate),
        self.topRight(of: coordinate),
        self.bottomLeft(of: coordinate),
        self.bottomRight(of: coordinate),
      ])
    }
    
    return Array(possibleAdjacents.compacted())
  }
  
  // MARK: Shortest Distance
  
  /**
   min = 1, max = 5
   # . . . .
   . . . . .
   . . . . .
   . . . . .
   . # . . .
   . . . . .
   . . . . .
   . . . . .
   
   */
  
  
  public func shortestDistance(from source: Coordinate, to destination: Coordinate) -> Int {
    let deltaX = abs(destination.x - source.x)
    let deltaY = abs(destination.y - source.y)
    
    let (minDelta, maxDelta) = [deltaX, deltaY].minAndMax()!
    return minDelta * 2 + (maxDelta - minDelta)
  }
  
  // MARK: CustomDebugStringConvertible
  
  public var debugDescription: String {
    self._rows.map { row in
      row.map(String.init(describing:)).joined(separator: "")
    }
    .joined(separator: "\n")
  }
  
  // MARK: Equatable
  
  public static func == (lhs: Grid<Element>, rhs: Grid<Element>) -> Bool {
    // Only need to check one storage format.
    return lhs._rows == rhs._rows
  }
  
  // MARK: Hashable
  
  public func hash(into hasher: inout Hasher) {
    hasher.combine(self._rows)
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
