import AdventCommon
import Algorithms
import Regex

/// https://adventofcode.com/2020/day/11
public struct Day11: AdventDay {

  public static let year = 2020
  public static let day = 11
  public static let answer = AdventAnswer(partOne: 2470, partTwo: 2259)

  struct SeatingChart: Equatable, CustomStringConvertible {

    // MARK: Sub-Types

    enum Seat: Character, CustomStringConvertible, RegexRepresentable {
      case empty = "L"
      case occupied = "#"
      case floor = "."

      var description: String { String(rawValue) }

      // MARK: RegexRepresentable

      static let regex: Regex = #"(L|\.|#)"#

      init?(match: Match) {
        guard let rawValue = match.text.first else { return nil }
        self.init(rawValue: rawValue)!
      }
    }

    typealias Coordinate = (x: Int, y: Int)

    // MARK: Stored Properties

    let rows: [[Seat]]

    // MARK: Computed Properties

    var numRows: Int { rows.count }
    var numColumns: Int { rows.first!.count }

    // MARK: Coordinate API

    subscript(coordinate: Coordinate) -> Seat {
      rows[coordinate.y][coordinate.x]
    }

    func isValidCoordinate(_ coordinate: Coordinate) -> Bool {
      (0..<numColumns).contains(coordinate.x) && (0..<numRows).contains(coordinate.y)
    }

    // MARK: CustomStringConvertible

    var description: String {
      String(rows.map { $0.map(\.rawValue) }.joined(separator: "\n"))
    }
  }

  public static func solve(input: String) throws -> AdventAnswer {
    let rowRegex: Regex = #"(?m)^[L\.]+$"#
    let rows = rowRegex.matches(in: input).map { match in
      SeatingChart.Seat.matches(in: String(match.text))
    }

    let initialChart = SeatingChart(rows: rows)

    return AdventAnswer(
      partOne: numberOfStableOccupiedSeats(
        startingFrom: initialChart,
        neighboringSeatsGivenBy: directNeighborStates(of:in:),
        maxNumberOfOccupiedNeighbors: 4
      ),

      partTwo: numberOfStableOccupiedSeats(
        startingFrom: initialChart,
        neighboringSeatsGivenBy: statesOfNearestSeatsInLineOfSight(from:in:),
        maxNumberOfOccupiedNeighbors: 5
      )
    )
  }

  // MARK: Neighbor-Visiting Logic

  // Used for Part 1
  private static func directNeighborStates(of coordinate: SeatingChart.Coordinate, in chart: SeatingChart) -> [SeatingChart.Seat] {
    product(-1...1, -1...1)
      .map { (x: coordinate.x + $0, y: coordinate.y + $1) }
      .filter { $0 != coordinate }
      .filter { chart.isValidCoordinate($0) }
      .map { chart[$0] }
  }

  // Used for Part 2
  private static func statesOfNearestSeatsInLineOfSight(from coordinate: SeatingChart.Coordinate, in chart: SeatingChart) -> [SeatingChart.Seat] {
    product(-1...1, -1...1).compactMap { delta in
      // Skip (0, 0) delta since increasing by (0, 0) will never go out-of-bounds, causing
      // infinite loop.
      guard delta != (0, 0) else { return nil }

      // Find the nearest seat (empty or occupied) in the direction of delta, if it exists.
      var currentCoordinate = (x: coordinate.x + delta.0, y: coordinate.y + delta.1)
      while chart.isValidCoordinate(currentCoordinate) {
        let state = chart[currentCoordinate]
        if state != .floor {
          return state
        }
        currentCoordinate = (currentCoordinate.x + delta.0, currentCoordinate.y + delta.1)
      }

      // We reached the edge of the chart and didn't find any seat.
      return nil
    }
  }

  // MARK: Stable Seating Logic

  private static func numberOfStableOccupiedSeats(
    startingFrom initialChart: SeatingChart,
    neighboringSeatsGivenBy neighborBlock: (SeatingChart.Coordinate, SeatingChart) -> [SeatingChart.Seat],
    maxNumberOfOccupiedNeighbors: Int
  ) -> Int {
    //
    func nextSeatingChart(applyingRoundOfRulesOn seatingChart: SeatingChart) -> SeatingChart {
      let newStates = product(0..<seatingChart.numRows, 0..<seatingChart.numColumns).map { (y, x) -> SeatingChart.Seat in
        let coordinate = (x, y)
        let numOccupiedNeighbors = neighborBlock(coordinate, seatingChart).filter { $0 == .occupied }.count

        let currentState = seatingChart[coordinate]
        switch currentState {
        case .empty where numOccupiedNeighbors == 0:
          return .occupied
        case .occupied where numOccupiedNeighbors >= maxNumberOfOccupiedNeighbors:
          return .empty
        default:
          return currentState
        }
      }
      let newRows = newStates.chunks(ofCount: seatingChart.numColumns).map(Array.init)
      let newChart = SeatingChart(rows: newRows)
      return newChart
    }

    func computeStableSeatingChart() -> SeatingChart {
      var currentChart = initialChart
      var i = 0
      repeat {
        let newChart = nextSeatingChart(applyingRoundOfRulesOn: currentChart)
        if newChart == currentChart {
          return newChart
        }
        currentChart = newChart
        i += 1
      } while true
    }

    let stableChart = computeStableSeatingChart()
    return stableChart.rows.flatMap { $0 }.filter { $0 == .occupied }.count
  }
}

