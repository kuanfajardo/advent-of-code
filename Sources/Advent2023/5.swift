//
//  5.swift
//
//
//  Created by Juan Fajardo on 12/12/23.
//

import AdventCommon
import RegexBuilder

fileprivate typealias Regex = _StringProcessing.Regex

public struct Day5: AdventDay {
  
  public static let year = 2023
  
  public static let day = 5
  
  struct Map {
    // Represents an entry in a map.
    struct Entry {
      let destinationRangeStart: Int
      let sourceRangeStart: Int
      let rangeLength: Int
      
      var sourceRange: Range<Int> {
        self.sourceRangeStart..<(self.sourceRangeStart + self.rangeLength)
      }
    }
    
    private let entries: [Entry]
    
    init(entries: [Entry]) {
      self.entries = entries
    }
    
    subscript(key: Int) -> Int {
      guard 
        let entry = self.entries.first(where: { $0.sourceRange.contains(key) })
      else {
        return key
      }
      return entry.destinationRangeStart + (key - entry.sourceRangeStart)
    }
  }
  
  public static func solve(input: String) throws -> AdventAnswer {
    let seedsRef = Reference(Substring.self)
    let seedToSoilRef = Reference(Substring.self)
    let soilToFertilizerRef = Reference(Substring.self)
    let fertilizerToWaterRef = Reference(Substring.self)
    let waterToLightRef = Reference(Substring.self)
    let lightToTemperatureRef = Reference(Substring.self)
    let temperatureToHumidityRef = Reference(Substring.self)
    let humidityToLocationRef = Reference(Substring.self)
    
    let regex = Regex {
      "seeds:"
      Capture(OneOrMore(.any), as: seedsRef)

      "seed-to-soil map:"
      Capture(OneOrMore(.any), as: seedToSoilRef)
      
      "soil-to-fertilizer map:"
      Capture(OneOrMore(.any), as: soilToFertilizerRef)
      
      "fertilizer-to-water map:"
      Capture(OneOrMore(.any), as: fertilizerToWaterRef)
      
      "water-to-light map:"
      Capture(OneOrMore(.any), as: waterToLightRef)
      
      "light-to-temperature map:"
      Capture(OneOrMore(.any), as: lightToTemperatureRef)
      
      "temperature-to-humidity map:"
      Capture(OneOrMore(.any), as: temperatureToHumidityRef)
      
      "humidity-to-location map:"
      Capture(OneOrMore(.any), as: humidityToLocationRef)
    }
    
    guard let match = try regex.firstMatch(in: input) else {
      throw AdventError.malformedInput(input: input)
    }
    
    let seeds = match[seedsRef]
      .trimmingCharacters(in: .whitespacesAndNewlines)
      .split(separator: " ")
      .map { Int($0)! }
    
    print(seeds)
    
    let seedToSoilMap = try self.makeMap(rawMapString: match[seedToSoilRef])
    let soilToFertilizerMap = try self.makeMap(rawMapString: match[soilToFertilizerRef])
    let fertilizerToWaterMap = try self.makeMap(rawMapString: match[fertilizerToWaterRef])
    let waterToLightMap = try self.makeMap(rawMapString: match[waterToLightRef])
    let lightToTemperatureMap = try self.makeMap(rawMapString: match[lightToTemperatureRef])
    let temperatureToHumidityMap = try self.makeMap(rawMapString: match[temperatureToHumidityRef])
    let humidityToLocationMap = try self.makeMap(rawMapString: match[humidityToLocationRef])
    
    let initialSeedLocations = (1...1_000_000)
      .map { seedToSoilMap[$0] }
      .map { soilToFertilizerMap[$0] }
      .map { fertilizerToWaterMap[$0] }
      .map { waterToLightMap[$0] }
      .map { lightToTemperatureMap[$0] }
      .map { temperatureToHumidityMap[$0] }
      .map { humidityToLocationMap[$0] }

    return AdventAnswer(
      partOne: initialSeedLocations.min()!,
      partTwo: 3
    )
  }
  
  private static func makeMap(rawMapString: Substring) throws -> Map {
    let entries: [Map.Entry] = try String(rawMapString)
      .trimmingCharacters(in: .whitespacesAndNewlines)
      .components(separatedBy: .newlines)
      .map { (entry: String) -> Map.Entry in
        let destinationStartRef = Reference(Int.self)
        let sourceStartRef = Reference(Int.self)
        let rangeLengthRef = Reference(Int.self)
        
        let entryRegex = Regex {
          TryCapture(OneOrMore(.digit), as: destinationStartRef) { Int($0) }
          " "
          TryCapture(OneOrMore(.digit), as: sourceStartRef) { Int($0) }
          " "
          TryCapture(OneOrMore(.digit), as: rangeLengthRef) { Int($0) }
        }
        
        guard let match = try entryRegex.wholeMatch(in: entry) else {
          throw AdventError.malformedInput(input: entry)
        }
        
        return Map.Entry(
          destinationRangeStart: match[destinationStartRef],
          sourceRangeStart: match[sourceStartRef],
          rangeLength: match[rangeLengthRef]
        )
      }
    return Map(entries: entries)
  }
  
//  private func make
}
