import AdventCommon
import Algorithms
import Regex

/// https://adventofcode.com/2022/day/12
public struct Day12: AdventDay {
  
  public static let year = 2022
  public static let day = 12
  
  public static func solve(input: String) throws -> AdventAnswer {
    let rows = input.trimmingCharacters(in: .newlines).components(separatedBy: .newlines).map { row in
      row.map { Space($0) }
    }
    
    let graph = makeGraph(columns: invertArray(rows))
    
    let part1Start = graph.vertices.first { $0.payload == .start }!
    let part2Starts = graph.vertices.filter { $0.payload.elevation == 0 }
    
    return AdventAnswer(
      partOne: findShortestPathLength(in: graph, startingFrom: part1Start)!,  // 361
      partTwo: part2Starts.compactMap { findShortestPathLength(in: graph, startingFrom: $0) }.min()!  // 354
    )
  }
  
  static func makeGraph(columns: [[Space]]) -> Graph<Vertex2DPayload<Space>> {
    let numColumns = columns.count
    let numRows = columns[0].count
    
    func edgesForVertex(_ vertex: Vertex2DPayload<Space>) -> [Graph<Vertex2DPayload<Space>>.Edge] {
      return
      // For each possible deltas between vertices...
      [(-1, 0), (0, -1), (1, 0), (0, 1)]
        // Compute true coordinates of a possible neighbor of `vertex`...
        .map { (dx, dy) in
          (x: vertex.x + dx, y: vertex.y + dy)
        }
        // Discard it if it isn't a valid coordinates in this graph...
        .filter { (x, y) in
          (0..<numColumns).contains(x) && (0..<numRows).contains(y)
        }
        // Create a corresponding vertex object...
        .map { (x, y) in
          Vertex2DPayload(x: x, y: y, payload: columns[x][y])
        }
        // Only a valid neighbor if it's elevation is at most one more than the elevation of `vertex`...
        .filter { possibleNeighbor in
          possibleNeighbor.payload.elevation <= vertex.payload.elevation + 1
        }
        // Create an edge between `vertex` and the valid neighbor.
        .map { neighbor in
          Graph.Edge(start: vertex, end: neighbor, weight: 1)
        }
    }
    
    let edges = product(0..<numColumns, 0..<numRows)
      .flatMap { (x, y) in
        let vertex = Vertex2DPayload<Space>(x: x, y: y, payload: columns[x][y])
        return edgesForVertex(vertex)
      }

    return Graph(edges: edges)
  }
  
  static func findShortestPathLength(in graph: Graph<Vertex2DPayload<Space>>, startingFrom start: Vertex2DPayload<Space>) -> Int? {
    let end = graph.vertices.first { $0.payload == .end }!
    guard let shortestPath = graph.shortestPathDijkstra(from: start, to: end) else { return nil }
    return shortestPath.path.count - 1  // - 1 because there is one less edge than vertices
  }
}

struct Vertex2DPayload<Payload: Hashable>: Hashable {
  let x: Int
  let y: Int
  let payload: Payload
}

enum Space: Hashable {
  case start
  case end
  case step(elevation: Int)
  
  init(_ character: Character) {
    switch character {
    case "S": self = .start
    case "E": self = .end
    default:
      let weight = character.asciiValue! - Character("a").asciiValue!
      self = .step(elevation: Int(weight))
    }
  }
  
  var elevation: Int {
    switch self {
    case .start: return Space("a").elevation
    case .end: return Space("z").elevation
    case .step(let elevation): return elevation
    }
  }
  
  func hash(into hasher: inout Hasher) {
    hasher.combine(self.elevation)
  }
}
