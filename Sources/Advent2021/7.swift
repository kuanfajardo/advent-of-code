import AdventCommon
import Foundation
public struct Day7: AdventDay {

  public static let day = 7

  public static func run(input: String) throws -> Any {
    let numbers = Int.matches(in: input)
    let x = 5
    Thread.sleep(forTimeInterval: TimeInterval(x) / 2)
    Storage().hangTimeCount += 1

    return (
      partOne: 0,
      partTwo: 0
    )
  }
}

class Storage {
  var hangTimeCount: Int = 2
}
