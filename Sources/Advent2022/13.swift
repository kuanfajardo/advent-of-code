import AdventCommon
import Algorithms
import Regex
import Collections
import Foundation

/// https://adventofcode.com/2022/day/13
public struct Day13: AdventDay {

  public static let year = 2022
  public static let day = 13
  
  public static let answer = AdventAnswer(partOne: 5684, partTwo: 22932)

  public static func solve(input: String) throws -> AdventAnswer {
    let payloads = input
      .components(separatedBy: .newlines)
      .filter { !$0.isEmpty }
      .map { Scanner(string: $0).scanPayload()! }

    return AdventAnswer(
      partOne: indicesOfSortedPackets(payloads: payloads),
      partTwo: decoderKey(payloads: payloads)
    )
  }
  
  // PART ONE
  
  static func indicesOfSortedPackets(payloads: [Packet.Payload]) -> Int {
    let packets = payloads
      .chunks(ofCount: 2)
      .map(Array.init)
      .map { chunk in
        let lhs = chunk[0]
        let rhs = chunk[1]
        return Packet(lhs: lhs, rhs: rhs)
      }
    
    return packets.map(\.isSorted).enumerated().map { $0.element ? $0.offset + 1 : 0 }.reduce(0, +)
  }
  
  // PART TWO
  
  static func decoderKey(payloads: [Packet.Payload]) -> Int {
    let markerOne: Packet.Payload = [[2]]
    let markerTwo: Packet.Payload = [[6]]
    
    let payloadsWithMarkers = payloads + [markerOne, markerTwo]
    let sortedWithMarkers = payloadsWithMarkers.sorted(by: <)
    
    let markerOneLocation = sortedWithMarkers.firstIndex { $0 == markerOne }! + 1
    let markerTwoLocation = sortedWithMarkers.firstIndex { $0 == markerTwo }! + 1
    
    return markerOneLocation * markerTwoLocation
  }
}

struct Packet: CustomStringConvertible {
  
  enum Payload: ExpressibleByIntegerLiteral, ExpressibleByArrayLiteral, CustomStringConvertible, Equatable {
    case integer(Int)
    case list(Deque<Payload>)
    
    // MARK: ExpressibleByIntegerLiteral

    init(integerLiteral value: Int) {
      self = .integer(value)
    }
    
    // MARK: ExpressibleByArrayLiteral
    
    init(arrayLiteral elements: Payload...) {
      self = .list(.init(elements))
    }
    
    // MARK: Equatable
    
    static func == (lhs: Payload, rhs: Payload) -> Bool {
      switch (lhs, rhs) {
      case (.integer(let lhs), .integer(let rhs)):
        return lhs == rhs
      case (.list(let lhs), .list(let rhs)):
        return lhs == rhs
      case (.list, .integer):
        return lhs == .list([rhs])
      case (.integer, .list):
        return .list([lhs]) == rhs
      }
    }
    
    // MARK: Comparable
    
    static func < (lhs: Payload, rhs: Payload) -> Bool {
      enum ComparisonResult {
        case inOrder
        case notInOrder
        case unknownOrder
      }
      
      func compare(lhs: Packet.Payload, rhs: Packet.Payload) -> ComparisonResult {
        switch (lhs, rhs) {
        case (.integer(let lhs), .integer(let rhs)):
          if lhs < rhs {
            return .inOrder
          } else if lhs > rhs {
            return .notInOrder
          } else {
            return .unknownOrder
          }
          
        case (.list(var lhs), .list(var rhs)):
          while true {
            switch (lhs.popFirst(), rhs.popFirst()) {
            case (.some(let left), .some(let right)):
              let comparison = compare(lhs: left, rhs: right)
              switch comparison {
              case .inOrder, .notInOrder: return comparison
              case .unknownOrder: continue
              }
              
            case (.none, .some):
              return .inOrder
            case (.none, .none):
              return .unknownOrder
            case (.some, .none):
              return .notInOrder
            }
          }
          
        case (.list, .integer):
          return compare(lhs: lhs, rhs: [rhs])
          
        case (.integer, .list):
          return compare(lhs: [lhs], rhs: rhs)
        }
      }
      
      return compare(lhs: lhs, rhs: rhs) == .inOrder
    }
    
    // MARK: Custom String Convertible
    
    var description: String {
      switch self {
      case .integer(let int):
        return "\(int)"
      case .list(let list):
        return "[" + Array(list).map(String.init(describing:)).joined(separator: ",") + "]"
      }
    }
  }
    
  let lhs: Payload
  let rhs: Payload
    
  var description: String {
    """
    
    LHS: \(self.lhs)
    RHS: \(self.rhs)
    """
  }
  
  var isSorted: Bool { lhs < rhs }
}

// MARK: Parsing

extension Scanner {
  
  func scanPayload() -> Packet.Payload? {
    let _ = self.scanCharacter() // opening "["
    let components = self.scanList(level: 0)
    return .list(Deque(components))
  }
  
  private func scanList(level: Int) -> [Packet.Payload] {
    var payloads = [Packet.Payload]()
    
    outer: while !self.isAtEnd {
      if let int = self.scanInt() {
        payloads.append(.integer(int))
      }
      
      switch self.scanCharacter() {
      case ",":
        continue
      case "[":
        let components = self.scanList(level: level + 1)
        payloads.append(.list(Deque(components)))
      case "]":
        break outer
      default:
        fatalError("Bad input!")
      }
    }
    
    return payloads
  }
}
