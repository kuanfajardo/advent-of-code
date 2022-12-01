import AdventCommon
import Algorithms
import Numerics
import DequeModule

public struct Day15: AdventDay {

  public static let day = 15

  struct Vertex: Hashable {
    let x: Int
    let y: Int
  }

  public static func run(input: String) throws -> Any {
    let temp =
    """
    1163751742
    1381373672
    2136511328
    3694931569
    7463417111
    1319128137
    1359912421
    3125421639
    1293138521
    2311944581
    """

    let weights = input.components(separatedBy: .newlines).map {
      $0.map { Int($0)! }
    }

    let numRows = weights.count
    let numColumns = weights.first!.count

    let start = Vertex(x: 0, y: 0)
    let end = Vertex(x: numColumns - 1, y: numRows - 1)

    let vertices = product(0..<numColumns, 0..<numRows).map { Vertex(x: $0, y: $1) }

    var unvisited = Set(vertices)
    var distances: [Vertex: Int] = vertices.reduce(into: [:]) { $0[$1] = .max }
    var previous: [Vertex: Vertex] = vertices.reduce(into: [:]) { $0[$1] = nil }


    distances[start] = 0

    func neighbors(of vertex: Vertex) -> [Vertex] {
      let deltas: [(Int, Int)] = [
        (-1, 0), (1, 0), (0, -1), (0, 1)
      ]
      return deltas.map { (dx, dy) in
        Vertex(x: vertex.x + dx, y: vertex.y + dy)
      }
    }

//    var min

    while !unvisited.isEmpty {
      let u = distances
        .sorted { $0.value < $1.value }
        .first { unvisited.contains($0.key) }!
        .key

      unvisited.remove(u)

      if u == end {
        break
      }

      unvisited.intersection(neighbors(of: u)).forEach { v in
        let alt = distances[u]! + weights[v.y][v.x]
        if alt < distances[v]! {
          distances[v] = alt
          previous[v] = u
        }
      }
    }

    var risk = 0
    var u: Vertex? = end

    while true {
      guard let unwrapped = u else { break }
      risk += weights[unwrapped.y][unwrapped.x]
      u = previous[unwrapped]
    }

    risk -= weights[start.y][start.x]

    return (
      partOne: risk,
      partTwo: 0
    )
  }
}
