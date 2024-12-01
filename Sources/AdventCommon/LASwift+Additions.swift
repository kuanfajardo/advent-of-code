//
//  LASwift+Additions.swift
//  
//
//  Created by Juan Fajardo on 11/30/24.
//

import LASwift

extension Matrix {

  public convenience init(_ data: [Int]) {
    self.init(data.map { Double($0) })
  }
}
