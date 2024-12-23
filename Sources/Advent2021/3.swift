import AdventCommon
import Algorithms
import Darwin
import Regex

public struct Day3: AdventDay {

  public static let year = 2021
  public static let day = 3
  public static let answer = AdventAnswer(partOne: 2003336, partTwo: 1877139)

  public static func solve(input: String) throws -> AdventAnswer {
    let reportNumbers = String.matches(in: input).compactMap { Int($0, radix: 2) }

    let (gamma, epsilon) = calculateGammaAndEpsilon(from: reportNumbers)
    let (o2, co2) = calculateO2AndCO2Ratings(from: reportNumbers)

    return AdventAnswer(
      partOne: gamma * epsilon,
      partTwo: o2 * co2
    )
  }

  // Part One
  private static func calculateGammaAndEpsilon(from reportNumbers: [Int]) -> (Int, Int) {
    let mostSignificantBit = reportNumbers.max()!.mostSignificantBit

    let gamma = (0..<mostSignificantBit).reversed().map {
      let divisor = 2.raisedTo(power: $0)
      let (_, zeroRows) = reportNumbers.partitioned { $0 & divisor == 0 }
      let multiplier = (zeroRows.count > reportNumbers.count / 2) ? 0 : 1
      return divisor * multiplier
    }.reduce(0, +)

    let epsilon = gamma ^ (2.raisedTo(power: mostSignificantBit) - 1)

    return (epsilon, gamma)
  }

  // Part Two
  private static func calculateO2AndCO2Ratings(from reportNumbers: [Int]) -> (Int, Int) {
    enum Keep {
      case zeros, ones
    }

    let mostSignificantBit = reportNumbers.max()!.mostSignificantBit

    func binarySearch(
      in numbers: [Int] = reportNumbers,
      byTestingBitAtOffsetFromMostSignificantBit offset: Int = mostSignificantBit - 1,
      test: (Int, Int, Int) -> Keep
    ) -> Int {
      // Base Case
      if numbers.count == 1, let solution = numbers.first { return solution }

      let divisor = 2.raisedTo(power: offset)
      let (oneRows, zeroRows) = numbers.partitioned { $0 & divisor == 0 }
      let remainingNumbers = test(zeroRows.count, oneRows.count, numbers.count) == .ones
        ? oneRows : zeroRows

      // Recursive Case
      return binarySearch(in: remainingNumbers, byTestingBitAtOffsetFromMostSignificantBit: offset - 1, test: test)
    }

    let o2 = binarySearch(
      in: reportNumbers,
      byTestingBitAtOffsetFromMostSignificantBit: mostSignificantBit - 1)
    { _, numOnes, numTotal in
      Double(numOnes) >= Double(numTotal) / 2.0 ? .ones : .zeros
    }

    let co2 = binarySearch(
      in: reportNumbers,
      byTestingBitAtOffsetFromMostSignificantBit: mostSignificantBit - 1)
    { numZeros, _, numTotal in
      Double(numZeros) <= Double(numTotal) / 2.0 ? .zeros : .ones
    }

    return (o2, co2)
  }
}

extension String: RegexRepresentable {
  public static let regex: Regex = ".*"
  
  public init?(match: Match) {
    self = String(match.text)
  }
}
