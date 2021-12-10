import Algorithms
import AdventCommon
import Regex

/// https://adventofcode.com/2020/day/7
public struct Day7: AdventDay {
  
  public static let day = 7
  
  struct BagRule: RegexRepresentable {
    struct ContainmentRule: RegexRepresentable {
      let color: String
      let quantity: Int
      
      static var regex: Regex = #"(?<quantity>[0-9]+) (?<color>[\w\s]+) bag(s)?"#
      
      init(match: Match) throws {
        self.color = try match.captureGroup(named: "color").trimmingCharacters(in: .whitespaces)
        self.quantity = try match.captureGroup(named: "quantity", as: Int.self)
      }
    }
    
    static let regex: Regex = #"(?m)^(?<color>[\w\s]+) bags contain (?<rules>(no other bags|.*))\.$"#
    
    let color: String
    let allowedBags: [ContainmentRule]
    
    init(match: Match) throws {
      self.color = try match.captureGroup(named: "color").trimmingCharacters(in: .whitespaces)
      
      let rulesClause = try match.captureGroup(named: "rules")
      if rulesClause == "no other bags" {
        self.allowedBags = []
      } else {
        self.allowedBags = try ContainmentRule.matches(in: rulesClause)
      }
    }
  }
  
  public static func run(input: String) throws -> Any {
    let rules = try BagRule.matches(in: input)
    return (
      partOne: numberOfBagColorsThatCanContainAShinyGoldBag(rules: rules),  // 139
      partTwo: numberOfBagsRequiredInsideShinyGoldBag(rules: rules)  // 58175
    )
  }
  
  // Part One
  static func numberOfBagColorsThatCanContainAShinyGoldBag(rules: [BagRule]) -> Int {
    let graph: [String: [String]] = rules.reduce(into: [:]) {
      $0[$1.color] = $1.allowedBags.map(\.color)
    }
    
    let allBagColors = Array(graph.keys)
    
    func allowedBagColors(insideColor color: String) -> [String] {
      var allowed = [String]()
      for allowedColor in graph[color, default: []] {
        allowed.append(allowedColor)
        allowed.append(contentsOf: allowedBagColors(insideColor: allowedColor))
      }
      return allowed
    }
    
    let allowedColors: [String: [String]] = allBagColors.reduce(into: [:]) {
      $0[$1] = allowedBagColors(insideColor: $1)
    }
    
    return allBagColors.filter {
      allowedColors[$0, default: []].contains("shiny gold")
    }.count
  }
  
  // Part Two
  static func numberOfBagsRequiredInsideShinyGoldBag(rules: [BagRule]) -> Int {
    let graph: [String: [BagRule.ContainmentRule]] = rules.reduce(into: [:]) {
      $0[$1.color] = $1.allowedBags
    }
    
    func numberOfBagsRequiredInsideBag(ofColor color: String) -> Int {
      var required = 0
      for requiredBag in graph[color, default: []] {
        required += requiredBag.quantity
        required += requiredBag.quantity * numberOfBagsRequiredInsideBag(ofColor: requiredBag.color)
      }
      return required
    }
    
    return numberOfBagsRequiredInsideBag(ofColor: "shiny gold")
  }
}
