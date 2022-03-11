// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "OfflineTranslator",
    platforms: [
        .macOS(.v10_10)
    ],
    products: [
        .library(
            name: "OfflineTranslator",
            targets: [
                "OfflineTranslator"
            ]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/marmelroy/Zip.git",
            from: .init("2.1.2")
        )
    ],
    targets: [
        .target(
            name: "OfflineTranslator",
            dependencies: [
                "Zip",
                "LingvanexCTranslate2"
            ]
        ),
        .binaryTarget(
            name: "LingvanexCTranslate2",
            path: "Frameworks/LingvanexCTranslate2.xcframework"
        )
    ]
)
