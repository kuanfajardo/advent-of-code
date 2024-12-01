//
//  6.swift
//
//
//  Created by Juan Fajardo on 12/14/23.
//

import AdventCommon

public struct Day6: AdventDay {
  
  public static let year = 2023
  
  public static let day = 6
  
  public static let answer = AdventAnswer(partOne: 6_209_190, partTwo: 28_545_089)
  
  struct Race {
    let time: Int
    let distance: Int
    
    func holdTimeBeatsDistance(_ holdTime: Int) -> Bool {
      return holdTime * (self.time - holdTime) > self.distance
    }
  }
  
  public static func solve(input: String) throws -> AdventAnswer {
    let part1Races = [
      Race(time: 40, distance: 215),
      Race(time: 92, distance: 1064),
      Race(time: 97, distance: 1505),
      Race(time: 90, distance: 1100)
    ]
    
    let part2Race = Race(time: 40_929_790, distance: 215_106_415_051_100)
    
    return AdventAnswer(
      partOne: part1Races.map(numPossibilitiesQuadratic(toBeat:)).reduce(1, *),
      partTwo: self.numPossibilitiesQuadratic(toBeat: part2Race)
    )
  }
  
  static func numPossibilitiesBinarySearch(toBeat race: Race) -> Int {
    // - Returns the smallest hold time that beats `race` in the given range.
    func smallestWinningHoldTime(in range: ClosedRange<Int>) -> Int {
      // Base Case (range of 1)
      if range.count == 1 {
        // The smallest winning number is either the number or the number + 1.
        let holdTime = range.lowerBound
        return race.holdTimeBeatsDistance(holdTime) ? holdTime : holdTime + 1
      }
      // Recursive Case
      else {
        // Choose pivot in middle of range; if it beats the race, recurse on the lower half; if it
        // loses, recurse on the upper half.
        let holdTime = range.upperBound - (range.count / 2)
        if race.holdTimeBeatsDistance(holdTime) {
          return smallestWinningHoldTime(in: range.lowerBound...holdTime)
        } else {
          return smallestWinningHoldTime(in: (holdTime + 1)...range.upperBound)
        }
      }
    }

    // Strategy: The possible distances form an upside-down parabola whose maximum is at exactly
    // the midpoint of the range 0...race.time; we only need to find the number of
    // possible solutions on one half and then double it!
    //
    // Use the lower half, and recursively find the smallest winning hold time. The number of
    // solutions in that half is the distance between the midpoint and the smallest possibiliy.
    let pivot = race.time / 2
    let smallestWinningHoldTime = smallestWinningHoldTime(in: 0...pivot)
    if race.time.isMultiple(of: 2) {
      return (smallestWinningHoldTime...pivot).count * 2 - 1
    } else {
      return (smallestWinningHoldTime...pivot).count * 2
    }
  }
  
  static func numPossibilitiesQuadratic(toBeat race: Race) -> Int {
    // Strategy: Possible distances are given by the equation `t * (b - t) > d`, where
    //  - `t` is the time held
    //  - `b` is the duration of the race
    //  - `d` is the record distance
    //
    // This is a quadratic! To solve this, we can find the two points z_0, z_1 where `t * (b - t) = d`, and
    // the solution is the range (z_0, z_1).
    //
    // To solve, we re-arrange into quadratic form and solve: `-t^2 + bt - d = 0`.
    let a: Double = -1
    let b = Double(race.time)
    let c = Double(-race.distance)
    
    let lowerBound = (-b + (b * b - 4 * a * c).squareRoot()) / (2 * a)
    let upperBound = (-b - (b * b - 4 * a * c).squareRoot()) / (2 * a)
    
    let quantizedLowerBound = Int((lowerBound + 1).rounded(.down))
    let quantizedUpperBound = Int((upperBound - 1).rounded(.up))
    return (quantizedLowerBound...quantizedUpperBound).count
  }
}
