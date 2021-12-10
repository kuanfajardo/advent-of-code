import AdventCommon
import Regex

// Can't nest protocols :(
protocol PassportField: CaseIterable {
  var regex: Regex { get }
  func validate(match: Match) -> Bool
}

/// https://adventofcode.com/2020/day/4
public struct Day4: AdventDay {
  
  public static let day = 4
  
  // MARK: Models
  
  // Fields for Part One
  enum BasicField: String, PassportField {
    case byr, iyr, eyr, hgt, hcl, ecl, pid
    
    var regex: Regex { Regex(pattern: "\(rawValue):") }
    
    func validate(match: Match) -> Bool { true }
  }
  
  // Fields for Part Two
  enum StrictField: String, PassportField {
    case byr = #"byr:(?<year>[0-9]{4}\b)"#
    case iyr = #"iyr:(?<year>[0-9]{4}\b)"#
    case eyr = #"eyr:(?<year>[0-9]{4}\b)"#
    case hgt = #"hgt:(?<height>[0-9]{2,3})(?<unit>(in|cm))\b"#
    case hcl = #"hcl:#[0-9a-f]{6}\b"#
    case ecl = #"ecl:(amb|blu|brn|gry|grn|hzl|oth)\b"#
    case pid = #"pid:[0-9]{9}\b"#
    
    var regex: Regex { Regex(pattern: rawValue) }
    
    func validate(match: Match) -> Bool {
      do {
        switch self {
        case .byr:
          let year = try match.captureGroup(named: "year", as: Int.self)
          return (1920...2002).contains(year)
          
        case .iyr:
          let year = try match.captureGroup(named: "year", as: Int.self)
          return (2010...2020).contains(year)
          
        case .eyr:
          let year = try match.captureGroup(named: "year", as: Int.self)
          return (2020...2030).contains(year)
          
        case .hgt:
          let height = try match.captureGroup(named: "height", as: Int.self)
          switch try match.captureGroup(named: "unit") {
          case "in": return (59...76).contains(height)
          case "cm": return (150...193).contains(height)
          default: return false
          }
          
        case .hcl, .ecl, .pid:
          // No extra validation needed
          return true
        }
      } catch {
        return false
      }
    }
  }
  
  public static func run(input: String) throws -> Any {
    return (
      partOne: numValidPassports(in: input, fields: BasicField.self),  // 182
      partTwo: numValidPassports(in: input, fields: StrictField.self)  // 109
    )
  }
  
  static func numValidPassports<Fields: PassportField>(in batch: String, fields: Fields.Type) -> Int {
    let passportEntryRegex: Regex = #"(?ms)(?<entry>.+?)\n\n"#
    let passportEntries = passportEntryRegex.matches(in: batch).map { $0["entry"]! }
    
    return passportEntries.filter { entry in
      Fields.allCases.allSatisfy {
        guard let match = $0.regex.firstMatch(in: entry) else { return false }
        return $0.validate(match: match)
      }
    }.count
  }
}
