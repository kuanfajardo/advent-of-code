import AdventCommon
import Algorithms
import Regex

/// https://adventofcode.com/2022/day/10
public struct Day10: AdventDay {

  public static let year = 2022
  public static let day = 10

  public static func solve(input: String) throws -> AdventAnswer {
    var instructions = try input.components(separatedBy: .newlines).filter { !$0.isEmpty }.map(Instruction.init(input:))
    
    // COMPUTER
    var cycle = 0
    var register = 1
    var registerHistory = [Int]()
    var pixels = [Character]()
    var pendingInstruction: (instruction: Instruction, cyclesLeft: Int)?
    
    // ACTIONS
    func loadNextInstruction() {
      let nextInstruction = instructions.removeFirst()
      pendingInstruction = (nextInstruction, nextInstruction.cyclesToComplete)
    }
    
    func addRegisterToHistory() {
      registerHistory.append(register)
    }
    
    func draw() {
      if ClosedRange(uncheckedBounds: (register - 1, register + 1)).contains(cycle % 40) {
        pixels.append("#")
      } else {
        pixels.append(".")
      }
    }
    
    func executeInstruction(_ instruction: Instruction) {
      switch instruction {
      case .noop: break
      case .addx(let value): register += value
      }
    }
    
    // CYCLE
    func simulateCycle() {
      if pendingInstruction == nil {
        loadNextInstruction()
      }
      
      draw()
      addRegisterToHistory()
      
      pendingInstruction?.cyclesLeft -= 1
      if pendingInstruction?.cyclesLeft == 0 {
        executeInstruction(pendingInstruction!.instruction)
        pendingInstruction = nil
      }
      
      cycle += 1
    }
    
    // PROGRAM
    while true {
      simulateCycle()
      if pendingInstruction == nil  && instructions.isEmpty { break }
    }
    
    func cycleStrength(at cycle: Int) -> Int {
      return cycle * registerHistory[cycle - 1]
    }

    return AdventAnswer(
      partOne: [20, 60, 100, 140, 180, 220].map(cycleStrength(at:)).reduce(0, +),  // 14520
      partTwo: "\n" + pixels.chunks(ofCount: 40).map(String.init(_:)).joined(separator: "\n")  // PBGZEJB
    )
  }
  
  // MARK: Input
  
  struct ParsingError: Error {
    let input: String
  }
  
  enum Instruction {
    case noop
    case addx(Int)
    
    enum Regexes {
      static let noop: Regex = #"noop"#
      static let addx: Regex = #"addx (?<value>-?\d+)"#
    }
    
    init(input: String) throws {
      if Regexes.noop.hasMatch(in: input) {
        self = .noop
      } else if let match = Regexes.addx.firstMatch(in: input) {
        self = .addx(try match.captureGroup(named: "value", as: Int.self))
      } else {
        throw ParsingError(input: input)
      }
    }
    
    var cyclesToComplete: Int {
      switch self {
      case .noop: return 1
      case .addx: return 2
      }
    }
  }
}
