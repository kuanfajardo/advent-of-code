//
//  Bag.swift
//
//
//  Created by Juan Fajardo on 11/30/24.
//

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
