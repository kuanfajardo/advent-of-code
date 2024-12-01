import AdventCommon
import Algorithms
import Regex

/// https://adventofcode.com/2022/day/2
public struct Day2: AdventDay {

  public static let year = 2022
  public static let day = 2
  
  public static let answer = AdventAnswer(partOne: 15632, partTwo: 14416)

  public static func solve(input: String) throws -> AdventAnswer {
    return AdventAnswer(
      partOne: Round_Part1.matches(in: input).map(\.score).reduce(0, +),
      partTwo: Round_Part2.matches(in: input).map(\.score).reduce(0, +)
    )
  }
  
  // MARK: Rock-Paper-Scissors Entities
    
  enum Move: ExpressibleByCaptureGroup {
    case rock
    case paper
    case scissors
    
    init?(captureGroup: String) {
      switch captureGroup {
      case "A", "X": self = .rock
      case "B", "Y": self = .paper
      case "C", "Z": self = .scissors
      default:
        return nil
      }
    }
    
    var score: Int {
      switch self {
      case .rock: return 1
      case .paper: return 2
      case .scissors: return 3
      }
    }
  }
  
  enum Result: String, ExpressibleByCaptureGroup {
    case lose = "X"
    case draw = "Y"
    case win = "Z"
    
    var score: Int {
      switch self {
      case .lose: return 0
      case .draw: return 3
      case .win: return 6
      }
    }
  }
  
  // MARK: Part 1
  
  struct Round_Part1: RegexRepresentable {
    static let regex: Regex = #"(?<opponent>[ABC]) (?<response>[XYZ])"#
    
    let opponentMove: Move
    let responseMove: Move
    
    init?(match: Match) {
      self.opponentMove = try! match.captureGroup(named: "opponent", as: Move.self)
      self.responseMove = try! match.captureGroup(named: "response", as: Move.self)
    }
    
    var score: Int {
      let result: Result
      switch (self.opponentMove, self.responseMove) {
      case (.rock, .scissors), (.paper, .rock), (.scissors, .paper):
        result = .lose
        
      case (.rock, .rock), (.paper, .paper), (.scissors, .scissors):
        result = .draw
        
      case (.rock, .paper), (.paper, .scissors), (.scissors, .rock):
        result = .win
      }
      
      return self.responseMove.score + result.score
    }
  }
  
  // MARK: Part 2
  
  struct Round_Part2: RegexRepresentable {
    static let regex: Regex = #"(?<opponent>[ABC]) (?<result>[XYZ])"#
    
    let opponentMove: Move
    let result: Result
    
    init?(match: Match) {
      self.opponentMove = try! match.captureGroup(named: "opponent", as: Move.self)
      self.result = try! match.captureGroup(named: "result", as: Result.self)
    }
    
    var score: Int {
      let responseMove: Move
      switch (self.opponentMove, self.result) {
      case (.rock, .win), (.paper, .draw), (.scissors, .lose):
        responseMove = .paper
      case (.rock, .lose), (.paper, .win), (.scissors, .draw):
        responseMove = .scissors
      case (.rock, .draw), (.paper, .lose), (.scissors, .win):
        responseMove = .rock
      }
      
      return responseMove.score + self.result.score
    }
  }
}
