//
//  2.swift
//
//
//  Created by Juan Fajardo on 12/10/23.
//

import AdventCommon
import RegexBuilder

fileprivate typealias Regex = _StringProcessing.Regex

public struct Day2: AdventDay {
  
  public static let year = 2023
  
  public static let day = 2
  
  struct Game {
    struct Hand {
      let red: Int
      let green: Int
      let blue: Int
      
      var power: Int { self.red * self.green * self.blue }
    }
    
    let id: Int
    let hands: [Hand]
    
    func isPossibleWithCounts(red: Int, green: Int, blue: Int) -> Bool {
      return self.hands.allSatisfy { hand in
        hand.red <= red && hand.green <= green && hand.blue <= blue
      }
    }
    
    var minimumHand: Hand {
      Hand(
        red: self.hands.map(\.red).max()!,
        green: self.hands.map(\.green).max()!, 
        blue: self.hands.map(\.blue).max()!
      )
    }
  }
  
  public static func solve(input: String) throws -> AdventAnswer {
    let lines = input.components(separatedBy: .newlines)
    
    let games = try lines.map {
      let idReference = Reference(Int.self)
      let gameReference = Reference(Substring.self)
      let regex = Regex {
        "Game "
        TryCapture(as: idReference) {
          OneOrMore(.digit)
        } transform: {
          Int($0)
        }
        ": "
        Capture(OneOrMore(.any), as: gameReference)
      }
      
      guard let match = $0.wholeMatch(of: regex) else {
        throw AdventError.malformedInput(input: $0)
      }

      let id = match[idReference]
      let game = match[gameReference]
      
      let hands = game.components(separatedBy: ";").map {
        Game.Hand(
          red: self.number(of: "red", in: $0),
          green: self.number(of: "green", in: $0),
          blue: self.number(of: "blue", in: $0)
        )
      }
      
      return Game(id: id, hands: hands)
    }
        
    return AdventAnswer(
      partOne: games.filter { $0.isPossibleWithCounts(red: 12, green: 13, blue: 14) }.map(\.id).reduce(0, +),  // 2632
      partTwo: games.map(\.minimumHand.power).reduce(0, +)  // 69629
    )
  }
  
  fileprivate static func number(of color: String, in rawHand: String) -> Int {
    let ref = Reference(Int.self)
    let regex = Regex {
      TryCapture(as: ref) {
        OneOrMore(.digit)
      } transform: {
        Int($0)
      }
      " \(color)"
    }
    
    if let match = rawHand.firstMatch(of: regex) {
      return match[ref]
    } else {
      return 0
    }
  }
}
