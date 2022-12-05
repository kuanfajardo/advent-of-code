import Algorithms

public struct Graph<Vertex: Hashable> {
  
  public struct Edge: Hashable {
    public let start: Vertex
    public let end: Vertex
    public let weight: Int
    
    public init(start: Vertex, end: Vertex, weight: Int) {
      self.start = start
      self.end = end
      self.weight = weight
    }
  }
  
  public let edges: Set<Edge>
  
  public let vertices: Set<Vertex>
  
  private let edgeMap: [Vertex: [Vertex: Edge]]
  
  public init<S>(edges: S) where S: Sequence, S.Element == Edge {
    self.edges = Set(edges)
    
    self.vertices = edges.reduce(into: []) { partialResult, edge in
      partialResult.insert(edge.start)
      partialResult.insert(edge.end)
    }
  
    self.edgeMap = edges.reduce(into: [:]) { partialResult, edge in
      if partialResult[edge.start] == nil {
        partialResult[edge.start] = [edge.end: edge]
      } else {
        partialResult[edge.start]?[edge.end] = edge
      }
    }
  }
  
  // MARK: Public
  
  public func edge(from start: Vertex, to end: Vertex) -> Edge? {
    self.edgeMap[start]?[end]
  }
  
  public func neighbors(of vertex: Vertex) -> [Vertex: Edge] {
    self.edgeMap[vertex, default: [:]]
  }
}

/// A 2-dimensional graph vertex.
public struct Vertex2D: Hashable, CustomStringConvertible {
  public let x: Int
  public let y: Int

  public init(x: Int, y: Int) {
    self.x = x
    self.y = y
  }
  
  public var description: String {
    "(\(self.x), \(self.y))"
  }
}


// MARK: Searching Helpers

public func + (lhs: Weight, rhs: Int) -> Weight {
  switch lhs {
  case .concrete(let weight): return .concrete(weight + rhs)
  case .infinity: return .infinity
  }
}

public enum Weight: Comparable, ExpressibleByIntegerLiteral, CustomStringConvertible {
  case concrete(Int)
  case infinity
  
  public init(integerLiteral value: Int) {
    self = .concrete(value)
  }
  
  public static func < (lhs: Weight, rhs: Weight) -> Bool {
    switch (lhs, rhs) {
    case (.concrete, .infinity): return true
    case (.infinity, .concrete): return false
    case (.concrete(let _lhs), .concrete(let _rhs)): return _lhs < _rhs
    case (.infinity, .infinity): return false
    }
  }
  
  public var description: String {
    switch self {
    case .infinity: return "INF"
    case .concrete(let weight): return "\(weight)"
    }
  }
}

public struct DistanceMap<Vertex: Hashable> {

  private var distances = [Vertex: Weight]()
  
  public init() { }
  
  public subscript(key: Vertex) -> Weight {
    get { distances[key, default: .infinity] }
    set { distances[key] = newValue }
  }
}

// MARK: Searching Algorithms

extension Graph {
  
  public func shortestPathDijkstra(from source: Vertex, to destination: Vertex) -> Weight {
    var distances = DistanceMap<Vertex>()
    self.vertices.forEach {
      distances[$0] = .infinity
    }
    distances[source] = 0
    
    var queue = BinaryHeap<Vertex, Weight>(compare: <)
    for vertex in self.vertices {
      queue.insert(vertex, key: distances[vertex])
    }
            
    while let u = queue.extract(), u != destination {
      for (neighbor, edge) in self.neighbors(of: u) {
        let newDistance = distances[u] + edge.weight
        if newDistance < distances[neighbor] {
          distances[neighbor] = newDistance
          queue.updateKey(of: neighbor, to: newDistance)
        }
      }
    }
    
    return distances[destination]
  }
}
