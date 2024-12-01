//
//  AnyEquatable.swift
//
//
//  Created by Juan Fajardo on 11/30/24.
//

public struct AnyEquatable: Equatable, CustomStringConvertible {

  private let base: Any

  private let comparitor: (Any) -> Bool
  
  // MARK: Initialization

  public init<T: Equatable>(_ base: T) {
    self.base = base
    self.comparitor = { ($0 as? T) == base }
  }
  
  // MARK: CustomStringConvertible
  
  public var description: String { String(describing: self.base) }
  
  // MARK: Equatable
  
  public static func == (lhs: AnyEquatable, rhs: AnyEquatable) -> Bool {
    return lhs.comparitor(rhs.base) && rhs.comparitor(lhs.base)
  }
}
