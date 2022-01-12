// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "DripCore",
  platforms: [.iOS(.v15)],
  products: [
    // Products define the executables and libraries a package produces, and make them visible to other packages.
    .library(
      name: "DripCore",
      targets: ["DripCore"]
    )
  ],
  dependencies: [
    .package(url: "https://github.com/muukii/Brightroom", branch: "main"),
    .package(url: "https://github.com/muukii/MondrianLayout", from: "0.8.0"),
    .package(url: "https://github.com/muukii/FluidInterfaceKit", branch: "main"),
    .package(url: "https://github.com/muukii/CompositionKit", branch: "main"),
    .package(url: "https://github.com/muukii/ResultBuilderKit", branch: "main"),
    .package(url: "https://github.com/muukii/TypedTextAttributes", from: "1.3.0"),
    .package(url: "https://github.com/muukii/EmbeddedStringsKit", from: "0.1.0"),
    .package(name: "Verge", url: "https://github.com/VergeGroup/Verge", branch: "main"),
    .package(url: "https://github.com/VergeGroup/Wrap", from: "3.0.0"),
  ],
  targets: [
    // Targets are the basic building blocks of a package. A target can define a module or a test suite.
    // Targets can depend on other targets in this package, and on products in packages this package depends on.
    .target(
      name: "DripCore",
      dependencies: [
        .product(name: "BrightroomEngine", package: "Brightroom"),
        .product(name: "BrightroomUI", package: "Brightroom"),
        "MondrianLayout",
        "FluidInterfaceKit",
        "Verge",
        "ResultBuilderKit",
        .product(name: "CompositionKit", package: "CompositionKit"),
        .product(name: "CompositionKitVerge", package: "CompositionKit"),
        "TypedTextAttributes",
        "Wrap",
        "AppResource",
      ]
    ),
    .target(
      name: "AppResource",
      dependencies: ["EmbeddedStringsKit"]
    ),
    .testTarget(
      name: "CoreTests",
      dependencies: ["DripCore"]
    ),
  ]
)
