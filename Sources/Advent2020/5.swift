import AdventCommon
import Algorithms
import Regex

/// https://adventofcode.com/2020/day/5
public struct Day5: AdventDay {

  public static let day = 5

  struct Seat: RegexRepresentable {

    let row: Int
    let column: Int

    static let regex: Regex = #"(?m)^(?<rowSpec>[FB]{7})(?<columnSpec>[LR]{3})$"#

    init(match: Match) {
      let binaryRowString = match["rowSpec"]!
        .replacingOccurrences(of: "F", with: "0")
        .replacingOccurrences(of: "B", with: "1")
      let binaryColumnString = match["columnSpec"]!
        .replacingOccurrences(of: "L", with: "0")
        .replacingOccurrences(of: "R", with: "1")

      self.row = Int(binaryRowString, radix: 2)!
      self.column = Int(binaryColumnString, radix: 2)!
    }
  }

  public static func run(input: String) throws -> Any {
    let seatIDs = Seat.matches(in: input).map { $0.row * 8 + $0.column }
    return (
      partOne: seatIDs.max()!,  // 874
      partTwo: missingSeatID(among: seatIDs)  // 594
    )
  }


  private static func missingSeatID(among seatIDs: [Int]) -> Int {
    return seatIDs.sorted().adjacentPairs().firstNonNil { pair in
      if pair.0 + 1 == pair.1 { return nil }
      else { return pair.0 + 1 }
    }!
  }
}

