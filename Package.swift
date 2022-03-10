// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "OfflineTranslator",
    platforms: [
        .iOS(.v9),
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
                .product(
                    name: "Zip"
                )
            ]
        )
    ]
)
