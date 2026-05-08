# Technical Details: StartOutboundVoiceContact with IAM User

**Date**: May 8, 2026  
**Context**: Phase 2 iOS Implementation  
**Authentication**: IAM User (No Cognito)

---

## 📞 API Overview: StartOutboundVoiceContact

### What It Does
Initiates an outbound voice call from an Amazon Connect instance. The API creates a new contact in the system and begins the call flow.

### Why It Requires IAM
This API allows creating calls programmatically, which is an **administrative action** in Amazon Connect. Only users/apps with proper IAM permissions can execute it.

---

## 🔐 IAM Permissions Required

Your IAM User needs this policy:

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "StartOutboundVoiceContact",
            "Effect": "Allow",
            "Action": [
                "connect:StartOutboundVoiceContact"
            ],
            "Resource": "arn:aws:connect:us-west-2:123456789012:instance/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
        }
    ]
}
```

### Key Points:
- **Action**: `connect:StartOutboundVoiceContact` (exact permission)
- **Resource**: ARN of your Connect instance (not queue or contact flow)
- **Effect**: "Allow" to permit the action

---

## 🏗️ Implementation in iOS App

### 1. Configuration Layer (AWSConfiguration.swift)
```swift
// Loads from environment variables
let accessKeyId: String = ProcessInfo.processInfo.environment["AWS_ACCESS_KEY_ID"] ?? ""
let secretAccessKey: String = ProcessInfo.processInfo.environment["AWS_SECRET_ACCESS_KEY"] ?? ""
let sessionToken: String = ProcessInfo.processInfo.environment["AWS_SESSION_TOKEN"] ?? "" // optional
```

### 2. Authentication Layer (AppDelegate.swift)
```swift
// Creates credentials provider from IAM User keys
let credentialsProvider = AWSBasicSessionCredentialsProvider(
    accessKey: awsConfig.accessKeyId,
    secretKey: awsConfig.secretAccessKey,
    sessionToken: awsConfig.sessionToken
)

// Initializes AWS SDK with these credentials
let configuration = AWSServiceConfiguration(
    region: regionType,
    credentialsProvider: credentialsProvider
)
```

### 3. Business Logic Layer (InitiateCallUseCase.swift)
```swift
// Uses repository abstraction
let contactId = try await callRepository.initiateCall(
    name: userName,
    attributes: ["key": "value"]
)
```

### 4. Data Layer (CallRepositoryImpl.swift)
```swift
// Delegates to AWS client
return try await awsConnectClient.startOutboundVoiceContact(
    instanceId: config.instanceId,
    destinationPhoneNumber: destinationPhoneNumber,
    sourcePhoneNumber: sourcePhoneNumber,
    attributes: attributes
)
```

### 5. AWS SDK Layer (AWSConnectClient.swift)
```swift
// Makes the actual API call
func startOutboundVoiceContact(...) async throws -> String {
    let request = AWSConnectStartOutboundVoiceContactRequest()
    request?.instanceId = instanceId
    request?.destinationPhoneNumber = destinationPhoneNumber
    request?.sourcePhoneNumber = sourcePhoneNumber
    request?.attributes = attributes
    request?.queueId = attributes["QueueId"]
    request?.contactFlowId = attributes["ContactFlowId"]
    
    // AWS SDK automatically uses credentials from AppDelegate
    // Credentials are injected via AWSServiceManager.defaultServiceConfiguration
    return try await withCheckedThrowingContinuation { continuation in
        self.connectService.startOutboundVoiceContact(request!) { response, error in
            // Handle response or error
        }
    }
}
```

---

## 🔄 Call Flow Sequence

```
┌──────────────┐
│   iOS App    │
└──────┬───────┘
       │ user taps button
       ↓
┌──────────────────────────────┐
│ ViewModel.initiateCall()      │
└──────────┬───────────────────┘
           │ calls use case
           ↓
┌──────────────────────────────────┐
│ InitiateCallUseCase.execute()    │
└──────────┬──────────────────────┘
           │ calls repository
           ↓
┌────────────────────────────────────────┐
│ CallRepositoryImpl.initiateCall()       │
└──────────┬─────────────────────────────┘
           │ delegates to AWS client
           ↓
┌──────────────────────────────────────────────┐
│ AWSConnectClient.startOutboundVoiceContact() │
└──────────┬───────────────────────────────────┘
           │ calls AWS SDK
           ↓
┌─────────────────────────────────────────────────┐
│ AWSConnect.startOutboundVoiceContact()          │
└──────────┬────────────────────────────────────┘
           │ AWS SDK validates credentials
           ├─ Checks Access Key ID
           ├─ Validates Secret Access Key
           ├─ Verifies IAM permissions
           └─ Checks request parameters
           ↓
       ┌───┴────┐
       ↓        ↓
    SUCCESS   FAILURE
    ┌─────┐  ┌──────────┐
    │ 200 │  │ 4xx / 5xx│
    └─┬───┘  └──┬───────┘
      ↓         ↓
  Contact    Error
    ID       (e.g., 403 Forbidden,
   ✅         400 Bad Request)
              ❌
```

---

## 🔑 Required Parameters for StartOutboundVoiceContact

### Mandatory
| Parameter | Type | Example | Description |
|-----------|------|---------|-------------|
| InstanceId | String (UUID) | xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx | Connect instance identifier |
| DestinationPhoneNumber | String | +1-555-123-4567 | Customer's phone number |
| ContactFlowId | String (UUID) | yyyyyyyy-yyyy-yyyy-yyyy-yyyyyyyyyyyy | Flow to handle the outbound call |

### Optional but Recommended
| Parameter | Type | Example | Description |
|-----------|------|---------|-------------|
| SourcePhoneNumber | String | +1-555-987-6543 | Caller ID (your contact center number) |
| QueueId | String (UUID) | zzzzzzzz-zzzz-zzzz-zzzz-zzzzzzzzzzzz | Queue to route contact (if using queue-based routing) |
| Attributes | Map<String, String> | {"name": "John", "tier": "VIP"} | Custom data passed to Contact Flow |

---

## 📊 Current iOS Implementation Parameters

### In AWSConnectClient.swift
```swift
request?.instanceId = instanceId                           // Mandatory
request?.destinationPhoneNumber = destinationPhoneNumber   // Mandatory
request?.sourcePhoneNumber = sourcePhoneNumber             // Optional
request?.attributes = attributes                          // Optional
request?.queueId = attributes["QueueId"]                   // Optional
request?.contactFlowId = attributes["ContactFlowId"]       // Mandatory
```

### In CallRepositoryImpl.swift (Consumer)
```swift
return try await awsConnectClient.startOutboundVoiceContact(
    instanceId: AWSConfiguration.shared.instanceId,
    destinationPhoneNumber: destinationPhoneNumber,
    sourcePhoneNumber: sourcePhoneNumber,
    attributes: [
        "name": customerName ?? "Guest",
        "timestamp": ISO8601DateFormatter().string(from: Date()),
        "QueueId": AWSConfiguration.shared.queueId,
        "ContactFlowId": AWSConfiguration.shared.contactFlowId
    ]
)
```

---

## 🔍 Error Handling & IAM Issues

### Common IAM Errors

#### 1. AccessDenied (403)
**Cause**: IAM User lacks `connect:StartOutboundVoiceContact` permission

**Solution**:
```bash
# Attach policy to user
aws iam put-user-policy --user-name connect-mobile-app-user \
  --policy-name ConnectPolicy \
  --policy-document file://policy.json
```

#### 2. InvalidParameterException: Invalid Access Key ID
**Cause**: Access Key ID doesn't exist or is inactive

**Solution**:
- Verify Access Key ID in AWS Console
- Check it matches environment variable
- Generate new key if lost

#### 3. ValidationException: The secret is invalid
**Cause**: Secret Access Key is incorrect

**Solution**:
- Verify exact Secret Access Key (case-sensitive)
- Check for whitespace or special characters
- Generate new key if unsure

#### 4. InvalidParameterException: Instance Id is invalid
**Cause**: Instance ID doesn't exist or is in different region

**Solution**:
```bash
# List instances
aws connect list-instances --region us-west-2
```

---

## 🧪 Testing IAM Configuration

### Test 1: Verify Credentials
```bash
# Test with AWS CLI
aws connect list-instances \
  --region us-west-2 \
  --profile connect-app-user

# Output should list your instances (not "AccessDenied")
```

### Test 2: Verify Permissions
```bash
# Simulate API call
aws connect start-outbound-voice-contact \
  --instance-id xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx \
  --destination-phone-number +1-555-123-4567 \
  --contact-flow-id yyyyyyyy-yyyy-yyyy-yyyy-yyyyyyyyyyyy \
  --source-phone-number +1-555-987-6543 \
  --region us-west-2 \
  --profile connect-app-user

# Output: contact ID (success) or error details
```

### Test 3: Check CloudTrail
```bash
# View API calls made with these credentials
aws cloudtrail lookup-events \
  --lookup-attributes AttributeKey=AccessKeyId,AttributeValue=AKIAIOSFODNN7EXAMPLE \
  --region us-west-2
```

---

## 🚀 In App: Full Request Example

```swift
// In AWSConnectClient.startOutboundVoiceContact
let request = AWSConnectStartOutboundVoiceContactRequest()!

// Required: Instance
request.instanceId = "12345678-1234-1234-1234-123456789012"

// Required: Destination
request.destinationPhoneNumber = "+1-555-001-0001"

// Required: Contact Flow
request.contactFlowId = "87654321-4321-4321-4321-210987654321"

// Optional: Source
request.sourcePhoneNumber = "+1-555-999-9999"

// Optional: Queue
request.queueId = "11111111-1111-1111-1111-111111111111"

// Optional: Custom attributes
request.attributes = [
    "name": "Customer Name",
    "email": "customer@example.com",
    "priority": "high"
]

// Make API call (AWS SDK uses IAM credentials from AppDelegate)
self.connectService.startOutboundVoiceContact(request) { response, error in
    if let error = error {
        // Check error type: AccessDenied, InvalidInstanceId, etc.
        print("Error: \(error.localizedDescription)")
    } else if let contactId = response?.contactId {
        // Success: contact created
        print("Contact ID: \(contactId)")
    }
}
```

---

## 📋 Response Format

### Success Response
```swift
{
    "ContactId": "12345678-1234-1234-1234-123456789abc"
}
```

### iOS App Usage
```swift
if let response = response, let contactId = response.contactId {
    // Store contactId for future API calls
    self.callData.contactId = contactId
    
    // Use for monitoring status
    try await monitorCallStatus(contactId: contactId)
}
```

---

## 🔄 After StartOutboundVoiceContact

### Next Steps in Call Flow
1. Contact created with status "INITIATED"
2. Contact Flow executes on Amazon Connect side
3. Dialing begins to destination phone number
4. Call state progresses: RINGING → CONNECTED → etc.
5. iOS app polls for status via `GetContactAttributes`

### Status Monitoring
```swift
// CallRepositoryImpl monitors status periodically
while callIsActive {
    let attributes = try await awsConnectClient.getContactAttributes(
        instanceId: instanceId,
        contactId: contactId
    )
    
    // Extract status from attributes
    let callState = parseState(attributes)
    
    // Emit to ViewModel (published property)
    publisher.send(callState)
    
    // Wait before next poll
    try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
}
```

---

## 🛡️ Security: Credential Lifecycle

```
┌─────────────────────────────────────────────────┐
│ 1. IAM User Created in AWS Console              │
│    - Username: connect-mobile-app-user          │
│    - Permissions: connect:StartOutboundVoiceContact
└─────────┬──────────────────────────────────────┘
          ↓
┌─────────────────────────────────────────────────┐
│ 2. Access Key Generated                         │
│    - Access Key ID: AKIAIOSFODNN7EXAMPLE        │
│    - Secret Access Key: wJalrXUtnFEMI/K7MDENG...│
│    ⚠️  Secret shown ONLY once, must save securely
└─────────┬──────────────────────────────────────┘
          ↓
┌─────────────────────────────────────────────────┐
│ 3. iOS App Configured                           │
│    - Credentials stored in environment variables │
│    - Or loaded from secure configuration file   │
│    - Or read from Keychain                      │
└─────────┬──────────────────────────────────────┘
          ↓
┌─────────────────────────────────────────────────┐
│ 4. App Startup (AppDelegate)                    │
│    - Load credentials from source              │
│    - Initialize AWSBasicSessionCredentialsProvider
│    - AWS SDK automatically uses for all API calls
└─────────┬──────────────────────────────────────┘
          ↓
┌─────────────────────────────────────────────────┐
│ 5. API Calls                                    │
│    - AWS SDK signs requests with Access Key ID │
│    - AWS verifies signature with Secret Key    │
│    - IAM checks permissions                     │
│    - API call succeeds or fails                │
└─────────┬──────────────────────────────────────┘
          ↓
┌─────────────────────────────────────────────────┐
│ 6. Monitoring (CloudTrail)                      │
│    - All API calls logged with Access Key ID    │
│    - Timestamps, results, errors recorded       │
│    - Audit trail for security review            │
└─────────────────────────────────────────────────┘
```

---

## 📚 Related Documentation

- **IAM_CONFIGURATION.md** - Complete IAM User setup
- **COGNITO_REMOVAL_UPDATE.md** - Overview of changes
- **AppDelegate.swift** - Code implementation
- **AWSConnectClient.swift** - API wrapper
- **CallRepositoryImpl.swift** - Business logic

---

**Status**: ✅ Complete  
**Last Updated**: May 8, 2026  
**Authentication Method**: IAM User (No Cognito)
