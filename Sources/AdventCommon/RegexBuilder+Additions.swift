//
//  RegexBuilder+Additions.swift
//
//
//  Created by Juan Fajardo on 11/30/24.
//

import RegexBuilder

public struct TryCaptureInt: RegexComponent {
  
  private let reference: RegexBuilder.Reference<Int>
  
  public init(as reference: RegexBuilder.Reference<Int>) {
    self.reference = reference
  }
  
  public var regex: Regex<(Substring, Int)> {
    TryCapture(as: self.reference) {
      OneOrMore(.digit)
    } transform: {
      Int($0)
    }
    .regex
  }
}
