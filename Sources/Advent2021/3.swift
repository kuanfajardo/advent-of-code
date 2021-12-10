import AdventCommon
import Algorithms
import Darwin

public struct Day3: AdventDay {

  public static let day = 3

  public static func run(input: String) throws -> Any {
    let reportNumbers = input.components(separatedBy: "\n").compactMap { Int($0, radix: 2) }

    let (gamma, epsilon) = calculateGammaAndEpsilon(from: reportNumbers)
    let (o2, co2) = calculateO2AndCO2Ratings(from: reportNumbers)

    return (
      partOne: gamma * epsilon,  // 2003336
      partTwo: o2 * co2  // 1877139
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
