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
        .package(url: "https://github.com/nathantannar4/InputBarAccessoryView", exact: "6.5.1"),
        .package(url: "https://github.com/MessageKit/MessageKit", exact: "4.3.0"),
        .package(url: "https://github.com/gordontucker/FittedSheets", exact: "2.6.1"),
        .package(url: "https://github.com/opentok/vonage-client-sdk-video", exact: "2.28.2")
    ],
    targets: [
        .target(name: moduleName,
                dependencies: [
                    "MBProgressHUD",
                    "InputBarAccessoryView",
                    "MessageKit",
                    "FittedSheets",
                    .product(name: "VonageClientSDKVideo", package: "vonage-client-sdk-video")
                ],
                resources: [.process("PrivacyInfo.xcprivacy"), .process("Dexcare-Info.plist")]
               )
    ]
)
