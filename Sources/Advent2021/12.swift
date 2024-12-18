import AdventCommon
import Regex

public struct Day12: AdventDay {

  public static let year = 2021
  public static let day = 12
  public static let answer = AdventAnswer(partOne: 5756, partTwo: 144603)

  // MARK: Graph Types

  // Core Type (Vertex)
  struct Cave: RawRepresentable, Hashable {
    enum Size: String, Hashable {
      case small, large
    }

    let rawValue: String
    let size: Size

    init(rawValue: String) {
      self.rawValue = rawValue
      self.size = rawValue.uppercased() == rawValue ? .large : .small
    }

    // MARK: Special Caves

    static let start = Cave(rawValue: "start")
    static let end = Cave(rawValue: "end")
  }

  // Input Type (Edge)
  struct Connection: RegexRepresentable {
    let startCave: Cave
    let endCave: Cave

    static let regex: Regex = #"(?<start>\w+)\-(?<end>\w+)"#

    init(match: Match) {
      self.startCave = Cave(rawValue: match["start"]!)
      self.endCave = Cave(rawValue: match["end"]!)
    }
  }

  typealias CaveNetwork = [Cave: [Cave]]  // "Graph" type
  typealias Path = [Cave]

  public static func solve(input: String) throws -> AdventAnswer {
    let connections = Connection.matches(in: input)
    let caveNetwork: CaveNetwork = connections.reduce(into: [:]) { caveNetwork, connection in
      // Graph is doubly-directed.
      caveNetwork[connection.startCave, default: []] += [connection.endCave]
      caveNetwork[connection.endCave, default: []] += [connection.startCave]
    }

    return AdventAnswer(
      partOne: allPathsFromStartToEnd(in: caveNetwork, visitor: SmallCaveOnlyOnceVisitor.self).count,
      partTwo: allPathsFromStartToEnd(in: caveNetwork, visitor: AtMostOneSmallCaveTwiceVisitor.self).count
    )
  }

  // MARK: Visitors

  // Part 1
  struct SmallCaveOnlyOnceVisitor: Visitor {

    var visited = Bag<Cave>()

    mutating func didVisit(cave: Cave) {
      visited.add(cave)
    }

    func canVisit(cave: Cave) -> Bool {
      switch cave.size {
      case .large: return true
      case .small: return visited[cave] < 1
      }
    }
  }

  // Part 2
  struct AtMostOneSmallCaveTwiceVisitor: Visitor {

    var visited = Bag<Cave>()
    var hasVisitedASmallCaveMoreThanOnce = false

    mutating func didVisit(cave: Cave) {
      visited.add(cave)
      if cave.size == .small &&  visited[cave] > 1 {
        hasVisitedASmallCaveMoreThanOnce = true
      }
    }

    func canVisit(cave: Cave) -> Bool {
      guard cave != .start else { return false }
      if cave == .end { return true }

      switch cave.size {
      case .large: return true
      case .small:
        return hasVisitedASmallCaveMoreThanOnce ? visited[cave] < 1 : visited[cave] < 2
      }
    }
  }

  // MARK: Logic (Dynamic Programming)

  private static func allPathsFromStartToEnd(in caveNetwork: CaveNetwork, visitor: Visitor.Type) -> [Path] {
    func allPathsToEnd(startingFrom cave: Cave, visitor: Visitor) -> [Path] {
      if cave == .end { return [[.end]] }

      var childPathVisitor = visitor
      childPathVisitor.didVisit(cave: cave)

      let possibleNextCaves = caveNetwork[cave, default: []]
        .filter(childPathVisitor.canVisit(cave:))

      return possibleNextCaves.flatMap { nextCave -> [Path] in
        allPathsToEnd(startingFrom: nextCave, visitor: childPathVisitor)
      }.map {
        [cave] + $0
      }
    }

    return allPathsToEnd(startingFrom: .start, visitor: visitor.init())
  }
}

protocol Visitor {
  init()
  mutating func didVisit(cave: Day12.Cave)
  func canVisit(cave: Day12.Cave) -> Bool
}
