import AdventCommon
import Regex

public struct Day2: AdventDay {

  public static let day = 2

  enum Movement: RegexRepresentable {
    case forward(Int)
    case up(Int)
    case down(Int)

    static let regex: Regex = #"(?m)^(?<direction>(up|down|forward))\s(?<amount>[0-9]+)"#

    init(match: Match) throws {
      let amount = try match.captureGroup(named: "amount", as: Int.self)
      switch try match.captureGroup(named: "direction") {
      case "up":
        self = .up(amount)
      case "down":
        self = .down(amount)
      case "forward":
        self = .forward(amount)
      default:
        throw AdventError.malformedInput
      }
    }
  }

  struct Position {
    let horizontal: Int
    let depth: Int

    static let start = Position(horizontal: 0, depth: 0)

    func moving(by movement: Movement) -> Position {
      switch movement {
      case .forward(let forward):
        return Position(horizontal: horizontal + forward, depth: depth)
      case .up(let up):
        return Position(horizontal: horizontal, depth: depth - up)
      case .down(let down):
        return Position(horizontal: horizontal, depth: depth + down)
      }
    }
  }

  struct AimedPosition {
    let horizontal: Int
    let depth: Int
    let aim: Int

    static let start = AimedPosition(horizontal: 0, depth: 0, aim: 0)

    func moving(by movement: Movement) -> AimedPosition {
      switch movement {
      case .forward(let forward):
        return AimedPosition(horizontal: horizontal + forward, depth: depth + aim * forward, aim: aim)
      case .up(let up):
        return AimedPosition(horizontal: horizontal, depth: depth, aim: aim - up)
      case .down(let down):
        return AimedPosition(horizontal: horizontal, depth: depth, aim: aim + down)
      }
    }
  }

  public static func run(input: String) throws -> Any {
    let movements = try Movement.matches(in: input)

    // Part One
    let finalBasicPosition = movements.reduce(Position.start) { $0.moving(by: $1) }
    // Part Two
    let finalAimedPosition = movements.reduce(AimedPosition.start) { $0.moving(by: $1) }

    return (
      partOne: finalBasicPosition.horizontal * finalBasicPosition.depth,  // 1962940
      partTwo: finalAimedPosition.horizontal * finalAimedPosition.depth  // 1813664422
    )
  }
}
