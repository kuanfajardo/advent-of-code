//
//  8.swift
//
//
//  Created by Juan Fajardo on 12/16/23.
//

import AdventCommon
import RegexBuilder
import Algorithms

fileprivate typealias Regex = _StringProcessing.Regex

public struct Day8: AdventDay {
  
  public static var year: Int { 2023 }
  
  public static var day: Int { 8 }
  
  static let temp =
    """
    RL

    AAA = (BBB, CCC)
    BBB = (DDD, EEE)
    CCC = (ZZZ, GGG)
    DDD = (DDD, DDD)
    EEE = (EEE, EEE)
    GGG = (GGG, GGG)
    ZZZ = (ZZZ, ZZZ)
    """
  
  static let temp2 =
    """
    LLR

    AAA = (BBB, BBB)
    BBB = (AAA, ZZZ)
    ZZZ = (ZZZ, ZZZ)
    """
  
  public static func solve(input: String) throws -> AdventAnswer {
    var lines = input.components(separatedBy: .newlines)
    let instructions = lines.removeFirst()
    let nodes = try lines.filter { !$0.isEmpty }.map(parseNode)
    print(nodes.count)
    
    let leftNodesMap = [String: String](uniqueKeysWithValues: nodes.map { (key: $0.id, value: $0.left) })
    let rightNodesMap = [String: String](uniqueKeysWithValues: nodes.map { (key: $0.id, value: $0.right) })
    
    let partOne = self.numStepsTillEnd(
      instructions: instructions,
      initial: "AAA",
      next: { current, instruction in
        switch instruction {
        case "L": return leftNodesMap[current]!
        case "R": return rightNodesMap[current]!
        default: fatalError("Invalid instruction: \(instruction)!")
        }
      },
      isDone: {
        $0 == "ZZZ"
      }
    )
    
    // Cycle in each one
    // Zs can occur before cycle or after
    // Find formula for Zs for each cycle
    // Z_0 = [1, 4, 5, ...] UNION [(size of cycle)*N + X for X in Zs in cycle]
    
    //  170, but starting on 3rd
    //  986 + 75n
    //
    
//    let partTwo = self.numStepsTillEnd(
//      instructions: instructions,
//      initial: nodes.filter { $0.id.last == "A" }.map(\.id),
//      next: { current, instruction in
//        switch instruction {
//        case "L": return current.map { leftNodesMap[$0]! }
//        case "R": return current.map { rightNodesMap[$0]! }
//        default: fatalError("Invalid instruction: \(instruction)!")
//        }
//      },
//      isDone: {
//        $0.allSatisfy { $0.last == "Z" }
//      }
//    )
    
    return AdventAnswer(
      partOne: partOne,  // 21883
      partTwo: nodes.filter { $0.id.last == "A" }.map(\.id).map { self.computeCycle(start: $0, lefts: leftNodesMap, rights: rightNodesMap, instructions: instructions)}  //
    )
  }
  
  static func numStepsTillEnd<T>(
    instructions: String,
    initial: T,
    next: (T, Character) -> T,
    isDone: (T) -> Bool
  ) -> Int {
    var numSteps = 0
    var current = initial
    for instruction in instructions.cycled() {
      if isDone(current) {
        break
      }
      numSteps += 1
      current = next(current, instruction)
    }
    
    return numSteps
  }
  
  static func computeCycle(
    start: String,
    lefts: [String: String],
    rights: [String: String],
    instructions: String
  ) -> (Int, Int, Int, String, [(Int, String)]) {
    var numSteps = 0
    var current = start
    var visited = [Int: [String]].init(uniqueKeysWithValues: (0..<instructions.count).map { ($0, []) })
    var loopStart: Int?
    var nodes = [current]
    for (i, instruction) in Array(instructions.enumerated()).cycled() {
      if visited[i]!.contains(current) {
        loopStart = i
        break
      }
      visited[i]!.append(current)
      nodes.append(current)
      numSteps += 1
      switch instruction {
      case "L": current = lefts[current]!
      case "R": current = rights[current]!
      default: fatalError("Invalid instruction: \(instruction)!")
      }
    }
    let loopLength = (numSteps - loopStart!) / instructions.count
    let visitedLoopStart = visited[loopStart!]!.enumerated()
    let loopNStart = visitedLoopStart.first {
      $0.element == current
    }!.offset
    return (numSteps, loopStart!, loopLength, current, Array(visitedLoopStart))
  }
  
//  class Node {
//    let id: String
//    let left: Node
//    let right: Node
//    
//    private init(id: String, left: Node, right: Node) {
//      self.id = id
//      self.left = left
//      self.right = right
//    }
//    
//    static var nodes = [String: Node]()
//    
//    static func make(id: String, left: Node, right: Node) -> Node {
//      guard self.nodes[id] == nil else {
//        fatalError("More than one node initialized with id: \(id)!")
//      }
//      let node = Node(id: id, left: left, right: right)
//      nodes[id] = node
//      return node
//    }
//    
//    static func node(id: String) -> Node? {
//      self.nodes[id]
//    }
//  }
  
  struct Node {
    let id: String
    let left: String
    let right: String
  }
  
  private static func parseNode(_ raw: String) throws -> Node {
    func nodeIDCapture(as reference: RegexBuilder.Reference<String>) -> some RegexComponent {
      return Regex {
        TryCapture(as: reference) {
          Repeat(count: 3) {
            CharacterClass.word
          }
        } transform: {
          String($0)
        }
      }
    }
    
    let idRef = Reference(String.self)
    let leftRef = Reference(String.self)
    let rightRef = Reference(String.self)
    
    let regex = Regex {
      nodeIDCapture(as: idRef)
      " = ("
      nodeIDCapture(as: leftRef)
      ", "
      nodeIDCapture(as: rightRef)
      ")"
    }
    
    guard let match = try regex.wholeMatch(in: raw) else {
      throw AdventError.malformedInput(input: raw)
    }
    
    return Node(id: match[idRef], left: match[leftRef], right: match[rightRef])
  }
}
