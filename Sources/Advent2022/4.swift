import AdventCommon
import Algorithms
import Regex

/// https://adventofcode.com/2022/day/4
public struct Day4: AdventDay {

  public static let year = 2022
  public static let day = 4
  
  struct Assignment: RegexRepresentable {
    static let regex: Regex = #"(?<group1start>\d+)-(?<group1end>\d+),(?<group2start>\d+)-(?<group2end>\d+)"#
    
    let group1: ClosedRange<Int>
    let group2: ClosedRange<Int>
    
    init?(match: Match) {
      self.group1 = try! match.captureGroup(named: "group1start", as: Int.self)...match.captureGroup(named: "group1end", as: Int.self)
      self.group2 = try! match.captureGroup(named: "group2start", as: Int.self)...match.captureGroup(named: "group2end", as: Int.self)
    }
  }

  public static func solve(input: String) throws -> AdventAnswer {
    let assignments = Assignment.matches(in: input)
    
    return AdventAnswer(
      partOne: assignments.filter { $0.group1.completelyOverlaps($0.group2) }.count,  // 431
      partTwo: assignments.filter { $0.group1.overlaps($0.group2) }.count  // 823
    )
  }
}

extension ClosedRange where Bound: Hashable & Strideable, Bound.Stride: SignedInteger {
  func completelyOverlaps(_ other: Self) -> Bool {
    let set1 = Set(self)
    let set2 = Set(other)
    return set1.isSuperset(of: set2) || set2.isSuperset(of: set1)
  }
}
