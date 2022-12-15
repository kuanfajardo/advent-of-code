import AdventCommon
import Algorithms
import Regex

/// https://adventofcode.com/2022/day/9
public struct Day9: AdventDay {

  public static let year = 2022
  public static let day = 9

  public static func solve(input: String) throws -> AdventAnswer {
    let moves = input.components(separatedBy: .newlines).compactMap { Instruction.firstMatch(in: $0) }

    return AdventAnswer(
      partOne: self.numberOfPositionsTailVisits(inRopeOfLength: 2, headMoves: moves),  // 6339
      partTwo: self.numberOfPositionsTailVisits(inRopeOfLength: 10, headMoves: moves)  // 2541
    )
  }
  
  static func numberOfPositionsTailVisits(inRopeOfLength numberOfKnots: Int, headMoves: [Instruction]) -> Int {
    let rope = Rope(numberOfKnots: numberOfKnots)
    
    for move in headMoves {
      for _ in 0..<move.amount {
        let deltaX: Int
        let deltaY: Int
        switch move.direction {
        case .up:
          deltaX = 0
          deltaY = 1
        case .down:
          deltaX = 0
          deltaY = -1
        case .left:
          deltaX = -1
          deltaY = 0
        case .right:
          deltaX = 1
          deltaY = 0
        }

        rope.head.move(deltaX: deltaX, deltaY: deltaY)
      }
    }
    
    return rope.tail.visited.count
  }
  
  // MARK: Abstractions
  
  class Rope {
    let head: Knot
    let tail: Knot
    
    init(numberOfKnots: Int) {
      let tail = Knot(position: .zero, tail: nil)
      
      var previous = tail
      for _ in 1..<numberOfKnots {
        let knot = Knot(position: .zero, tail: previous)
        previous = knot
      }
      
      self.head = previous
      self.tail = tail
    }
  }
  
  class Knot {
    var position: Position
    let tail: Knot?
    var visited: Set<Position>
    
    init(position: Position, tail: Knot?) {
      self.position = position
      self.tail = tail
      self.visited = [position]
    }
    
    func move(deltaX: Int, deltaY: Int) {
      self.position.move(deltaX: deltaX, deltaY: deltaY)
      self.visited.insert(self.position)
      self.moveTailToHead()
    }
    
    func moveTailToHead() {
      guard let tail else { return }
      guard !self.position.isAdjacent(to: tail.position) else { return }
      
      let deltaX: Int
      if self.position.x > tail.position.x {
        deltaX = 1
      } else if self.position.x < tail.position.x {
        deltaX = -1
      } else { // ==
        deltaX = 0
      }
      
      let deltaY: Int
      if self.position.y > tail.position.y {
        deltaY = 1
      } else if self.position.y < tail.position.y {
        deltaY = -1
      } else { // ==
        deltaY = 0
      }
            
      tail.move(deltaX: deltaX, deltaY: deltaY)
    }
  }
    
  struct Position: Hashable {
    static let zero = Position(x: 0, y: 0)

    var x: Int
    var y: Int
    
    mutating func move(deltaX: Int, deltaY: Int) {
      self.x += deltaX
      self.y += deltaY
    }
    
    func isAdjacent(to other: Position) -> Bool {
      abs(self.x - other.x) <= 1 && abs(self.y - other.y) <= 1
    }
  }
  
  // MARK: Input
  
  struct Instruction: RegexRepresentable {

    static let regex: Regex = #"(?<direction>\w)\s(?<amount>\d+)"#
    
    enum Direction: String, ExpressibleByCaptureGroup {
      case up = "U"
      case down = "D"
      case left = "L"
      case right = "R"
    }
    
    let direction: Direction
    let amount: Int
    
    init?(match: Match) {
      self.direction = try! match.captureGroup(named: "direction", as: Direction.self)
      self.amount = try! match.captureGroup(named: "amount", as: Int.self)
    }
  }
}
