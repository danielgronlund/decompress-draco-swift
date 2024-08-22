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
    .package(url: "git@github.com:danielgronlund/draco.git", revision: "spm-0.0.1")
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
