import AdventCommon
import Foundation
import Regex

/// https://adventofcode.com/2022/day/7
public struct Day7: AdventDay {

  public static let year = 2022
  public static let day = 7
  
  /// Representation of a line of input.
  enum InputLine {
    case ls
    case cd(directoryName: String)
    case directory(directoryName: String)
    case file(size: Int, name: String)
    
    enum Regexes {
      static let ls: Regex = #"\$ ls"#
      static let cd: Regex = #"\$ cd (?<directory>.+)"#
      static let directory: Regex = #"dir (?<name>\w+)"#
      static let file: Regex = #"(?<size>\d+) (?<name>.+)"#
    }
    
    init(input: String) throws {
      if Regexes.ls.hasMatch(in: input) {
        self = .ls
      } else if let match = Regexes.cd.firstMatch(in: input) {
        let directoryName = try match.captureGroup(named: "directory")
        self = .cd(directoryName: directoryName)
      } else if let match = Regexes.directory.firstMatch(in: input) {
        let name = try match.captureGroup(named: "name")
        self = .directory(directoryName: name)
      } else if let match = Regexes.file.firstMatch(in: input) {
        let size = try match.captureGroup(named: "size", as: Int.self)
        let name = try match.captureGroup(named: "name")
        self = .file(size: size, name: name)
      } else {
        throw ParsingError(input: input)
      }
    }
  }
  
  /// Representation of a directory.
  class Directory: Hashable {
    let name: String
    let parent: Directory?
    var files = [File]()
    var subdirectories = [Directory]()
    
    init(name: String, parent: Directory?) {
      self.name = name
      self.parent = parent
    }
    
    var size: Int {
      self.files.map(\.size).reduce(0, +) + self.subdirectories.map(\.size).reduce(0, +)
    }
    
    subscript(_ subdirectory: String) -> Directory? {
      self.subdirectories.first { $0.name == subdirectory }
    }
    
    static func == (lhs: Directory, rhs: Directory) -> Bool {
      lhs.name == rhs.name && lhs.parent == rhs.parent
    }
    
    func hash(into hasher: inout Hasher) {
      hasher.combine(self.name)
      hasher.combine(self.parent)
    }
  }

  /// Representation of a file.
  struct File {
    let name: String
    let size: Int
  }

  public static func solve(input: String) throws -> AdventAnswer {
    let lines = try input.components(separatedBy: .newlines).filter { !$0.isEmpty }.map(InputLine.init(input:))
    
    let rootDirectory = Directory(name: "/", parent: nil)
    var directories = Set<Directory>()
    var currentWorkingDirectory = rootDirectory
    
    for line in lines {
      switch line {
      case .ls: break
      
      case .cd(let directoryName):
        if directoryName == ".." {
          currentWorkingDirectory = currentWorkingDirectory.parent ?? rootDirectory
        } else if directoryName == "/" {
          currentWorkingDirectory = rootDirectory
        } else {
          guard let existingDirectory = currentWorkingDirectory[directoryName] else { fatalError("how u do") }
          currentWorkingDirectory = existingDirectory
        }
      
      case .directory(let directoryName):
        if let existingDirectory = currentWorkingDirectory[directoryName] {
          currentWorkingDirectory.subdirectories.append(existingDirectory)
        } else {
          let directory = Directory(name: directoryName, parent: currentWorkingDirectory)
          directories.insert(directory)
          currentWorkingDirectory.subdirectories.append(directory)
        }
       
      case .file(let size, let name):
        let file = File(name: name, size: size)
        currentWorkingDirectory.files.append(file)
      }
    }
        
    let spaceNeededToClear = 30000000 - (70000000 - rootDirectory.size)
    return AdventAnswer(
      partOne: directories.map { $0.size }.filter { $0 <= 100000 }.reduce(0, +),  // 1443806
      partTwo: directories.map { $0.size }.filter { $0 >= spaceNeededToClear }.sorted(by: <).first!  // 942298
    )
  }
}

struct ParsingError: Error {
  let input: String
}
