//
//  Regex_Old+Additions.swift
//
//  This file adds some things to the old Regex package used in the earlier years (before Regex built-ins in Swift)
//
//  Created by Juan Fajardo on 11/30/24.
//

import Regex

public enum MatchError: Error {
  case missingCaptureGroup(String)
  case badRawValue(String)
}

extension Match {
  /// Retrieves the match for a named capture group.
  ///
  /// - Parameter name: The name of the capture group to return.
  /// - Returns: The string matching the capture group named `name`.
  /// - Throws: If the capture group doesn't exist.
  public func captureGroup(named name: String) throws -> String {
    guard let value = self[name] else {
      throw MatchError.missingCaptureGroup(name)
    }
    return value
  }

  ///
  public func captureGroup<T: ExpressibleByCaptureGroup>(named name: String, as: T.Type) throws -> T {
    let rawValue = try self.captureGroup(named: name)
    guard let value = T.init(captureGroup: rawValue) else { throw MatchError.badRawValue(rawValue) }
    return value
  }
}

