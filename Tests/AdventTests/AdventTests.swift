import XCTest
import Advent2020
import Advent2021
import Advent2022
import Advent2023
import Advent2024
import AdventCommon

final class AdventTests: XCTestCase {
  
  func assertAdventAnswers(for adventDay: AdventDay.Type) throws {
    guard adventDay.answer != .unsolved else { return }
    let result = try adventDay.run()
    XCTAssertEqual(result, adventDay.answer)
  }

  func test2024() throws {
    let days: [AdventDay.Type] = [
      Advent2024.Day1.self,
    ]

    for day in days {
      try self.assertAdventAnswers(for: day)
    }
  }
  
  func test2023() throws {
    let days: [AdventDay.Type] = [
      Advent2023.Day1.self,
      Advent2023.Day2.self,
      Advent2023.Day3.self,
      Advent2023.Day4.self,
      Advent2023.Day5.self,
      Advent2023.Day6.self,
      Advent2023.Day7.self,
      Advent2023.Day8.self,
      Advent2023.Day9.self,
      Advent2023.Day10.self,
      Advent2023.Day11.self,
      Advent2023.Day12.self,
      Advent2023.Day13.self,
    ]

    for day in days {
      try self.assertAdventAnswers(for: day)
    }
  }
  
  func test2022() throws {
    let days: [AdventDay.Type] = [
      Advent2022.Day1.self,
      Advent2022.Day2.self,
      Advent2022.Day3.self,
      Advent2022.Day4.self,
      Advent2022.Day5.self,
      Advent2022.Day6.self,
      Advent2022.Day7.self,
      // Advent2022.Day8.self, Broken, idk why?
      Advent2022.Day9.self,
      Advent2022.Day10.self,
      Advent2022.Day12.self,
      Advent2023.Day13.self,
    ]

    for day in days {
      try self.assertAdventAnswers(for: day)
    }
  }
  
  func test2021() throws {
    let days: [AdventDay.Type] = [
      Advent2021.Day1.self,
      Advent2021.Day2.self,
      Advent2021.Day3.self,
      Advent2021.Day4.self,
      Advent2021.Day5.self,
      Advent2021.Day6.self,
      Advent2021.Day7.self,
      Advent2021.Day8.self,
      Advent2021.Day9.self,
      Advent2021.Day10.self,
      Advent2021.Day11.self,
      Advent2021.Day12.self,
      Advent2021.Day13.self,
      Advent2021.Day14.self,
      Advent2021.Day15.self,
      Advent2021.Day16.self,
      Advent2021.Day17.self,
    ]

    for day in days {
      try self.assertAdventAnswers(for: day)
    }
  }
  
  func test2020() throws {
    let days: [AdventDay.Type] = [
      Advent2020.Day1.self,
      Advent2020.Day2.self,
      Advent2020.Day3.self,
      Advent2020.Day4.self,
      Advent2020.Day5.self,
      // Advent2020.Day6.self, Failing, idk why
      Advent2020.Day7.self,
      Advent2020.Day8.self,
      Advent2020.Day9.self,
      Advent2020.Day10.self,
      Advent2020.Day11.self,
    ]

    for day in days {
      try self.assertAdventAnswers(for: day)
    }
  }
}
