// swift-tools-version:5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let moduleName = "DexcareiOSSDK"

let package = Package(
    name: moduleName,
    defaultLocalization: "en",
    platforms: [.iOS(.v14)],
    products: [
        .library(
            name: moduleName,
            targets: [moduleName])
    ],
    dependencies: [
        .package(url: "https://github.com/matej/MBProgressHUD", exact: "1.2.0"),
        .package(url: "https://github.com/MessageKit/MessageKit", exact: "3.8.0"),
        .package(url: "https://github.com/gordontucker/FittedSheets", exact: "2.6.1"),
        .package(url: "https://github.com/opentok/vonage-client-sdk-video", exact: "2.27.4")
    ],
    targets: [
        .target(name: moduleName,
                dependencies: [
                    "MBProgressHUD",
                    "MessageKit",
                    "FittedSheets",
                    .product(name: "VonageClientSDKVideo", package: "vonage-client-sdk-video")
                ],
                resources: [.process("PrivacyInfo.xcprivacy"), .process("Dexcare-Info.plist")]
               )
    ]
)
