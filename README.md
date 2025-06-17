# AgentforceService

A Swift framework for building conversational AI experiences powered by the Salesforce Agentforce platform.

`AgentforceService` provides a comprehensive toolkit for developers to integrate intelligent, conversational agents into their iOS applications. It handles session management, message passing, and real-time event handling, allowing you to focus on building engaging user interactions.

## Features

-   **Session Management**: Easily start and end sessions with Agentforce agents.
-   **Rich Messaging**: Send and receive various message types, including text, replies, and attachments.
-   **Real-time Communication**: Utilizes Server-Sent Events (SSE) for real-time, low-latency communication with agents.
-   **Combine Integration**: Leverages Apple's Combine framework for handling asynchronous events.
-   **Flexible Authentication**: Supports both OAuth and OrgJWT for authentication.
-   **Context Management**: Persist and manage conversational context across sessions.
-   **Attachment Uploads**: Supports uploading images and PDFs as attachments.

## Architecture

The `AgentforceService` framework is composed of several key components:

-   `AgentforceServiceProvider`: Takes all necessary dependencies and creates services for specific agents
-   `AgentforceServicing`: The protocol for services created by `AgentforceServiceProvider`. You use this to interact with the specific agent.
-   **Models**: A rich set of data models for requests, responses, and events.
-   **Network APIs**: A layer for handling network communication with the Agentforce platform.
-   **SSE Client**: An implementation for handling Server-Sent Events using the `LDSwiftEventSource` library.

## Requirements

-   iOS 16.0+
-   Xcode 16.0+
-   Swift 5.0+

## Dependencies

-   [LDSwiftEventSource](https://github.com/launchdarkly/swift-eventsource): For handling Server-Sent Events.
-   [SalesforceNetwork](https://github.com/forcedotcom/SalesforceMobileInterfaces-iOS): For making network requests.
-   [SalesforceLogging](https://github.com/forcedotcom/SalesforceMobileInterfaces-iOS): For logging.

## Installation

### CocoaPods

`AgentforceService` is available through [CocoaPods](https://cocoapods.org).

At the top of your podfile, add the Salesforce Mobile iOS Spec Repo above the cocoapods trunk repo. Ensure you add the cocoapods CDN if you use any other cocoapods dependencies.

```ruby
source 'https://github.com/forcedotcom/SalesforceMobileSDK-iOS-Specs.git'
source 'https://cdn.cocoapods.org/'
```

Then in your target add:

```ruby
pod 'AgentforceService'
```

At the bottom of your podfile where you set up your post installer, configure it as such:

```ruby
post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['BUILD_LIBRARY_FOR_DISTRIBUTION'] = 'YES'
    end
  end
end
```

After adding the pods, run `pod install` from your project's root directory. If cocoapods is unable to locate the specs, try `pod install --repo-update`.

## Usage

### 1. Configure the Service Provider

First, you need to create an instance of `AgentforceServiceProviding`. This requires a `Network` instance from `SalesforceNetwork`, and an object that conforms to `AgentforceAuthCredentialProviding`.

```swift
import AgentforceService
import SalesforceNetwork

// You will need to implement this protocol to provide authentication credentials.
class YourAuthCredentialProvider: AgentforceAuthCredentialProviding {
    func getAuthCredentials() -> AgentforceAuthCredentials {
        // Return your OAuth token or OrgJWT
        return .OAuth(authToken: "YOUR_AUTH_TOKEN", orgId: "YOUR_ORG_ID", userId: "YOUR_USER_ID")
    }
}

// You will need a Network instance conforming to SalesforceNetwork
let network = // ... create your Network instance

let credentialProvider = YourAuthCredentialProvider()

let serviceProvider = AgentforceServiceProvider(
    network: network,
    credentialProvider: credentialProvider,
    connectionInfo: nil, // Can be nil, will be fetched at runtime
    instrumentationHandler: nil, // Optional
    logger: nil // Optional
)
```

### 2. Get an Agentforce Service

Once you have a service provider, you can get an `AgentforceServicing` instance for a specific agent.

```swift
let agentService = serviceProvider.agentforceServiceFor(agentId: "YOUR_AGENT_ID")
```

You can also get a list of available agents:

```swift
Task {
    do {
        let agents = try await serviceProvider.getAvailableAgents(agentTypes: nil)
        print("Available agents: \(agents)")
    } catch {
        print("Error getting agents: \(error)")
    }
}
```

### 3. Start a Session

Before you can communicate with an agent, you need to start a session.

```swift
Task {
    do {
        let response = try await agentService.startSession(instanceURL: "YOUR_INSTANCE_URL", streamingCapabilities: nil)
        let sessionId = response.sessionId
        print("Session started with ID: \(sessionId)")
    } catch {
        print("Error starting session: \(error)")
    }
}
```

### 4. Subscribe to Events

To receive real-time events from the agent, you need to subscribe to the `eventPublisher`.

```swift
import Combine

var subscriptions = Set<AnyCancellable>()

agentService.eventPublisher
    .sink(receiveCompletion: { completion in
        print("Event stream completed: \(completion)")
    }, receiveValue: { event in
        print("Received event: \(event)")
        // Handle different event types
        switch event.message {
        case .TextChunk(let textChunk):
            print("Received text chunk: \(textChunk.text)")
        case .Inquire(let inquire):
            print("Agent is inquiring: \(inquire)")
        // ... handle other event types
        default:
            break
        }
    })
    .store(in: &subscriptions)
```

### 5. Send a Message

Now you can send messages to the agent.

```swift
let utterance = AgentforceUtterance(utterance: "Hello, agent!")
let sessionId = // ... the session ID from startSession()

Task {
    do {
        try await agentService.sendMessage(utterance, sessionId: sessionId)
    } catch {
        print("Error sending message: \(error)")
    }
}
```

### 6. Set Additional Context

You can provide additional context to the agent using `setAdditionalContext`.

```swift
let contextVariable = AgentforceVariable(name: "user_name", type: .string, value: JSEncodableValue("John Doe"))
Task {
    do {
        try await agentService.setAdditionalContext(context: [contextVariable])
    } catch {
        print("Error setting context: \(error)")
    }
}
```

## Contributing

See `CONTRIBUTING.md`

## License

See the `LICENSE.txt` file.