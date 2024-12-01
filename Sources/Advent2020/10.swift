import AdventCommon
import Algorithms
import Collections

/// https://adventofcode.com/2020/day/10
public struct Day10: AdventDay {

  public static let year = 2020
  public static let day = 10
  public static let answer = AdventAnswer(partOne: 2664, partTwo: 148098383347712)

  public static func solve(input: String) throws -> AdventAnswer {
    let joltages = Int.matches(in: input)
    let effectiveJoltages = joltages + [0, joltages.max()! + 3]

    return AdventAnswer(
      partOne: partOne(joltages: effectiveJoltages),
      partTwo: partTwo(joltages: effectiveJoltages)
    )
  }

  private static func partOne(joltages: [Int]) -> Int {
    let sortedJoltages = joltages.sorted(by: >)
    let differences = sortedJoltages.adjacentPairs().map(-)
    let groupedDifferences = Dictionary(grouping: differences) { $0 }.mapValues { $0.count }
    return groupedDifferences[1]! * groupedDifferences[3]!
  }

  private static func partTwo(joltages: [Int]) -> Int {
    var memo = [ArraySlice<Int>.Index: Int]()

    // DP, baby!
    func numberOfUniqueValidArrangementsOfAdapters(withSortedJoltages joltages: ArraySlice<Int>) -> Int {
      // Base Case
      guard joltages.count > 1 else { return 1 }

      let startIndex = joltages.startIndex

      // Memoization Case
      if let previousComputation = memo[startIndex] {
        return previousComputation
      }

      // Compute the indices which could come after `startIndex` in a valid arrangement of joltagee...
      // Do this by starting at `startIndex` + 1 and walking up the array slice, checking if
      // the difference between the joltages at `startIndex` and the test index is <= 3.
      var validNextIndices = [ArraySlice<Int>.Index]()
      var currentIndex = startIndex + 1
      while currentIndex < joltages.endIndex && joltages[currentIndex] - joltages[startIndex] <= 3 {
        validNextIndices.append(currentIndex)
        currentIndex += 1
      }

      // For each valid "next index", create a slice of the array from the index to the end and
      // recurse on *that* slice. The number of unique arrangements for this current slice is the
      // sum of the unique number of arrangements for each of the valid sub-slices!
      let subSolution = validNextIndices
        .map { joltages[$0...] }
        .map { numberOfUniqueValidArrangementsOfAdapters(withSortedJoltages: $0) }
        .reduce(0, +)

      // Memoize (:
      memo[startIndex] = subSolution

      return subSolution
    }

    let sortedJoltages = joltages.sorted(by: <)
    return numberOfUniqueValidArrangementsOfAdapters(withSortedJoltages: sortedJoltages[0...])
  }
}
