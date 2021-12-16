import AdventCommon
import Regex
import Darwin

public struct Day8: AdventDay {

  public static let day = 8

  enum Segment: String, CustomStringConvertible, CaseIterable {
    case a, b, c, d, e, f, g
    var description: String { rawValue }
  }

  typealias SegmentSet = Set<Segment>

  struct Input: RegexRepresentable {
    static let regex: Regex = #"(?<signals>[abcdefg ]+) \| (?<digits>[abcdefg ]+)"#

    let signals: [SegmentSet]
    let digits: [SegmentSet]

    init(match: Match) throws {
      /// - Returns: Segment set from a string representing a segment set, i.e. `"abdf"` -> `[.a, .b, .d, .f]`
      func makeSegmentSet(rawSegment: String) -> SegmentSet {
        rawSegment
          .map { Segment(rawValue: String($0))! }
          .reduce(into: []) { $0.insert($1) }
      }

      self.signals = try match.captureGroup(named: "signals")
        .components(separatedBy: .whitespaces)
        .map(makeSegmentSet(rawSegment:))

      self.digits = try match.captureGroup(named: "digits")
        .components(separatedBy: .whitespaces)
        .map(makeSegmentSet(rawSegment:))
    }
  }

  public static func run(input: String) throws -> Any {
    let outputs = try Input.matches(in: input).map(calculateOutput(fromInput:))
    return (
      partOne: outputs.flatMap(\.digits).filter { [1, 4, 7, 8].contains($0) }.count,  // 247
      partTwo: outputs.map(\.value).reduce(0, +)  // 933305
    )
  }

  static func calculateOutput(fromInput input: Input) -> (digits: [Int], value: Int) {
    let digitMap = makeDigitMap(signals: input.signals)
    let outputDigits = input.digits.map { digitMap[$0]! }
    let outputValue =
      10.raisedTo(power: 3) * outputDigits[0] +
      10.raisedTo(power: 2) * outputDigits[1] +
      10.raisedTo(power: 1) * outputDigits[2] +
      10.raisedTo(power: 0) * outputDigits[3]

    return (outputDigits, outputValue)
  }

  /// - Returns: A map whose keys are sets of segments and values are the integer digit that set of segments represents.
  private static func makeDigitMap(signals: [Set<Segment>]) -> [SegmentSet: Int] {
    // The only digit with 2 segments is "1"
    let one = signals.first { $0.count == 2 }!
    // The only digit with 4 segments is "4"
    let four = signals.first { $0.count == 4 }!
    // The only digit with 3 segments is "7"
    let seven = signals.first { $0.count == 3 }!
    // The only digit with 7 segments is "8"
    let eight = signals.first { $0.count == 7 }!

    // The set of 5-segment digits (2, 3, 5).
    let fiveSegmentSignals = signals.filter { $0.count == 5 }
    // The set of 6-segment digits (0, 6, 9).
    let sixSegmentSignals = signals.filter { $0.count == 6 }

    // The only 6-segment digit that doesn't contain both segments of "1" is "6".
    let six = sixSegmentSignals.first { !$0.isSuperset(of: one) }!
    // The only segment of "1" in "6" is "f".
    let f = six.intersection(one).first!
    // The other segment of "1" that isn't "f" is "c".
    let c = one.subtracting([f]).first!

    // The only segment in "7" but not in "1" is "a".
    let a = seven.subtracting(one).first!
    // The only three segments that appear in all of the 5-segment digits are "a", "d", and "g".
    let adg = Set(Segment.allCases).filter { segment in
      fiveSegmentSignals.allSatisfy { signal in
        signal.contains(segment)
      }
    }
    // Remove "a" to get the set of "d" and "g".
    let dg = adg.subtracting([a])
    // Of "d" and "g", only "g" is in all 6-segment digits.
    let g = dg.first { segment in
      sixSegmentSignals.allSatisfy { signal in
        signal.contains(segment)
      }
    }!
    // Subtract "g" from "d/g" to get "d".
    let d = dg.subtracting([g]).first!

    // The only unknown segment in "4" is "b".
    let b = four.subtracting([c, d, f]).first!
    // The remaining unknown segment is "e".
    let e = eight.subtracting([a, b, c, d, f, g]).first!

    // Now that we know all the segments, construct the remaining unknown digits.
    let zero: SegmentSet = [a, b, c, e, f, g]
    let two: SegmentSet = [a, c, d, e, g]
    let three: SegmentSet = [a, c, d, f, g]
    let five: SegmentSet = [a, b, d, f, g]
    let nine: SegmentSet = [a, b, c, d, f, g]

    // Create a map from a set of segments to it's actual integer value.
    let keyValuePairs = zip(
      [zero, one, two, three, four, five, six, seven, eight, nine],
      0...9
    )

    return [SegmentSet: Int](uniqueKeysWithValues: keyValuePairs)
  }
}
