import Foundation
import LASwift

// MARK: Advent Types

public protocol AdventDay {
  static var day: Int { get }
  static func run(input: String) throws -> Any
}

public enum AdventError: Error {
  case noSolutionFound
  case malformedInput
}

// MARK: Extensions

extension String {

  // MARK: Integer Indexing

  public subscript(offset: Int) -> Element {
    self[self.index(self.startIndex, offsetBy: offset)]
  }

  public subscript(bounds: CountableClosedRange<Int>) -> String {
    let start = index(startIndex, offsetBy: bounds.lowerBound)
    let end = index(start, offsetBy: bounds.count)
    return String(self[start...end])
  }

  public subscript(bounds: CountableRange<Int>) -> String {
    let start = index(startIndex, offsetBy: bounds.lowerBound)
    let end = index(start, offsetBy: bounds.count - 1)
    return String(self[start..<end])
  }
}

extension Int {

  public func raisedTo(power: Int) -> Int {
    Int(pow(Double(self), Double(power)))
  }

  public var mostSignificantBit: Int {
    Int(flsl(self))
  }
}

public struct Bag<Element: Hashable> {
  private var storage: [Element: Int]

  public init<S: Sequence>(_ sequence: S) where S.Element == Element {
    self.storage = [Element: [Element]](grouping: sequence) { $0 }.mapValues(\.count)
  }

  mutating func add(_ element: Element) {
    storage[element] = storage[element, default: 0] + 1
  }

  public subscript(_ element: Element) -> Int {
    storage[element, default: 0]
  }
}

extension Matrix {

  public convenience init(_ data: [Int]) {
    self.init(data.map { Double($0) })
  }
}
