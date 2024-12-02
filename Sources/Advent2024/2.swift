//
//  AdventDay.swift
//  
//
//  Created by Juan Fajardo on 12/1/24.
//

import AdventCommon
import Algorithms

public struct Day2: AdventDay {
  
  public static let year = 2024
  public static let day = 2
  public static let answer = AdventAnswer(partOne: 252, partTwo: 324)
  
  static let temp =
    """
    7 6 4 2 1
    1 2 7 8 9
    9 7 6 2 1
    1 3 2 4 5
    8 6 4 4 1
    1 3 6 7 9
    """
  
  public static func solve(input: String) -> AdventAnswer {
    let reports = input.components(separatedBy: .newlines).map { row in
      row.matches(of: /\d+/).map { Int(String($0.output))! }
    }

    return .init(
      partOne: reports.filter(self.isReportSafe).count,
      partTwo: reports.filter(self.isReportSafeWithOneRemoval).count
    )
  }
  
  private static func isReportSafe(_ report: [Int]) -> Bool {
    let differences = report.adjacentPairs().map { $0.1 - $0.0 }
    let sign = differences.first!.sign
    return differences.allSatisfy {
      $0.sign == sign && (1...3).contains(abs($0))
    }
  }
  
  private static func isReportSafeWithOneRemoval(_ report: [Int]) -> Bool {
    if self.isReportSafe(report) { return true }
    for index in 0..<report.count {
      var newReport = report
      newReport.remove(at: index)
      if self.isReportSafe(newReport) { return true }
    }
    return false
  }
}
