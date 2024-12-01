//
//  7.swift
//
//
//  Created by Juan Fajardo on 12/15/23.
//

import AdventCommon
import RegexBuilder
import Algorithms
import OrderedCollections

fileprivate typealias Regex = _StringProcessing.Regex

public struct Day7: AdventDay {
  
  public static let year = 2023
  
  public static let day = 7
  
  public static let answer = AdventAnswer(partOne: 251_216_224, partTwo: 250_825_971)
  
  struct Hand: Comparable {

    enum Card: Int, Comparable {
      case joker = 1
      case two = 2
      case three
      case four
      case five
      case six
      case seven
      case eight
      case nine
      case ten
      case jack
      case queen
      case king
      case ace

      init(_ character: Character, jStrategy: Hand.JStrategy) {
        switch character {
        case "A": self = .ace
        case "K": self = .king
        case "Q": self = .queen
        case "J": self = jStrategy.card
        case "T": self = .ten
        case "9": self = .nine
        case "8": self = .eight
        case "7": self = .seven
        case "6": self = .six
        case "5": self = .five
        case "4": self = .four
        case "3": self = .three
        case "2": self = .two
        default: fatalError("Invalid character: \(character).")
        }
      }
      
      static func < (lhs: Card, rhs: Card) -> Bool {
        lhs.rawValue < rhs.rawValue
      }
    }
    
    enum _Type: Comparable {
      case highCard
      case onePair
      case twoPair
      case threeOfAKind
      case fullHouse
      case fourOfAKind
      case fiveOfAKind
    }
    
    enum JStrategy {
      case jack, joker

      var card: Card {
        switch self {
        case .jack: return .jack
        case .joker: return .joker
        }
      }
    }
    
    let bid: Int
    let type: _Type
    let first: Card
    let second: Card
    let third: Card
    let fourth: Card
    let fifth: Card
    
    init(cards: (Card, Card, Card, Card, Card), bid: Int, jStrategy: JStrategy) {
      self.bid = bid
      self.first = cards.0
      self.second = cards.1
      self.third = cards.2
      self.fourth = cards.3
      self.fifth = cards.4
      
      let counts = OrderedDictionary(
        uniqueKeysWithValues: Dictionary(grouping: [cards.0, cards.1, cards.2, cards.3, cards.4]) { $0 }
          .mapValues { $0.count }
          .sorted { $0.value > $1.value }
      )

      self.type = Self.computeHandType(counts: counts)
    }
    
    private static func computeHandType(counts: OrderedDictionary<Card, Int>) -> _Type {
      var counts = counts

      let jokerCount = counts.removeValue(forKey: .joker) ?? 0
      // Since the counts are ordered, the first element is the highest-count card.
      // If there is no non-joker cards, treat it as if the highest-count card is *any* card
      // with a count of 0.
      let highestCard = counts.elements.first ?? (key: .ace, value: 0)
      counts[highestCard.key] = highestCard.value + jokerCount

      let highestCount = counts.elements[0].value
      let secondHighestCount = counts.count > 1 ? counts.elements[1].value: 0
      switch (highestCount, secondHighestCount) {
      case (5, _): return .fiveOfAKind
      case (4, _): return .fourOfAKind
      case (3, 2): return .fullHouse
      case (3, 1): return .threeOfAKind
      case (2, 2): return .twoPair
      case (2, 1): return .onePair
      case (1, _): return .highCard
      default: fatalError("Invalid card counts: \(counts).")
      }
    }
    
    static func < (lhs: Hand, rhs: Hand) -> Bool {
      if lhs.type != rhs.type {
        return lhs.type < rhs.type
      } else {
        let cardKeyPaths: [KeyPath<Hand, Card>] = [\.first, \.second, \.third, \.fourth, \.fifth]
        for cardKeyPath in cardKeyPaths where lhs[keyPath: cardKeyPath] != rhs[keyPath: cardKeyPath] {
          return lhs[keyPath: cardKeyPath] < rhs[keyPath: cardKeyPath]
        }
      }
      return false
    }
  }
  
  public static func solve(input: String) throws -> AdventAnswer {
    let lines = input.components(separatedBy: .newlines)
    
    func solve(jStrategy: Hand.JStrategy) throws -> Int {
      let hands = try lines.map { try self.parseHand(from: $0, jStrategy: jStrategy) }
      return hands.sorted(by: <).enumerated().map { $0.element.bid * ($0.offset + 1) }.reduce(0, +)
    }
    
    return AdventAnswer(
      partOne: try solve(jStrategy: .jack),
      partTwo: try solve(jStrategy: .joker)
    )
  }
  
  static func parseHand(from raw: String, jStrategy: Hand.JStrategy) throws -> Hand {
    let cardRegex = CharacterClass.anyOf("AKQJT98765432")
    let bidRef = Reference(Int.self)
    
    let firstRef = Reference(Hand.Card.self)
    let secondRef = Reference(Hand.Card.self)
    let thirdRef = Reference(Hand.Card.self)
    let fourthRef = Reference(Hand.Card.self)
    let fifthRef = Reference(Hand.Card.self)
    
    func cardCapture(as reference: RegexBuilder.Reference<Hand.Card>) -> some RegexComponent {
      TryCapture(as: reference) {
        cardRegex
      } transform: {
        Hand.Card($0.first!, jStrategy: jStrategy)
      }
    }

    let regex = Regex {
      cardCapture(as: firstRef)
      cardCapture(as: secondRef)
      cardCapture(as: thirdRef)
      cardCapture(as: fourthRef)
      cardCapture(as: fifthRef)
      " "
      TryCapture(as: bidRef) {
        OneOrMore(.digit)
      } transform: {
        Int($0)
      }
    }
    
    guard let match = try regex.wholeMatch(in: raw) else { throw AdventError.malformedInput(input: raw) }
    
    return Hand(
      cards: (match[firstRef], match[secondRef], match[thirdRef], match[fourthRef], match[fifthRef]),
      bid: match[bidRef],
      jStrategy: jStrategy
    )
  }
}
