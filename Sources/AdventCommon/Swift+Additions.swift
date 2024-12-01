//
//  File.swift
//  
//
//  Created by Juan Fajardo on 11/30/24.
//

import Foundation

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

