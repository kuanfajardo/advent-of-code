//
//  12.swift
//
//
//  Created by Juan Fajardo on 12/23/23.
//

import AdventCommon
import RegexBuilder

public struct Day12: AdventDay {
  
  public static var year: Int { 2023 }
  
  public static var day: Int { 12 }
  
  public static let temp =
    """
    ???.### 1,1,3
    .??..??...?##. 1,1,3
    ?#?#?#?#?#?#?#? 1,3,1,6
    ????.#...#... 4,1,1
    ????.######..#####. 1,6,5
    ?###???????? 3,2,1
    """
  
  public static func solve(input: String) throws -> AdventAnswer {
    let records = try input.components(separatedBy: .newlines).map(self.makeConditionRecord(raw:))
    let counts = records.map { self.numberOfPossibleSolutions(entries: $0.entries, damagedCounts: $0.damagedCounts) }

    return AdventAnswer(
      partOne: counts.map(\.count).reduce(0, +),  // 7169
      partTwo: 3
    )
  }
  
  struct ConditionRecord: Hashable {
    enum Entry: Character, CustomStringConvertible {
      case unknown = "?"
      case operational = "."
      case damaged = "#"
      
      var description: String { String(self.rawValue) }
    }

    let entries: [Entry]
    let damagedCounts: [Int]
    
  }
  
  static func makeConditionRecord(raw: String) throws -> ConditionRecord {
    let entriesRef = Reference(String.self)
    let countsRef = Reference(String.self)

    let regex = Regex {
      TryCapture(as: entriesRef) {
        OneOrMore(/[\.\?#]/)
      } transform: {
        String($0)
      }
      " "
      TryCapture(as: countsRef) {
        OneOrMore(/[\d,]/)
      } transform: {
        String($0)
      }
    }
    
    guard let match = try regex.wholeMatch(in: raw) else {
      throw AdventError.malformedInput(input: raw)
    }
    
    let entries = match[entriesRef].compactMap(ConditionRecord.Entry.init(rawValue:))
    let counts = match[countsRef].components(separatedBy: ",").compactMap(Int.init)
    return ConditionRecord(
      entries: entries,
      damagedCounts: counts
    )
  }
  
  struct CachedResultKey: Hashable {
    let entries: [ConditionRecord.Entry]
    let damagedCounts: [Int]
    let runningDamagedCount: Int
  }
  
  static var cached = [CachedResultKey: [[ConditionRecord.Entry]]]()

  static func numberOfPossibleSolutions(
    entries: [ConditionRecord.Entry],
    damagedCounts: [Int],
    runningDamagedCount: Int = 0,
    resolvedEntries: [ConditionRecord.Entry] = [],
    level: Int = 0
  ) -> [[ConditionRecord.Entry]] {
    printState(
      entries: entries,
      resolvedEntries: resolvedEntries,
      counts: damagedCounts,
      runningDamagedCount: runningDamagedCount,
      level: level
    )
    
    let cacheKey = CachedResultKey(
      entries: entries, damagedCounts: damagedCounts, runningDamagedCount: runningDamagedCount
    )
    
    if let cachedResult = self.cached[cacheKey] {
      return cachedResult
    }
    
    func cacheAndReturn(_ result: [[ConditionRecord.Entry]]) -> [[ConditionRecord.Entry]] {
      self.cached[cacheKey] = result
      return result
    }

    guard let entry = entries.first else {
      if damagedCounts.isEmpty {
        printIndented("1: Empty and Dones!", level: level)
        return cacheAndReturn([resolvedEntries])
      } else {
        if damagedCounts.count == 1 && runningDamagedCount == damagedCounts.first {
          printIndented("1: Empty and Dones!", level: level)
          return cacheAndReturn([resolvedEntries])
        } else {
          printIndented("0: Empty", level: level)
          return cacheAndReturn([])
        }
      }
    }

    let nextExpectedDamageCount = damagedCounts.first
    
    switch entry {
    case .damaged:
      printIndented("Damaged (Given)", level: level)
      // FAIL CASE
      guard let nextExpectedDamageCount, runningDamagedCount + 1 <= nextExpectedDamageCount else {
        printIndented("0: Running count too big", level: level)
        return cacheAndReturn([])
      }

      printIndented("Damaged (Confirmed)", level: level)
      let solutions = numberOfPossibleSolutions(
        entries: Array(entries.suffix(from: 1)),
        damagedCounts: damagedCounts,
        runningDamagedCount: runningDamagedCount + 1,
        resolvedEntries: resolvedEntries + [.damaged],
        level: level
      )
      return cacheAndReturn(solutions)

    case .operational:
      printIndented("Operational (Given)", level: level)
      if runningDamagedCount > 0 {
        printIndented("Running > 0", level: level)
        // FAIL CASE
        guard runningDamagedCount == nextExpectedDamageCount else {
          printIndented("0: Ended running damage without matching", level: level)
          return cacheAndReturn([])
        }
        printIndented("Operational (Confirmed) ", level: level)
        let solutions = numberOfPossibleSolutions(
          entries: Array(entries.suffix(from: 1)),
          damagedCounts: Array(damagedCounts.suffix(from: 1)),
          runningDamagedCount: 0,
          resolvedEntries: resolvedEntries + [.operational],
          level: level
        )
        return cacheAndReturn(solutions)
      } else {
        printIndented("Running = 0, Operational (Confirmed)", level: level)
        let solutions = numberOfPossibleSolutions(
          entries: Array(entries.suffix(from: 1)),
          damagedCounts: damagedCounts,
          runningDamagedCount: 0,
          resolvedEntries: resolvedEntries + [.operational],
          level: level
        )
        return cacheAndReturn(solutions)
      }
      
    case .unknown:
      printIndented("Unknown (Given)", level: level)
      if runningDamagedCount == nextExpectedDamageCount {
        printIndented("running == next, Operational (Confirmed)", level: level)
        // Must be operational
        let solutions = numberOfPossibleSolutions(
          entries: Array(entries.suffix(from: 1)),
          damagedCounts: Array(damagedCounts.suffix(from: 1)),
          runningDamagedCount: 0,
          resolvedEntries: resolvedEntries + [.operational],
          level: level
        )
        return cacheAndReturn(solutions)
      } else if let nextExpectedDamageCount, runningDamagedCount > 0 && runningDamagedCount < nextExpectedDamageCount {
        printIndented("Running damaged, Damaged (Confirmed)", level: level)
        // Must be damaged
        let solutions = numberOfPossibleSolutions(
          entries: Array(entries.suffix(from: 1)),
          damagedCounts: damagedCounts,
          runningDamagedCount: runningDamagedCount + 1,
          resolvedEntries: resolvedEntries + [.damaged],
          level: level
        )
        return cacheAndReturn(solutions)
      } else {
        // Branch 2 ways
        printIndented("Branching!", level: level)

        var operationalSolutions = numberOfPossibleSolutions(
            entries: [.operational] + entries.suffix(from: 1),
            damagedCounts: damagedCounts,
            runningDamagedCount: runningDamagedCount,
            resolvedEntries: resolvedEntries,
            level: level + 1
        )

        
        if !damagedCounts.isEmpty {
          let damagedSolutions = numberOfPossibleSolutions(
            entries: [.damaged] + entries.suffix(from: 1),
            damagedCounts: damagedCounts,
            runningDamagedCount: runningDamagedCount,
            resolvedEntries: resolvedEntries,
            level: level + 1
          )

          operationalSolutions.append(contentsOf: damagedSolutions)
        }
        return cacheAndReturn(operationalSolutions)
      }
    }
  }
  
  static func printState(
    entries: [ConditionRecord.Entry],
    resolvedEntries: [ConditionRecord.Entry],
    counts: [Int],
    runningDamagedCount: Int? = nil,
    level: Int
  ) {
    var lines: [[Character]]
    var firstLine = [Character](repeating: " ", count: resolvedEntries.count)
    firstLine.append(contentsOf: entries.map(\.rawValue))
    firstLine.append(" ")
    firstLine.append(contentsOf: String(describing: counts))
    firstLine.append(" ")
    firstLine.append(contentsOf: "\(runningDamagedCount!)")
    lines = [
       firstLine
    ]
    if !resolvedEntries.isEmpty {
      lines.append(resolvedEntries.map(\.rawValue))
    }
    if !entries.isEmpty {
      var countCharacters = [Character](repeating: " ", count: resolvedEntries.count + entries.count - 1)
      countCharacters.insert("^", at: resolvedEntries.count)
      lines.append(countCharacters)
    }
    
    for line in lines {
      printIndented(String(line), level: level)
    }
  }
  
  static func printIndented(_ s: Any, level: Int) {
    print(String([Character](repeating: " ", count: level)), s)
  }
  
  static func printEntries(_ entries: [ConditionRecord.Entry]) {
    print(String(entries.map(\.rawValue)))
  }
}
