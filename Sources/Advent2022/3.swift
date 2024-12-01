import AdventCommon
import Foundation
import Algorithms
import Regex

/// https://adventofcode.com/2022/day/3
public struct Day3: AdventDay {

  public static let year = 2022
  public static let day = 3
  
  public static let answer = AdventAnswer(partOne: 8109, partTwo: 2738)

  public static func solve(input: String) throws -> AdventAnswer {
    let rucksacks = input.components(separatedBy: .newlines).filter { !$0.isEmpty }
    
    let part1 = rucksacks
      .map { rucksack in
        // Find common item
        let compartment1 = Set(rucksack.prefix(rucksack.count / 2))
        let compartment2 = Set(rucksack.suffix(rucksack.count / 2))
        return compartment1.intersection(compartment2).first!
      }
      .map { $0.priority }
      .reduce(0, +)
    
    let part2 = rucksacks
      .map(Set.init)
      .chunks(ofCount: 3)
      // Find common item
      .map { group in
        group.reduce(Set<Character>.letters) { $0.intersection($1) }.first!
      }
      .map(\.priority)
      .reduce(0, +)
    
    return AdventAnswer(
      partOne: part1,
      partTwo: part2
    )
  }
}

extension Character {
  var priority: Int {
    guard self.isLetter else { return 0 }

    let priority: UInt8
    if self.isLowercase {
      priority = self.asciiValue! - Character("a").asciiValue! + 1
    } else if self.isUppercase {
      priority = self.asciiValue! - Character("A").asciiValue! + 27
    } else {      
      priority = 0
    }
    
    return Int(priority)
  }
}

extension Set where Element == Character {
  static let letters = Set("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ")
}
