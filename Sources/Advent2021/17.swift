import AdventCommon
import Algorithms

/// https://adventofcode.com/2021/day/17
public struct Day17: AdventDay {

  public static let year = 2021
  public static let day = 17
  public static let answer = AdventAnswer(partOne: 4656, partTwo: 1908)

  public static func solve(input: String) throws -> AdventAnswer {
    let target = Target(xRange: 241...273, yRange: (-97)...(-63))
    
    let validPaths = product(0...target.xRange.upperBound, target.yRange.lowerBound...100).map { v in
      var probe = Probe(v_x: v.0, v_y: v.1)
      return probe.simulate(target: target)
    }
    .filter { $0.1 }
    
    return AdventAnswer(
      partOne: validPaths.map { $0.0.map(\.1).max()! }.max()!,
      partTwo: validPaths.count
    )
  }
}

struct Target {
  let xRange: ClosedRange<Int>
  let yRange: ClosedRange<Int>
}

struct Probe {
  var x: Int = 0
  var y: Int = 0
  var v_x: Int
  var v_y: Int
  
  mutating func step() {
    self.x += self.v_x
    self.y += self.v_y
    self.v_x = max(self.v_x - 1, 0)
    self.v_y -= 1
  }
  
  mutating func simulate(target: Target) -> (steps: [(Int, Int)], hitTarget: Bool) {
    var steps = [(self.x, self.y)]
    while !self.hasAlreadyMissedTarget(target) && !self.isInTarget(target) {
      self.step()
      steps.append((self.x, self.y))
    }
    return (steps, self.isInTarget(target))
  }
  
  func isInTarget(_ target: Target) -> Bool {
    target.xRange.contains(self.x) && target.yRange.contains(self.y)
  }
  
  func hasAlreadyMissedTarget(_ target: Target) -> Bool {
    self.x > target.xRange.upperBound || (self.y < target.yRange.lowerBound && self.v_y <= 0)
  }
}
