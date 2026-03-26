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
            url: "https://github.com/forcedotcom/AgentforceMobileService-iOS/releases/download/4.10.5/AgentforceMobileService-260-2.xcframework.zip",
            checksum: "6a5e6ce34abd747423e0dcf74b0c38edd6974c45af5e9b74911bbd7a4f285aae"
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
