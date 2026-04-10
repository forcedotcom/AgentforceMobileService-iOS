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
            url: "https://github.com/forcedotcom/AgentforceMobileService-iOS/releases/download/5.1.0/AgentforceMobileService-260-3.xcframework.zip",
            checksum: "d73d2ada39b4395be14ed4818c72fe990027c62b80269f6bc4e7661039406a61"
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
