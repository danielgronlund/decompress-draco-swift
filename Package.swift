// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DracoDecompressSwift",
    products: [
        .library(
            name: "DracoDecompressSwift",
            targets: ["DracoDecompressSwift"]),
    ],
    dependencies: [
      .package(url: "git@github.com:danielgronlund/DracoSwift.git", exact: .init(1, 0, 0))
    ],
    targets: [
        .target(
          name: "DracoDecompressSwift",
          dependencies: ["DracoDecompressObjc"],
          cSettings: [.headerSearchPath("Include/")]
        ),
        .target(name: "DracoDecompressObjc",
                dependencies: [.product(name: "DracoSwift", package: "DracoSwift")],
                publicHeadersPath: "Include"),
    ],
    cxxLanguageStandard: .cxx17
)
