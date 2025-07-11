// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "lhCloudKit",
    platforms: [
        .iOS(.v17),
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "lhCloudKit",
            targets: ["lhCloudKit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/supabase-community/supabase-swift.git", exact: "2.29.3"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "lhCloudKit",
            dependencies: [
                .product(name: "Supabase", package: "supabase-swift"),
            ]),
        .testTarget(
            name: "lhCloudKitTests",
            dependencies: ["lhCloudKit"]
        )
    ]
)
