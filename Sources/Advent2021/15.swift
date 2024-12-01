import AdventCommon
import Algorithms
import Numerics
import DequeModule

public struct Day15: AdventDay {

  public static let year = 2021
  public static let day = 15

  public static func solve(input: String) throws -> AdventAnswer {
    // Part 1 Input
    let risks = input.trimmingCharacters(in: .newlines).components(separatedBy: .newlines).map {
      $0.map { Int($0)! }
    }

    // Part 2 Input
    let size = risks.count
    var part2Risks = [[Int]](repeating: [Int](repeating: 0, count: size * 5), count: size * 5)
    product(0..<size * 5, 0..<size * 5).forEach { i, j in
      let xOffset = i / size
      let yOffset = j / size
      let originalWeight = risks[i % size][j % size]
      let newWeight = originalWeight + xOffset + yOffset
      part2Risks[i][j] = ((newWeight - 1) % 9) + 1  // Wrap to number between 1-9
    }
        
    return AdventAnswer(
      partOne: findSmallestRisk(risks: risks),  // 458
      partTwo: findSmallestRisk(risks: part2Risks) // 2800
    )
  }
  
  static func findSmallestRisk(risks: [[Int]]) -> Weight {
    let size = risks.count
    let edges = product(0..<size, 0..<size)
      .flatMap { (x, y) in
        let vertex = Vertex2D(x: x, y: y)
        return [
          (-1, 0), (0, -1), (1, 0), (0, 1)
        ].map { (dx, dy) in
          Vertex2D(x: vertex.x + dx, y: vertex.y + dy)
        }.filter {
          (0..<size).contains($0.x) && (0..<size).contains($0.y)
        }.map {
          Graph.Edge(start: vertex, end: $0, weight: risks[$0.x][$0.y])
        }
      }

    let graph = Graph(edges: edges)

    return graph.shortestPathDijkstra(
      from: Vertex2D(x: 0, y: 0),
      to: Vertex2D(x: size - 1, y: size - 1)
    )!.cost
  }
}

