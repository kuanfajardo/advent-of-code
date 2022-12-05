
public struct BinaryHeap<Element: Hashable, Key: Comparable>: CustomStringConvertible {
  
  private struct Node {
    let element: Element
    var key: Key
  }
  
  private let compare: (Key, Key) -> Bool
  
  private var storage = [Node]()
  
  private var indexMap = [Element: Int]()
  
  /// - Complexity: O(1)
  public init(compare: @escaping (Key, Key) -> Bool) {
    self.compare = compare
  }
  
  // MARK: Public
  
  /// - Complexity: O(1)
  public var count: Int { self.storage.count }
  
  /// - Complexity: O(1)
  public var isEmpty: Bool { self.storage.isEmpty }
  
  /// - Complexity: O(log n)
  public mutating func insert(_ newElement: Element, key: Key) {
    self.append(newElement, key: key)
    self.upHeapify(index: self.count - 1)
  }
  
  /// - Complexity: O(log n)
  public mutating func extract() -> Element? {
    guard !self.isEmpty else { return nil }
    
    if self.count == 1 {
      return self.removeLast()
    } else {
      self.swapAt(0, self.count - 1)
      let value = self.removeLast()
      self.downHeapify(index: 0)
      return value
    }
  }
  
  /// - Complexity: O(1)
  public func peek() -> Element? {
    self.storage.first?.element
  }
  
  /// - Complexity: O(log n)
  public mutating func insertAndExtract(_ newElement: Element, key: Key) -> Element? {
    guard let first = self.storage.first else { return newElement }
    if self.compare(key, first.key) {
      return newElement
    } else {
      self.replaceElement(atIndex: 0, with: newElement, key: key)
      self.downHeapify(index: 0)
      return first.element
    }
  }
  
  /// - Complexity: O(log n)
  @discardableResult
  public mutating func updateKey(of element: Element, to newKey: Key) -> Bool {
    guard let index = self.indexMap[element] else { return false }
    self.storage[index].key = newKey
    self.upOrDownHeapify(index: index)
    return true
  }
  
  // MARK: Comparison
  
  /// - Complexity: O(1)
  private func compareAtIndices(_ lhs: Int, _ rhs: Int) -> Bool {
    self.compare(self.storage[lhs].key, self.storage[rhs].key)
  }
  
  // MARK: Indices
  
  /// - Complexity: O(1)
  private func parentIndex(of index: Int) -> Int {
    return (index - 1) / 2
  }
  
  /// - Complexity: O(1)
  private func leftChildIndex(of index: Int) -> Int? {
    let leftChildIndex = 2 * index + 1
    guard leftChildIndex < self.count else { return nil }
    return leftChildIndex
  }
  
  /// - Complexity: O(1)
  private func rightChildIndex(of index: Int) -> Int? {
    let rightChildIndex = 2 * index + 2
    guard rightChildIndex < self.count else { return nil }
    return rightChildIndex
  }
  
  // MARK: Heapify
  
  /// - Complexity: O(log n)
  private mutating func downHeapify(index: Int) {
    var first = index
    if let leftChildIndex = self.leftChildIndex(of: index), self.compareAtIndices(leftChildIndex, first) {
      first = leftChildIndex
    }
    if let rightChildIndex = self.rightChildIndex(of: index), self.compareAtIndices(rightChildIndex, first) {
      first = rightChildIndex
    }
    if first == index { return }
    
    self.swapAt(index, first)
    self.downHeapify(index: first)
  }
  
  /// - Complexity: O(log n)
  private mutating func upHeapify(index: Int) {
    // If already at root, return.
    guard index > 0 else { return }
    
    let parentIndex = self.parentIndex(of: index)
    if self.compareAtIndices(index, parentIndex) {
      self.swapAt(parentIndex, index)
      self.upHeapify(index: parentIndex)
    }
  }
  
  /// - Complexity: O(log n)
  private mutating func upOrDownHeapify(index: Int) {
    let parentIndex = self.parentIndex(of: index)
    if self.compareAtIndices(index, parentIndex) {
      self.upHeapify(index: index)
    } else {
      self.downHeapify(index: index)
    }
  }
  
  // MARK: Storage
  
  private mutating func swapAt(_ i: Int, _ j: Int) {
    let element_i = self.storage[i].element
    let element_j = self.storage[j].element
    
    self.storage.swapAt(i, j)
    self.indexMap[element_i] = j
    self.indexMap[element_j] = i
  }
  
  private mutating func removeLast() -> Element {
    let removed = self.storage.removeLast()
    self.indexMap.removeValue(forKey: removed.element)
    return removed.element
  }
  
  private mutating func append(_ newElement: Element, key: Key) {
    let node = Node(element: newElement, key: key)
    self.storage.append(node)
    self.indexMap[newElement] = self.storage.count - 1
  }
  
  private mutating func replaceElement(atIndex index: Int, with newElement: Element, key: Key) {
    let existing = self.storage[index]
    self.storage[index] = Node(element: newElement, key: key)
    self.indexMap[newElement] = index
    self.indexMap.removeValue(forKey: existing.element)
  }
  
  // MARK: Display
  
  public var description: String {
    String(describing: self.storage)
  }
}

