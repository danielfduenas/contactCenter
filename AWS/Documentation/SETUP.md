# AWS Amazon Connect Setup Guide

## 📋 Table of Contents
1. [Prerequisites](#prerequisites)
2. [Step-by-Step Setup](#step-by-step-setup)
3. [Configuration Details](#configuration-details)
4. [Testing](#testing)
5. [Troubleshooting](#troubleshooting)

---

## Prerequisites

### Required Access
- [ ] AWS Account with billing enabled
- [ ] Permissions to create Amazon Connect instances
- [ ] Permissions to create IAM roles and policies
- [ ] AWS CLI installed and configured

### Tools Needed
```bash
# Install AWS CLI (if not already installed)
# macOS
brew install awscli

# Windows (PowerShell)
msiexec.exe /i https://awscli.amazonaws.com/AWSCLIV2.msi

# Verify installation
aws --version
```

### Configure AWS Credentials
```bash
aws configure

# Enter your credentials when prompted:
# AWS Access Key ID: [your-access-key]
# AWS Secret Access Key: [your-secret-key]
# Default region: us-east-1
# Default output format: json
```

---

## Step-by-Step Setup

### Phase 1: Create Amazon Connect Instance

#### Step 1.1: Open AWS Console
1. Go to [AWS Console](https://console.aws.amazon.com)
2. Search for "Amazon Connect"
3. Click "Get started" or "Create instance"

#### Step 1.2: Configure Instance Settings
1. **Access URL**: Choose a unique access URL
   ```
   https://[company-name].awsapps.com/connect/ccp-v2/
   ```
   - Example: `https://mobilesupport123.awsapps.com/connect/ccp-v2/`

2. **Telephony Options**:
   - Select: "Yes, I want to use Chat" (if needed)
   - Select: "Yes, enable voice" for outbound/inbound
   - Select: "Yes, I want to set up phone numbers now"

3. **Data Storage**:
   - Enable call recording (recommended)
   - CloudWatch logs: Enable for debugging
   - S3 bucket: Create new or select existing

#### Step 1.3: Create a Phone Number
1. In "Telephony" section, click "Claim a phone number"
2. Choose country: United States
3. Phone number type: DID (Direct Inward Dial)
4. Select a phone number from available options
5. Click "Claim"

#### Step 1.4: Complete Setup
1. Review settings
2. Click "Create instance"
3. Wait 5-10 minutes for instance to be created
4. Note the **Instance ID** (found in instance details)

**Save these values**:
```
Instance URL: https://[account-id].awsapps.com/connect
Instance ID: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
Phone Number: +1-800-XXXXX
```

---

### Phase 2: Create Users (Admin & Agents)

#### Step 2.1: Access Admin Dashboard
1. Go to your instance URL
2. Use AWS account credentials to sign in initially
3. Click "Admin" in left sidebar
4. Select "User management" → "Users"

#### Step 2.2: Create Admin User
1. Click "+ Add user"
2. **General Information**:
   - First Name: `Admin`
   - Last Name: `Support`
   - Email: `admin@company.connect`
   - Username: `admin@company.connect`
   - Password: Generate strong password (save it!)

3. **User Settings**:
   - Routing Profile: Select "Default"
   - Security Profiles: Select "Admin"

4. Click "Save"

#### Step 2.3: Create Agent Users
Repeat for each agent:

**Agent 1**:
- First Name: `Agent`
- Last Name: `One`
- Email: `agent1@company.connect`
- Username: `agent1@company.connect`
- Routing Profile: (will assign later)
- Security Profile: `Agent`

**Agent 2** (for testing):
- First Name: `Agent`
- Last Name: `Two`
- Email: `agent2@company.connect`
- Username: `agent2@company.connect`
- Routing Profile: (will assign later)
- Security Profile: `Agent`

---

### Phase 3: Create Queues

#### Step 3.1: Navigate to Queues
1. In Admin, go to "Queues"
2. Click "+ Add queue"

#### Step 3.2: Create "Mobile Support Queue"
**Basic Information**:
- Name: `Mobile Support Queue`
- Description: `Queue for mobile app support requests`

**Queue Settings**:
- Outbound caller ID name: `Mobile Support`
- Outbound caller ID number: Select your claimed phone number
- Max queue time before disconnect: `300` seconds (5 minutes)
- Enable callback: `Yes`

**Timeout**:
- Max wait time: `600` seconds (10 minutes)
- Action after timeout: Send to voicemail / Disconnect

Click "Save"

**Optional: Create Additional Queues**
- "Email Support Queue" (for chat/email)
- "Emergency Queue" (for high-priority calls)

---

### Phase 4: Create Routing Profile

#### Step 4.1: Navigate to Routing Profiles
1. In Admin, go to "Routing profiles"
2. Click "+ Add routing profile"

#### Step 4.2: Configure Profile
**Basic Information**:
- Name: `Mobile Support Agent Profile`
- Description: `Profile for agents handling mobile support calls`

**Set Channels and Queues**:
1. Click "Add queue"
2. Select channel: `Voice`
3. Select queue: `Mobile Support Queue`
4. Priority: `1` (highest)
5. Delay: `0` seconds

**Set Default Outbound Queue**:
- Default: `Mobile Support Queue`

**Save** the routing profile

**Note the Routing Profile ID** (visible in the URL or profile details)

---

### Phase 5: Assign Routing Profile to Agents

#### Step 5.1: Update Agent Users
1. Go to "User management" → "Users"
2. Click on `agent1@company.connect`
3. In "Routing Profile" dropdown, select: `Mobile Support Agent Profile`
4. Click "Save"

Repeat for `agent2@company.connect`

---

### Phase 6: Create Contact Flow

#### Step 6.1: Navigate to Contact Flows
1. In Admin, go to "Contact flows"
2. Click "+ Create contact flow"
3. Choose "Inbound contact flow"
4. Name: `Mobile User Support Flow`

#### Step 6.2: Build the Flow

**Flow Design** (Drag & drop blocks):

```
1. [Entry Point] - START
   ↓
2. [Set Contact Attributes]
   - Key: "source"
   - Value: "mobile_app"
   ↓
3. [Set Contact Attributes]
   - Key: "caller_name"
   - Value: $.Name (or external data)
   ↓
4. [Play Prompt]
   - "Thank you for contacting support"
   ↓
5. [Transfer to Queue]
   - Queue: "Mobile Support Queue"
   - Transfer Prompt: "Connecting you to an agent"
   ↓
6. [Add to Queue] (if no agent available)
   - Queue: "Mobile Support Queue"
   - Wait Prompt: "Your call is important to us"
   ↓
7. [Check Staffing]
   - If agent available → route
   - If no agent → offer callback
   ↓
8. [Disconnect]
   - "Thank you for calling"
```

**Step-by-step in UI**:

1. Drag "Set contact attributes" block
   - Attribute: "Source"
   - Value type: "Text"
   - Value: "mobile_app"

2. Drag "Set contact attributes" again
   - Attribute: "CallType"
   - Value: "Support Request"

3. Drag "Play prompt"
   - Text: "Thank you for contacting mobile support. Connecting you to an agent."

4. Drag "Transfer to queue"
   - Select queue: "Mobile Support Queue"
   - Select prompt: "Please wait while we connect your call"

5. Drag "Disconnect"
   - Text: "Thank you for using our service"

**Save and Publish**:
1. Click "Save"
2. Click "Publish"

**Note the Contact Flow ID** (visible in the flow details)

---

### Phase 7: Configure IAM Roles

#### Step 7.1: Create Role for iOS App

**Navigate to IAM**:
1. Go to IAM Console
2. Click "Roles" in left sidebar
3. Click "Create role"

**Trusted Entity**:
- Service: STS (Security Token Service)
- Use Case: "AssumeRole"
- Trust your AWS account

**Create with Inline Policy**:

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "ConnectMobileClientPermissions",
            "Effect": "Allow",
            "Action": [
                "connect:StartOutboundVoiceContact",
                "connect:GetContactAttributes",
                "connect:UpdateContactAttributes",
                "connect:GetUserData"
            ],
            "Resource": "arn:aws:connect:*:ACCOUNT_ID:instance/INSTANCE_ID/*"
        },
        {
            "Sid": "AssumeRolePermission",
            "Effect": "Allow",
            "Action": "sts:AssumeRole",
            "Resource": "arn:aws:iam::ACCOUNT_ID:role/ConnectMobileClientRole"
        }
    ]
}
```

**Role Name**: `ConnectMobileClientRole`

**Note the Role ARN**: Save for later use

#### Step 7.2: Create Role for Android Agent App

**Create another role** with:

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "ConnectAgentPermissions",
            "Effect": "Allow",
            "Action": [
                "connect:DescribeContact",
                "connect:GetContactAttributes",
                "connect:UpdateContactAttributes",
                "connect:GetCCPSessionBag",
                "connect:GetCurrentUserData"
            ],
            "Resource": "arn:aws:connect:*:ACCOUNT_ID:instance/INSTANCE_ID/*"
        }
    ]
}
```

**Role Name**: `ConnectAgentAppRole`

---

### Phase 8: Create IAM User for Applications

#### Step 8.1: Create IAM User
1. Go to IAM Console
2. Click "Users"
3. Click "Create user"

**User Details**:
- Username: `mobile-app-user`
- Access type: "Programmatic access"

**Permissions**:
- Attach policies:
  - `AmazonConnectFullAccess` (for testing; restrict in production)
  - Or create custom policy with specific Connect permissions

**Save Access Keys**:
- Access Key ID: `AKIA...`
- Secret Access Key: Save securely!

**⚠️ Important**: Save these credentials in a `.env.example` file:

```env
AWS_ACCESS_KEY_ID=AKIA...
AWS_SECRET_ACCESS_KEY=...
AWS_REGION=us-east-1
CONNECT_INSTANCE_ID=...
CONNECT_CONTACT_FLOW_ID=...
CONNECT_QUEUE_ID=...
CONNECT_ROUTING_PROFILE_ID=...
```

---

## Configuration Details

### Complete Configuration Summary

```bash
# Save all these values from your setup

# AWS Account
AWS_ACCOUNT_ID=123456789012
AWS_REGION=us-east-1

# Amazon Connect
CONNECT_INSTANCE_ID=12345678-1234-1234-1234-123456789012
CONNECT_INSTANCE_URL=https://account-id.awsapps.com/connect
CONNECT_PHONE_NUMBER=+1-800-XXXXXX

# Contact Flow
CONTACT_FLOW_ID=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
CONTACT_FLOW_NAME=Mobile User Support Flow

# Queue
QUEUE_ID=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
QUEUE_NAME=Mobile Support Queue

# Routing Profile
ROUTING_PROFILE_ID=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx

# Users
AGENT_USERNAME=agent1@company.connect
AGENT_PASSWORD=SecurePassword123!

# IAM
MOBILE_CLIENT_ROLE_ARN=arn:aws:iam::123456789012:role/ConnectMobileClientRole
AGENT_APP_ROLE_ARN=arn:aws:iam::123456789012:role/ConnectAgentAppRole

# API User
API_ACCESS_KEY=AKIA...
API_SECRET_KEY=...
```

---

## Testing

### Test 1: Verify Instance is Running
```bash
aws connect describe-instance \
    --instance-id INSTANCE_ID \
    --region us-east-1
```

Expected output shows instance details.

### Test 2: List Contact Flows
```bash
aws connect list-contact-flows \
    --instance-id INSTANCE_ID \
    --region us-east-1
```

Should show "Mobile User Support Flow" in the list.

### Test 3: List Queues
```bash
aws connect list-queues \
    --instance-id INSTANCE_ID \
    --filters Name=queue-type,Operator=EQUALS,Value=STANDARD \
    --region us-east-1
```

Should show "Mobile Support Queue".

### Test 4: Test Contact Flow Manually
1. Go to your Connect instance
2. Click "Test" on the Contact Flow
3. Verify the flow executes properly

### Test 5: Agent Login Test
1. Go to CCP URL (visible in instance details)
2. Log in as `agent1@company.connect`
3. Verify you can see the queue
4. Set status to "Available"

---

## Troubleshooting

### Issue: Cannot Create Instance
**Solution**: 
- Verify billing is enabled
- Check IAM permissions
- Try different region if one is having issues

### Issue: Phone Number Not Available
**Solution**:
- Some regions have limited phone numbers
- Try different country/area code
- Use SIP URI instead of phone number

### Issue: Contact Flow Not Publishing
**Solution**:
- Verify all required blocks are present
- Check for disconnected blocks
- Validate queue exists before publishing

### Issue: Agent Not Receiving Calls
**Solution**:
- Verify agent is assigned to routing profile
- Check agent status is "Available" in CCP
- Verify queue is assigned to routing profile
- Check IAM permissions

### Issue: Cannot Connect to CCP
**Solution**:
- Clear browser cache
- Try incognito mode
- Verify user has "Agent" or "Admin" security profile
- Check network connectivity

### Issue: Call Not Routing to Queue
**Solution**:
- Test contact flow with "Test" button
- Verify queue exists and is properly referenced
- Check for errors in contact flow logs
- Verify routing profile is assigned

---

## AWS CLI Cheat Sheet

```bash
# Describe instance
aws connect describe-instance --instance-id INSTANCE_ID

# List users
aws connect list-users --instance-id INSTANCE_ID

# List contact flows
aws connect list-contact-flows --instance-id INSTANCE_ID

# Get contact details
aws connect get-contact-attributes \
    --instance-id INSTANCE_ID \
    --initial-contact-id CONTACT_ID

# List queues
aws connect list-queues --instance-id INSTANCE_ID

# Create a test contact
aws connect start-outbound-voice-contact \
    --destination-phone-number "+1-800-XXXXXX" \
    --contact-flow-id FLOW_ID \
    --instance-id INSTANCE_ID

# Check call status
aws connect describe-contact \
    --instance-id INSTANCE_ID \
    --contact-id CONTACT_ID
```

---

## Next Steps

1. ✅ Verify all AWS resources are created and working
2. ✅ Document all credentials securely
3. ⬜ Proceed to iOS app development (see `iOS/README.md`)
4. ⬜ Proceed to Android app development (see `Android/README.md`)
5. ⬜ Test end-to-end integration

---

**Last Updated**: May 2, 2026  
**AWS Region**: us-east-1 (recommended)  
**Contact Service**: Amazon Connect
