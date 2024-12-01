import Algorithms
import Foundation
import AdventCommon
import Regex

/// https://adventofcode.com/2021/day/1
public struct Day16: AdventDay {

  public static let year = 2021
  public static let day = 16
  public static let answer = AdventAnswer(partOne: 929, partTwo: 911945136934)

  public static func solve(input: String) throws -> AdventAnswer {
    var bits = Array(input.compactMap { Int(String($0), radix: 16) }.map { $0.bitArray(minLength: 4) }.reduce([], +).reversed())
    let packet = bits.scanPacket()!

    func versionSum(of packet: Packet) -> Int {
      switch packet.payload {
      case .literal: return packet.version
      case .operator(_, let subpackets): return packet.version + subpackets.map { versionSum(of: $0) }.reduce(0, +)
      }
    }
    
    func value(of packet: Packet) -> Int {
      switch packet.payload {
      case .literal(let value): return value
      case .operator(let operation, let subpackets):
        switch operation {
        case .sum:
          return subpackets.map { value(of: $0) }.reduce(0, +)
        case .product:
          return subpackets.map { value(of: $0) }.reduce(1, *)
        case .min:
          return subpackets.map { value(of: $0) }.min() ?? 0
        case .max:
          return subpackets.map { value(of: $0) }.max() ?? 0
        case .greaterThan:
          return value(of: subpackets[0]) > value(of: subpackets[1]) ? 1 : 0
        case .lessThan:
          return value(of: subpackets[0]) < value(of: subpackets[1]) ? 1 : 0
        case .equalTo:
          return value(of: subpackets[0]) == value(of: subpackets[1]) ? 1 : 0
        }
      }
    }
        
    return AdventAnswer(
      partOne: versionSum(of: packet),
      partTwo: value(of: packet)
    )
  }
}

struct Packet {
  enum Operation: Int {
    case sum = 0, product = 1, min = 2, max = 3, greaterThan = 5, lessThan = 6, equalTo = 7
  }
  
  indirect enum Payload {
    case literal(Int)
    case `operator`(operation: Operation, subpackets: [Packet])
  }
  
  let version: Int
  let payload: Payload
}

enum Bit: Character {
  case zero = "0"
  case one = "1"
  
  var integerValue: Int {
    switch self {
    case .zero: return 0
    case .one: return 1
    }
  }
}

extension Int {
  
  init(bitArray: [Bit]) {
    self = bitArray.reversed().enumerated().map { i, bit in
      bit.integerValue * 2.raisedTo(power: i)
    }.reduce(0, +)
  }
  
  func bitArray(minLength: Int = 0) -> [Bit] {
    guard self > 0 else { return .init(repeating: .zero, count: minLength) }
    let numberOfBits = log2(Double(self)) + 1
    let numberOfBitsInArray = Int(Swift.max(numberOfBits, Double(minLength)))
    return (0..<numberOfBitsInArray).reversed().compactMap {
      self >> $0 & 1 == 1 ? .one : .zero
    }
  }
}

extension Array where Element == Bit {
  
  mutating func scanBit() -> Bit? {
    return self.popLast()
  }
  
  mutating func scanBits(numberOfBits: Int) -> [Bit]? {
    var bits = [Bit]()
    for _ in 0..<numberOfBits {
      guard let bit = self.scanBit() else { break }
      bits.append(bit)
    }
    return bits
  }
  
  mutating func scanInt(numberOfDigits: Int) -> Int? {
    guard let bits = self.scanBits(numberOfBits: numberOfDigits) else { return nil }
    return Int(bitArray: bits)
  }
  
  mutating func scanPacket() -> Packet? {
    let version = self.scanInt(numberOfDigits: 3)!
    let typeID = self.scanInt(numberOfDigits: 3)!
    
    if typeID == 4 {
      var bits = [Bit]()
      while true {
        let endBit = self.scanBit()!
        bits.append(contentsOf: self.scanBits(numberOfBits: 4)!)
        if endBit == .zero { break }
      }
      let number = Int(bitArray: bits)
      return Packet(version: version, payload: .literal(number))
    } else {
      let lengthTypeID = self.scanBit()!
      switch lengthTypeID {
      case .zero:
        let subpacketsLength = self.scanInt(numberOfDigits: 15)!
        let endCount = self.count - subpacketsLength
        var subpackets = [Packet]()
        while self.count > endCount {
          subpackets.append(self.scanPacket()!)
        }
        let operation = Packet.Operation(rawValue: typeID)!
        return Packet(version: version, payload: .operator(operation: operation,  subpackets: subpackets))
        
      case .one:
        let numberOfSubpackets = self.scanInt(numberOfDigits: 11)!
        let subpackets = (0..<numberOfSubpackets).map { _ in self.scanPacket()! }
        let operation = Packet.Operation(rawValue: typeID)!
        return Packet(version: version, payload: .operator(operation: operation,  subpackets: subpackets))
      }
    }
  }
}
