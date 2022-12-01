import AdventCommon
import Regex
import Collections

public struct Day14: AdventDay {

  public static let year = 2021
  public static let day = 14

  struct Pair: Hashable, CustomStringConvertible {
    let left: Character
    let right: Character

    var description: String { "\(left)\(right)" }
  }

  struct Rulebook: RegexRepresentableCollection {
    private let insertionRules: [Pair: Character]

    static let elementRegex: Regex = #"(?<left>\w)(?<right>\w+) -> (?<insertion>\w)"#

    init(matches: [Match]) throws {
      self.insertionRules = try matches.reduce(into: [:]) { map, match in
        let pair = Pair(
          left: try match.captureGroup(named: "left", as: Character.self),
          right: try match.captureGroup(named: "right", as: Character.self)
        )
        let insertion = try match.captureGroup(named: "insertion", as: Character.self)

        map[pair] = insertion
      }
    }

    subscript(pair: Pair) -> Character {
      insertionRules[pair]!
    }
  }

  public static func solve(input: String) throws -> AdventAnswer {
    let firstNewlineIndex = input.firstIndex(of: "\n")!
    let template = Array(input.prefix(upTo: firstNewlineIndex))
    let rulebook = try Rulebook.match(in: input)

    return AdventAnswer(
      partOne: differenceBetweenMaxAndMinCounts(
        of: elementCounts(afterExpandingTemplate: template, nTimes: 10, using: rulebook)
      ),  // 2899
      partTwo: differenceBetweenMaxAndMinCounts(
        of: elementCounts(afterExpandingTemplate: template, nTimes: 40, using: rulebook)
      )  // 3528317079545
    )
  }

  private static func differenceBetweenMaxAndMinCounts<E: Hashable>(of bag: Bag<E>) -> Int {
    let minMax = bag.minAndMax { $0.value < $1.value }!
    return minMax.max.value - minMax.min.value
  }

  private static func elementCounts(
    afterExpandingTemplate template: [Character], nTimes n: Int, using rulebook: Rulebook) -> Bag<Character>
  {
    // Represent polymer by its pairs, i.e. a bag of pair counts.
    var pairCounts = Bag(template.adjacentPairs().map(Pair.init(left:right:)))

    // Polymerization
    var i = 0
    while i < n {
      pairCounts = pairCounts.reduce(into: [:]) { (counts, element) in
        let (pair, count) = element

        let insertion = rulebook[pair]

        let leftPair = Pair(left: pair.left, right: insertion)
        let rightPair = Pair(left: insertion, right: pair.right)

        counts.add(leftPair, count: count)
        counts.add(rightPair, count: count)
      }

      i +=  1
    }

    // If we make a bag out of the elements in every pair, we end up double-counting each element
    // except the first and last one (b/c each element is in 2 pairs!). So, to get the final element
    // count...

    // 1. Make the bag of elements from pairs...
    var doubleCountedElements = pairCounts.reduce(into: Bag<Character>()) { bag, pairBag in
      bag.add(pairBag.key.left, count: pairBag.value)
      bag.add(pairBag.key.right, count: pairBag.value)
    }

    // 2. Add a single count of the first and last elements...
    doubleCountedElements.add(template.first!)
    doubleCountedElements.add(template.last!)

    // 3. And now that each element is counted twice, we make a new bag with the same elements but
    // with their counts halved!
    let elementCounts: Bag<Character> = doubleCountedElements.reduce(into: [:]) {
      $0.add($1.key, count: $1.value / 2)
    }
    return elementCounts
  }
}
