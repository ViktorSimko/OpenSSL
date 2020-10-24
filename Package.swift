// swift-tools-version:5.3
import PackageDescription

let package = Package(
  name: "OpenSSL",
  products: [
    .library(
      name: "OpenSSL",
      targets: ["OpenSSL"]
    ),
  ],
  dependencies: [],
  targets: [
    .binaryTarget(
      name: "OpenSSL",
      path: "build/OpenSSL.xcframework"
    )
  ]
)