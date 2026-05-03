# Configuration Checklist & Validation Guide

## 🔧 Pre-Implementation Checklist

### AWS Account Setup
- [ ] AWS account created and verified
- [ ] Billing enabled
- [ ] IAM permissions configured
- [ ] AWS CLI installed: `aws --version`
- [ ] AWS credentials configured: `aws configure`

### Region Selection
- [ ] Primary region: `us-east-1` (recommended)
- [ ] Backup region: `us-west-2` (for testing)
- [ ] All resources in same region

### Service Enablement
- [ ] Amazon Connect service enabled in region
- [ ] CloudWatch Logs enabled
- [ ] S3 bucket available for logs/recordings
- [ ] IAM service fully accessible

---

## 📝 Configuration Values Template

**Use this template to save all configuration values during setup**:

```yaml
# AWS Account Information
AWS_ACCOUNT_ID: "123456789012"
AWS_REGION: "us-east-1"
AWS_ACCESS_KEY_ID: "AKIA..."
AWS_SECRET_ACCESS_KEY: "..."

# Amazon Connect Instance
CONNECT_INSTANCE_ID: "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
CONNECT_INSTANCE_NAME: "MobileConnectSupport"
CONNECT_INSTANCE_URL: "https://account-id.awsapps.com/connect"
CONNECT_PHONE_NUMBER: "+1-800-XXX-XXXX"
CONNECT_REGION: "us-east-1"

# Users
ADMIN_USERNAME: "admin@company.connect"
ADMIN_PASSWORD: "..." # Save securely!
AGENT_USERNAME: "agent1@company.connect"
AGENT_PASSWORD: "..." # Save securely!

# Contact Flows
CONTACT_FLOW_ID: "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
CONTACT_FLOW_NAME: "Mobile User Support Flow"

# Queues
QUEUE_ID: "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
QUEUE_NAME: "Mobile Support Queue"

# Routing Profiles
ROUTING_PROFILE_ID: "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
ROUTING_PROFILE_NAME: "Mobile Support Agent Profile"

# IAM Roles
MOBILE_CLIENT_ROLE_ARN: "arn:aws:iam::123456789012:role/ConnectMobileClientRole"
AGENT_APP_ROLE_ARN: "arn:aws:iam::123456789012:role/ConnectAgentAppRole"
API_USER_NAME: "mobile-app-user"

# CCP URLs
CCP_AGENT_URL: "https://account-id.awsapps.com/connect/ccp-v2/"
CCP_ADMIN_URL: "https://account-id.awsapps.com/connect/admin/"
```

---

## ✅ AWS Setup Validation Steps

### Validation 1: Instance Health
```bash
# Command
aws connect describe-instance --instance-id INSTANCE_ID --region us-east-1

# Expected Response
{
    "Instance": {
        "Id": "INSTANCE_ID",
        "Status": "ACTIVE",
        "InstanceAlias": "MobileConnectSupport"
    }
}
```

**Checklist**:
- [ ] Status is "ACTIVE"
- [ ] Instance Alias matches your instance name
- [ ] Region is correct

### Validation 2: Users Exist
```bash
# List all users
aws connect list-users --instance-id INSTANCE_ID --region us-east-1

# Expected Response includes
[
    {
        "Id": "user-id-1",
        "Username": "admin@company.connect",
        "Arn": "arn:aws:connect:..."
    },
    {
        "Id": "user-id-2",
        "Username": "agent1@company.connect",
        "Arn": "arn:aws:connect:..."
    }
]
```

**Checklist**:
- [ ] Admin user exists
- [ ] At least one agent user exists
- [ ] Users have correct usernames

### Validation 3: Contact Flows Created
```bash
aws connect list-contact-flows \
    --instance-id INSTANCE_ID \
    --region us-east-1

# Expected Response includes
[
    {
        "Id": "FLOW_ID",
        "Name": "Mobile User Support Flow",
        "Arn": "arn:aws:connect:..."
    }
]
```

**Checklist**:
- [ ] Contact flow exists
- [ ] Contact flow name is correct
- [ ] Contact flow is published (not draft)

### Validation 4: Queues Created
```bash
aws connect list-queues \
    --instance-id INSTANCE_ID \
    --filters Name=queue-type,Operator=EQUALS,Value=STANDARD \
    --region us-east-1

# Expected Response includes
[
    {
        "Id": "QUEUE_ID",
        "Name": "Mobile Support Queue",
        "Arn": "arn:aws:connect:..."
    }
]
```

**Checklist**:
- [ ] Queue exists
- [ ] Queue name is correct
- [ ] Queue type is "STANDARD"

### Validation 5: IAM Roles Created
```bash
# List IAM roles
aws iam list-roles --query "Roles[?contains(RoleName, 'Connect')]"

# Expected Response includes
[
    {
        "RoleName": "ConnectMobileClientRole",
        "Arn": "arn:aws:iam::123456789012:role/ConnectMobileClientRole"
    },
    {
        "RoleName": "ConnectAgentAppRole",
        "Arn": "arn:aws:iam::123456789012:role/ConnectAgentAppRole"
    }
]
```

**Checklist**:
- [ ] Mobile client role exists
- [ ] Agent app role exists
- [ ] Both roles have correct permissions

### Validation 6: Login Test (Manual)
```bash
# 1. Open CCP URL in browser
https://YOUR_INSTANCE_URL/connect/ccp-v2/

# 2. Log in with agent credentials
Username: agent1@company.connect
Password: [your-password]

# Expected
- Should see dashboard
- Queue should be visible
- Status should be settable to "Available"
```

**Checklist**:
- [ ] Can log in successfully
- [ ] Can see assigned queue
- [ ] Can set status to "Available"
- [ ] No console errors

### Validation 7: Contact Flow Test (Manual)
```bash
# In Connect Console:
1. Go to Contact Flows
2. Click on "Mobile User Support Flow"
3. Click "Test" button
4. Verify flow executes without errors
```

**Checklist**:
- [ ] Flow starts properly
- [ ] All blocks execute
- [ ] No error logs
- [ ] Queue routing works

---

## 🔐 Security Validation

### Credentials Security
- [ ] AWS credentials stored in `.env` (not in Git)
- [ ] `.env` added to `.gitignore`
- [ ] No credentials in code or comments
- [ ] Use IAM users, not root account
- [ ] Enable MFA on AWS account

### IAM Permissions
- [ ] Roles use least privilege principle
- [ ] Mobile client role limited to necessary Connect actions
- [ ] Agent app role limited to necessary Connect actions
- [ ] API user has restricted permissions

### Network Security
- [ ] HTTPS enforced for all Connect URLs
- [ ] TLS 1.2+ for all connections
- [ ] No HTTP traffic to Connect services

### Data Protection
- [ ] Call recording encrypted at rest
- [ ] S3 bucket has encryption enabled
- [ ] CloudWatch logs retention configured
- [ ] No sensitive data in logs

---

## 🚀 Pre-App Development Validation

### Complete AWS Setup Verification
```bash
#!/bin/bash
# Run all validations

echo "=== AWS Setup Validation Script ==="
INSTANCE_ID="YOUR_INSTANCE_ID"
REGION="us-east-1"

# Check instance
echo "1. Checking instance..."
aws connect describe-instance --instance-id $INSTANCE_ID --region $REGION > /dev/null && echo "✓ Instance OK" || echo "✗ Instance Failed"

# Check users
echo "2. Checking users..."
USER_COUNT=$(aws connect list-users --instance-id $INSTANCE_ID --region $REGION --query 'UserSummaryList | length(@)')
echo "✓ Found $USER_COUNT users"

# Check contact flows
echo "3. Checking contact flows..."
FLOW_COUNT=$(aws connect list-contact-flows --instance-id $INSTANCE_ID --region $REGION --query 'ContactFlowSummaryList | length(@)')
echo "✓ Found $FLOW_COUNT contact flows"

# Check queues
echo "4. Checking queues..."
QUEUE_COUNT=$(aws connect list-queues --instance-id $INSTANCE_ID --region $REGION --query 'QueueSummaryList | length(@)')
echo "✓ Found $QUEUE_COUNT queues"

echo "=== Validation Complete ==="
```

### Manual Test Checklist
- [ ] Can access Connect admin panel
- [ ] Can log in as agent
- [ ] Can see assigned queue
- [ ] Can set status to Available/Offline
- [ ] Contact flow publishes without errors
- [ ] Test inbound call routes to queue

---

## 📋 Required Values for Mobile Apps

### For iOS App (Constants.swift)
```
✓ AWS_ACCESS_KEY_ID
✓ AWS_SECRET_ACCESS_KEY
✓ AWS_REGION (us-east-1)
✓ CONNECT_INSTANCE_ID
✓ CONNECT_CONTACT_FLOW_ID
✓ CONNECT_ROUTING_PROFILE_ID
```

### For Android App (build.gradle / local.properties)
```
✓ AWS_ACCESS_KEY_ID
✓ AWS_SECRET_ACCESS_KEY
✓ AWS_REGION (us-east-1)
✓ CONNECT_INSTANCE_ID
✓ CONNECT_INSTANCE_URL
✓ AGENT_ROUTING_PROFILE_ID
✓ Firebase Project ID
```

---

## 📊 Quick Reference Card

| Component | Value | Status |
|-----------|-------|--------|
| AWS Account | [Account ID] | ✓ |
| Instance ID | [ID] | ✓ |
| Instance Name | [Name] | ✓ |
| Instance URL | [URL] | ✓ |
| Region | us-east-1 | ✓ |
| Phone Number | [Number] | ✓ |
| Contact Flow ID | [ID] | ✓ |
| Queue ID | [ID] | ✓ |
| Routing Profile ID | [ID] | ✓ |
| Admin User | [Email] | ✓ |
| Agent User | [Email] | ✓ |
| Mobile Client Role | [ARN] | ✓ |
| Agent App Role | [ARN] | ✓ |

---

## 🎯 Next Steps

After validating all AWS setup:

1. ✅ **AWS Infrastructure Ready** - Move to Phase 2
2. ⬜ **iOS App Development** - See `iOS/README.md`
3. ⬜ **Android App Development** - See `Android/README.md`
4. ⬜ **Integration Testing** - See `IMPLEMENTATION_PLAN.md`

---

**Document Status**: Complete  
**Last Verified**: [Date]  
**AWS Region**: us-east-1  
**Total Setup Time**: ~1-2 hours (depending on experience)
