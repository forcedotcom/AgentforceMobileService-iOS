# AgentforceService

A comprehensive Swift framework for building conversational AI experiences powered by the Salesforce Agentforce platform, supporting both Employee Agents and Service Agents via Salesforce Enhanced Chat.

`AgentforceService` provides a complete toolkit for developers to integrate intelligent, conversational agents into their iOS applications. It handles session management, message passing, real-time event handling, voice conversations, and multi-channel agent support, allowing you to focus on building engaging user interactions.

## Features

### Core Capabilities
-   **Dual Agent Support**: Supports both Employee Agents (Agentforce) and Service Agents (Salesforce Enhanced Chat)
-   **Session Management**: Comprehensive session lifecycle management with enhanced tracking and information
-   **Rich Messaging**: Send and receive various message types including text, replies, choices, and attachments
-   **Real-time Communication**: Server-Sent Events (SSE) for low-latency, bidirectional communication
-   **Combine Integration**: Native Apple Combine framework for reactive event handling
-   **Flexible Authentication**: OAuth, OrgJWT, and Guest authentication with sophisticated token management
-   **Context Management**: Persist and manage conversational context across sessions with variables

### Voice & Transcription
-   **Voice Conversations**: Full voice communication support via LiveKit integration
-   **Real-time Transcription**: Live speech-to-text processing for both user and agent
-   **Voice Level Monitoring**: Audio level tracking for voice activity visualization
-   **Microphone Control**: Mute/unmute capabilities during voice sessions

### Advanced Messaging
-   **Interactive Choices**: Support for carousel, buttons, and quick reply message formats
-   **Typing Indicators**: Real-time typing status for enhanced user experience
-   **Message Acknowledgments**: Read receipts and delivery confirmations (Service Agents)
-   **Conversation Transcripts**: Download conversation history as PDF (Service Agents)

### Event Streaming
-   **Categorized Event Streams**: Separate publishers for message, system, and status events
-   **Event Filtering**: Built-in categorization for efficient event processing
-   **Custom Event Handlers**: Support for instrumentation and telemetry

### Service Agent Features
-   **Core SDK Integration**: Native SMIClientCore SDK support for Service Agents
-   **Pre-chat Forms**: Automatic handling of required pre-chat fields
-   **Agent Availability**: Check agent availability and queue status
-   **Conversation Management**: Create, list, end, and manage multiple conversations
-   **Session Context**: Enhanced context variables for Service Agent interactions

## Requirements

-   iOS 16.0+
-   Xcode 16.0+
-   Swift 5.0+

## Dependencies

### Core Dependencies
-   [SalesforceNetwork](https://github.com/forcedotcom/SalesforceMobileInterfaces-iOS): Network layer abstraction
-   [SalesforceLogging](https://github.com/forcedotcom/SalesforceMobileInterfaces-iOS): Logging infrastructure

### Voice & Real-time
-   [LiveKitClient](https://github.com/livekit/client-sdk-swift): Voice conversation support
-   [LiveKitWebRTC](https://github.com/livekit/client-sdk-swift): WebRTC for voice communication

### Service Agent (MIAW)
-   [Messaging-InApp-Core](https://developer.salesforce.com/docs/service/messaging-in-app/overview): Core SDK for Service Agents (Binary subspec only)

Note: The framework includes a custom SSE implementation and no longer depends on external SSE libraries.

## Installation

### CocoaPods

`AgentforceService` is available through [CocoaPods](https://cocoapods.org).

At the top of your podfile, add the Salesforce Mobile iOS Spec Repo above the cocoapods trunk repo. Ensure you add the cocoapods CDN if you use any other cocoapods dependencies.

```ruby
source 'https://github.com/forcedotcom/SalesforceMobileSDK-iOS-Specs.git'
source 'https://github.com/livekit/podspecs.git'
source 'https://cdn.cocoapods.org/'
```

Then in your target add:

```ruby
pod 'AgentforceService'
pod 'Messaging-InApp-Core', '1.9.3-Experimental'
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
        // Return your OAuth token, OrgJWT, or Guest credentials
        return .OAuth(authToken: "YOUR_AUTH_TOKEN", orgId: "YOUR_ORG_ID", userId: "YOUR_USER_ID")
        // Or: return .OrgJWT(orgJWT: "YOUR_ORG_JWT")
        // Or: return .Guest(url: "YOUR_GUEST_URL") // For unauthenticated users
    }
}

// You will need a Network instance conforming to SalesforceNetwork
let network = // ... create your Network instance

let credentialProvider = YourAuthCredentialProvider()

let serviceProvider = AgentforceServiceProvider(
    network: network,
    credentialProvider: credentialProvider,
    orgId: "YOUR_ORG_ID", // Required for service discovery
    connectionInfo: nil, // Can be nil, will be fetched at runtime
    instrumentationHandler: nil, // Optional instrumentation handler
    logger: nil, // Optional logger
    voiceDelegate: nil // Optional voice delegate for voice events
)
```

### 2. Get an Agent Service

You can create services for both Employee Agents and Service Agents.

#### Employee Agent Service
```swift
let agentService = serviceProvider.agentforceServiceFor(agentId: "YOUR_AGENT_ID")
```

#### Service Agent (MIAW) Service
```swift
let config = ServiceAgentConfig(
    esDeveloperName: "YOUR_ES_DEVELOPER_NAME",
    organizationId: "YOUR_ORG_ID",
    serviceApiURL: "YOUR_SERVICE_API_URL"
)
let serviceAgent = serviceProvider.serviceAgentFor(config: config)
```

#### Get Available Agents
```swift
Task {
    do {
        let agents = try await serviceProvider.getAvailableAgents(
            agentTypes: nil, // Optional filter by agent types
            appName: nil // Optional app name filter
        )
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
        // Start a new session
        let response = try await agentService.startSession(
            sessionId: nil, // Optional: Resume existing session
            instanceURL: "YOUR_INSTANCE_URL",
            streamingCapabilities: [.textChunk, .lightningChunk] // Optional capabilities
        )
        let sessionId = response.sessionId
        print("Session started with ID: \(sessionId)")
        
        // Access session info
        if let sessionInfo = agentService.getCurrentSessionInfo() {
            print("Session status: \(sessionInfo.status)")
            print("Message count: \(sessionInfo.messageCount)")
        }
    } catch {
        print("Error starting session: \(error)")
    }
}
```

### 4. Subscribe to Events

The framework provides multiple event publishers for different event categories.

```swift
import Combine

var subscriptions = Set<AnyCancellable>()

// Subscribe to all events
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
        case .Choices(let choices):
            print("Received choices: \(choices)")
        case .UserTranscriptionChunk(let transcription):
            print("User said: \(transcription.text)")
        // ... handle other event types
        default:
            break
        }
    })
    .store(in: &subscriptions)

// Or subscribe to categorized event streams
agentService.messageEvents
    .sink { event in
        // Handle message events only
    }
    .store(in: &subscriptions)

agentService.systemEvents
    .sink { event in
        // Handle system events only
    }
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
let contextVariable = AgentforceVariable(name: "user_name", type: .string, value: JSEncodableValue.string("John Doe"))
let locationVariable = AgentforceVariable(name: "location", type: .string, value: JSEncodableValue.string("San Francisco"))
Task {
    do {
        try await agentService.setAdditionalContext(context: [contextVariable, locationVariable])
    } catch {
        print("Error setting context: \(error)")
    }
}
```

### 7. Voice Conversations

Enable voice communication with agents using LiveKit integration.

```swift
// Start voice conversation
Task {
    do {
        try await agentService.startAgentforceVoice()
        print("Voice conversation started")
        
        // Monitor voice levels
        agentService.voiceLevelPublisher
            .sink { level in
                print("Voice level: \(level)")
                // Update UI with voice activity indicator
            }
            .store(in: &subscriptions)
            
    } catch {
        print("Error starting voice: \(error)")
    }
}

// Control microphone
try await agentService.muteMicrophone(true) // Mute
try await agentService.muteMicrophone(false) // Unmute

// End voice conversation
await agentService.endAgentforceVoice()
```

### 8. Handle Interactive Choices

Process interactive choice messages with multiple formats.

```swift
agentService.eventPublisher
    .sink { event in
        switch event.message {
        case .Choices(let choicesMessage):
            switch choicesMessage.choices {
            case .buttons(let buttonsChoices):
                // Display button options
                for option in buttonsChoices.optionItems {
                    print("Button: \(option.titleItem.title)")
                }
            case .carousel(let carouselChoices):
                // Display carousel cards
                for item in carouselChoices.items {
                    print("Card with \(item.interactionItems.count) options")
                }
            case .quickReplies(let quickReplies):
                // Display quick reply options
                for option in quickReplies.optionItems {
                    print("Quick Reply: \(option.titleItem.title)")
                }
            }
        default:
            break
        }
    }
    .store(in: &subscriptions)

// Send choice response
let selectedOption = SourceTypeMessage(
    type: "TitleOptionItem",
    property: "optionIdentifier",
    value: JSEncodableValue.string("option-1")
)
try await agentService.sendReply([selectedOption], replyToId: choicesMessage.id)
```

### 9. Advanced Features

#### Multiple Attachment Upload
```swift
let attachments = [
    AgentforceAttachment(
        name: "document.pdf",
        mimeType: "application/pdf",
        attachmentType: .PDF(data: pdfData)
    ),
    AgentforceAttachment(
        name: "image.jpg",
        mimeType: "image/jpeg",
        attachmentType: .Image(data: imageData)
    )
]

try await agentService.uploadAttachments(attachments) { progress in
    print("Upload progress: \(progress * 100)%")
}
```

#### Typing Indicators
```swift
// Send typing indicator (Service Agent only)
try await agentService.sendTypingIndicator(isTyping: true)

// Receive typing indicators
agentService.statusEvents
    .sink { event in
        if case .TypingIndicator(let indicator) = event.message {
            print("\(indicator.participantName) is typing: \(indicator.isTyping)")
        }
    }
    .store(in: &subscriptions)
```

#### Session Management
```swift
// Check agent availability
let availability = try await agentService.checkAgentAvailability()
if availability.isAvailable {
    print("Agent is available")
} else {
    print("Estimated wait time: \(availability.estimatedWaitTime ?? 0) seconds")
}

// Get queue status
let queueStatus = try await agentService.getQueueStatus()
print("Position in queue: \(queueStatus.position ?? 0)")

// End session (resumable)
try await agentService.endSession()

// Close session (complete cleanup)
try await agentService.closeSession()
```

#### Conversation Transcript (Service Agent)
```swift
// Download conversation transcript as PDF
let transcriptData = try await agentService.getConversationTranscript()
// Save or display PDF data
```

## Migration Guide

### Migrating from Earlier Versions

#### Breaking Changes
- `AgentforceServiceProvider` now requires `orgId` parameter
- Authentication now uses internal `TokenManager` for token lifecycle
- SSE implementation replaced external dependencies with custom implementation
- Voice features now require `AgentforceVoiceDelegate` for event callbacks

#### New Features to Adopt
- Use categorized event streams (`messageEvents`, `systemEvents`, `statusEvents`) for better performance
- Implement `ServiceAgentConfig` for MIAW/Service Agent support
- Leverage enhanced session management with `SessionInfo` tracking
- Adopt voice conversation features with transcription support

## Performance Considerations

### Optimizations
- **Event Filtering**: Use categorized event publishers to reduce processing overhead
- **Token Caching**: Internal token management reduces authentication requests
- **SSE Reconnection**: Automatic reconnection with exponential backoff
- **Voice Processing**: Efficient audio rendering with LiveKit optimization

### Best Practices
```swift
// Use categorized streams instead of filtering all events
agentService.messageEvents // More efficient
    .sink { event in /* Handle messages */ }

// Batch context updates
let variables = [variable1, variable2, variable3]
try await agentService.setAdditionalContext(context: variables)

// Use progress handlers for large uploads
try await agentService.uploadAttachments(attachments) { progress in
    // Update UI efficiently
}
```

## Error Handling

The framework provides comprehensive error handling through the `AgentforceError` enum:

```swift
do {
    try await agentService.startSession(instanceURL: instanceURL, streamingCapabilities: nil)
} catch AgentforceError.NoActiveSession {
    print("No active session found")
} catch AgentforceError.ConnectionInfoRequired {
    print("Connection info required for guest users")
} catch AgentforceError.NotSupportedForMIAW {
    print("Feature not supported for Service Agents")
} catch AgentforceError.MIAWPreChatRequired {
    print("Pre-chat form submission required")
} catch {
    print("Unexpected error: \(error)")
}
```

### Common Error Types

- **Authentication Errors**: `InvalidCredentials`, `CouldNotFetchGuestToken`, `NotSupportedForGuestUsers`
- **Session Errors**: `NoActiveSession`, `MissingSession`
- **Service Agent Errors**: `NotSupportedForMIAW`, `MIAWConfigurationError`, `MIAWPreChatRequired`
- **Connection Errors**: `CouldNotObtainConnectionInfo`, `ConnectionInfoRequired`
- **Network Errors**: `NetworkAPIRequired`, `InvalidURL`
- **Stream Errors**: `AgentforceStreamError`, `AgentforceErrorEvent`

## Contributing

See `CONTRIBUTING.md` for guidelines on contributing to this project.

## License

See the `LICENSE.txt` file for licensing information.