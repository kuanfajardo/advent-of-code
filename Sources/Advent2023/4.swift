//
//  4.swift
//
//
//  Created by Juan Fajardo on 12/10/23.
//

import AdventCommon
import RegexBuilder
import OrderedCollections

fileprivate typealias Regex = _StringProcessing.Regex

public struct Day4: AdventDay {
  
  public static let year = 2023
  
  public static let day = 4
  
  public static let answer = AdventAnswer(partOne: 25_174, partTwo: 6_420_979)
  
  struct Card: Hashable {
    let id: Int
    let winningNumbers: Set<Int>
    let myNumbers: Set<Int>
    
    var numberOfMatches: Int {
      self.winningNumbers.intersection(self.myNumbers).count
    }
    
    var points: Int {
      2.raisedTo(power: self.numberOfMatches - 1)
    }
    
    static func == (lhs: Card, rhs: Card) -> Bool {
      lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
      hasher.combine(self.id)
    }
  }
  
  public static func solve(input: String) throws -> AdventAnswer {
    let cards = try input.components(separatedBy: .newlines).map {
      try self.extractCard(from: $0)
    }
    
    let idToCard = [Int: Card](uniqueKeysWithValues: cards.map { ($0.id, $0) })
    let initialCounts = OrderedDictionary(uniqueKeysWithValues: cards.map { ($0, 1) })
    
    let finalCounts = cards.reduce(into: initialCounts) { counts, card in
      // If no matches in card, move on to next one.
      guard card.numberOfMatches > 0 else { return }
      
      let idsToCopy = (card.id + 1)...(card.id + card.numberOfMatches)
      let numberOfCopies = counts[card]!  // Guaranteed to be at least 1 for all cards.
      for id in idsToCopy {
        guard
          let cardToCopy = idToCard[id],
          let count = counts[cardToCopy]
        else { continue }
        counts[cardToCopy] = count + numberOfCopies
      }
    }
    
    return AdventAnswer(
      partOne: cards.map(\.points).reduce(0, +),
      partTwo: finalCounts.map(\.value).reduce(0, +)
    )
  }
  
  static func extractCard(from line: String) throws -> Card {
    let idRef = Reference(Int.self)
    let winningNumbersRef = Reference([Int].self)
    let myNumbersRef = Reference([Int].self)
    
    let numbersTransform: (Substring) throws -> [Int] = { rawNumbers in
      try rawNumbers
        .components(separatedBy: .whitespaces)
        .compactMap {
          // Ignore multiple whitespaces in between numbers.
          guard !$0.isEmpty else { return nil }
          guard let number = Int($0) else {
            throw AdventError.malformedInput(input: $0)
          }
          return number
        }
    }
    
    let regex = Regex {
      "Card"
      OneOrMore(.horizontalWhitespace)
      TryCapture(as: idRef) {
        OneOrMore(.digit)
      } transform: {
        Int($0)
      }
      ":"
      OneOrMore(.horizontalWhitespace)
      TryCapture(
        OneOrMore(.digit.union(.horizontalWhitespace)),
        as: winningNumbersRef,
        transform: numbersTransform
      )
      "|"
      TryCapture(
        OneOrMore(.digit.union(.horizontalWhitespace)),
        as: myNumbersRef,
        transform: numbersTransform
      )
    }
    
    guard let match = line.firstMatch(of: regex) else {
      throw AdventError.malformedInput(input: line)
    }

    return Card(
      id: match[idRef],
      winningNumbers: Set(match[winningNumbersRef]),
      myNumbers: Set(match[myNumbersRef])
    )
  }
}
