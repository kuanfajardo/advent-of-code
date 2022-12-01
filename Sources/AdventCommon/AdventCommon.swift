import Foundation
import LASwift
import Regex

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

public struct Bag<E: Hashable>: ExpressibleByArrayLiteral {
  public typealias Storage = [E: Int]

  private var storage: Storage

  public init<S: Sequence>(_ sequence: S) where S.Element == E {
    self.storage = [E: [S.Element]](grouping: sequence) { $0 }.mapValues(\.count)
  }

  public init() {
    self.storage = [:]
  }

  public init(arrayLiteral elements: E...) {
    self.init(elements)
  }

  public mutating func add(_ element: E, count: Int = 1) {
    storage[element] = storage[element, default: 0] + count
  }

  public subscript(_ element: E) -> Int {
    storage[element, default: 0]
  }

  public func adding(_ element: E) -> Self {
    var bag = self
    bag.add(element)
    return bag
  }

  public var counts: Storage.Values { storage.values }
}

extension Bag: Sequence {
  public func makeIterator() -> Storage.Iterator {
    storage.makeIterator()
  }
}

extension Bag: Collection {
  public var endIndex: Storage.Index {
    storage.endIndex
  }

  public var startIndex: Storage.Index {
    storage.startIndex
  }

  public subscript(index: Storage.Index) -> Storage.Element {
    storage[index]
  }

  public func index(after i: Storage.Index) -> Storage.Index {
    storage.index(after: i)
  }
}

extension Bag: CustomStringConvertible {
  public var description: String { String(describing: storage) }
}

extension Bag: ExpressibleByDictionaryLiteral {

  public init(dictionaryLiteral elements: (E, Int)...) {
    self.storage = .init(uniqueKeysWithValues: elements)
  }
}

extension Matrix {

  public convenience init(_ data: [Int]) {
    self.init(data.map { Double($0) })
  }
}

public enum MatchError: Error {
  case missingCaptureGroup(String)
  case badRawValue(String)
}

extension Match {
  /// Retrieves the match for a named capture group.
  ///
  /// - Parameter name: The name of the capture group to return.
  /// - Returns: The string matching the capture group named `name`.
  /// - Throws: If the capture group doesn't exist.
  public func captureGroup(named name: String) throws -> String {
    guard let value = self[name] else {
      throw MatchError.missingCaptureGroup(name)
    }
    return value
  }

  ///
  public func captureGroup<T: ExpressibleByCaptureGroup>(named name: String, as: T.Type) throws -> T {
    let rawValue = try self.captureGroup(named: name)
    guard let value = T.init(captureGroup: rawValue) else { throw MatchError.badRawValue(rawValue) }
    return value
  }
}
