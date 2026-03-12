// swift-tools-version:5.9

import PackageDescription

let package = Package(
    name: "AgentforceMobileService",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "AgentforceService",
            targets: ["AgentforceServiceTarget"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/forcedotcom/SalesforceMobileInterfaces-iOS.git", from: "1.0.0"),
        .package(url: "https://github.com/livekit/client-sdk-swift.git", from: "2.0.0"),
        .package(url: "https://github.com/Salesforce-Async-Messaging/Swift-Package-InAppMessaging.git", from: "1.10.0"),
    ],
    targets: [
        .binaryTarget(
            name: "AgentforceService",
            url: "https://github.com/forcedotcom/AgentforceMobileService-iOS/releases/download/4.9.11/AgentforceMobileService-260-1.xcframework.zip",
            checksum: "91996e19bac4f10988d59960b70596eb440c1b4b6d36fe7724bbb75183ec3198"
        ),
        .target(
            name: "AgentforceServiceTarget",
            dependencies: [
                "AgentforceService",
                .product(name: "SalesforceNetwork", package: "SalesforceMobileInterfaces-iOS"),
                .product(name: "SalesforceLogging", package: "SalesforceMobileInterfaces-iOS"),
                .product(name: "LiveKit", package: "client-sdk-swift"),
                .product(name: "Swift-InAppMessaging", package: "Swift-Package-InAppMessaging"),
            ],
            path: "Sources/AgentforceServiceTarget"
        )
    ],
    swiftLanguageVersions: [.v5]
)
