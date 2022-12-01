// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "Advent",
  platforms: [.macOS(.v11)],
  products: [
    // Products define the executables and libraries a package produces, and make them visible to other packages.
    .executable(name: "Advent", targets: ["AdventRunner"])
  ],
  dependencies: [
    // Dependencies declare other packages that this package depends on.
    .package(url: "https://github.com/apple/swift-algorithms.git", .branch("main")),
    .package(url: "https://github.com/apple/swift-argument-parser.git", .upToNextMajor(from: "0.4.3")),
    .package(url: "https://github.com/apple/swift-numerics.git", .upToNextMajor(from: "1.0.0")),
    .package(url: "https://github.com/apple/swift-collections.git", .upToNextMajor(from: "0.0.3")),
    // .package(url: "https://github.com/attaswift/BigInt.git", .upToNextMajor(from: "5.3.0")),
    .package(url: "https://github.com/alexandertar/LASwift.git", .upToNextMajor(from: "0.2.4")),
    .package(path: "../../Documents/Packages/Regex"),
  ],
  targets: [
    // Targets are the basic building blocks of a package. A target can define a module or a test suite.
    // Targets can depend on other targets in this package, and on products in packages this package depends on.
    .executableTarget(
      name: "AdventRunner",
      dependencies: [
        "Advent2020",
        "Advent2021",
        "Regex",
        .product(name: "ArgumentParser", package: "swift-argument-parser"),
      ]
    ),
    .target(
      name: "AdventCommon",
      dependencies: [
        "LASwift",
        "Regex",
      ]
    ),
    .target(
      name: "Advent2020",
      dependencies: [
        "AdventCommon",
        "Regex",
        .product(name: "Collections", package: "swift-collections"),
        .product(name: "Numerics", package: "swift-numerics"),
        .product(name: "Algorithms", package: "swift-algorithms"),
      ]
    ),
    .target(
      name: "Advent2021",
      dependencies: [
        "AdventCommon",
        "Regex",
        "LASwift",
        .product(name: "Collections", package: "swift-collections"),
        .product(name: "Numerics", package: "swift-numerics"),
        .product(name: "Algorithms", package: "swift-algorithms"),
      ]
    ),
  ]
)
