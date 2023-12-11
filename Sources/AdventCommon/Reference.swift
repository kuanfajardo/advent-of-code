//
//  Reference.swift
//
//
//  Created by Juan Fajardo on 12/10/23.
//

public class Reference<T>: Hashable {

  public let value: T
  
  public init(_ value: T) {
    self.value = value
  }
  
  public static func == (lhs: Reference<T>, rhs: Reference<T>) -> Bool {
    lhs === rhs
  }
  
  public func hash(into hasher: inout Hasher) {
    hasher.combine(ObjectIdentifier(self))
  }
}
