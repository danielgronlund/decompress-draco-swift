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
    .package(url: "git@github.com:danielgronlund/draco.git", revision: "a16d61bd471e8132501f82d712a8ae88167023b1")
  ],
  targets: [
    .target(
      name: "DracoDecompressSwift",
      dependencies: ["DracoDecompressObjc"],
      cSettings: [.headerSearchPath("Include/")]
    ),
    .target(name: "DracoDecompressObjc",
            dependencies: [.product(name: "draco", package: "draco")],
            publicHeadersPath: "Include"),
  ],
  cxxLanguageStandard: .cxx17
)
