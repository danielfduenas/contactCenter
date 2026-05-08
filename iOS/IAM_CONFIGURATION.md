# iOS App: IAM Credentials Configuration Guide

## Overview

La aplicación iOS utiliza **credenciales IAM directas** (Access Key ID + Secret Access Key) para autenticarse con AWS Connect. No se utiliza AWS Cognito ni roles de sesión temporal.

Este enfoque permite que la app iOS inicie llamadas directamente a través de la API `StartOutboundVoiceContact`, que requiere permisos administrativos.

---

## ✅ Prerequisites

1. **AWS Account** con acceso a Amazon Connect
2. **IAM User** con permisos para Amazon Connect (ver sección "Permisos IAM Requeridos")
3. **Access Key ID** y **Secret Access Key** del usuario IAM
4. **Amazon Connect Instance ID**, **Queue ID**, y **Contact Flow ID**

---

## 🔐 IAM User Setup

### 1. Crear un Usuario IAM Dedicado

```bash
# Opción 1: Vía AWS CLI
aws iam create-user --user-name connect-mobile-app-user
```

**Opción 2: Vía AWS Console**
- Ir a IAM → Users → Create user
- Nombre: `connect-mobile-app-user`

### 2. Permisos IAM Requeridos

Crear una política IAM con los siguientes permisos:

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
            "Resource": "arn:aws:connect:REGION:ACCOUNT_ID:instance/INSTANCE_ID"
        },
        {
            "Sid": "GetContactAttributes",
            "Effect": "Allow",
            "Action": [
                "connect:GetContactAttributes"
            ],
            "Resource": "arn:aws:connect:REGION:ACCOUNT_ID:instance/INSTANCE_ID/contact/*"
        },
        {
            "Sid": "UpdateContactAttributes",
            "Effect": "Allow",
            "Action": [
                "connect:UpdateContactAttributes"
            ],
            "Resource": "arn:aws:connect:REGION:ACCOUNT_ID:instance/INSTANCE_ID/contact/*"
        },
        {
            "Sid": "DescribeContact",
            "Effect": "Allow",
            "Action": [
                "connect:DescribeContact"
            ],
            "Resource": "arn:aws:connect:REGION:ACCOUNT_ID:instance/INSTANCE_ID/contact/*"
        }
    ]
}
```

**Reemplazar:**
- `REGION`: Tu región AWS (ej: `us-west-2`)
- `ACCOUNT_ID`: Tu ID de cuenta AWS
- `INSTANCE_ID`: Tu Instance ID de Amazon Connect

### 3. Crear Access Key

```bash
# Vía AWS CLI
aws iam create-access-key --user-name connect-mobile-app-user
```

**Respuesta:**
```json
{
    "AccessKey": {
        "UserName": "connect-mobile-app-user",
        "AccessKeyId": "AKIAIOSFODNN7EXAMPLE",
        "SecretAccessKey": "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY",
        "Status": "Active",
        "CreateDate": "2025-05-08T..."
    }
}
```

⚠️ **IMPORTANTE**: Guardar el `SecretAccessKey` de forma segura. No se puede recuperar después.

---

## 📱 iOS App Configuration

### Opción 1: Variables de Entorno

La app carga automáticamente desde variables de entorno:

```bash
export AWS_ACCESS_KEY_ID="AKIAIOSFODNN7EXAMPLE"
export AWS_SECRET_ACCESS_KEY="wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
export AWS_SESSION_TOKEN=""  # Dejar vacío para IAM User
export AWS_REGION="us-west-2"
export CONNECT_INSTANCE_ID="xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
export CONNECT_QUEUE_ID="xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
export CONNECT_CONTACT_FLOW_ID="xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
```

### Opción 2: Info.plist (Para desarrollo local)

**Editar** `Info.plist`:

```xml
<key>AWS_ACCESS_KEY_ID</key>
<string>AKIAIOSFODNN7EXAMPLE</string>
<key>AWS_SECRET_ACCESS_KEY</key>
<string>wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY</string>
<key>AWS_REGION</key>
<string>us-west-2</string>
<key>CONNECT_INSTANCE_ID</key>
<string>xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx</string>
<key>CONNECT_QUEUE_ID</key>
<string>xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx</string>
<key>CONNECT_CONTACT_FLOW_ID</key>
<string>xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx</string>
```

### Opción 3: Archivo de Configuración

**Crear** `ConnectMobileUser/Config/aws-config.json`:

```json
{
    "aws": {
        "accessKeyId": "AKIAIOSFODNN7EXAMPLE",
        "secretAccessKey": "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY",
        "region": "us-west-2"
    },
    "connect": {
        "instanceId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
        "queueId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
        "contactFlowId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
    }
}
```

---

## 🔑 Obtener Amazon Connect Configuration

### Instance ID

```bash
# Vía AWS CLI
aws connect list-instances --region us-west-2
```

**Respuesta:**
```json
{
    "InstanceSummaryList": [
        {
            "Id": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
            "Arn": "arn:aws:connect:us-west-2:123456789:instance/xxxxxxxx...",
            "Name": "MyInstance"
        }
    ]
}
```

### Queue ID

```bash
# Vía AWS CLI
aws connect list-queues --instance-id xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx --region us-west-2
```

### Contact Flow ID

```bash
# Vía AWS CLI
aws connect list-contact-flows --instance-id xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx --region us-west-2
```

O vía **AWS Console**:
- Ir a Amazon Connect → Your Instance → Contact Flows
- Seleccionar el Contact Flow → Copiar Flow ID (en la URL o detalles)

---

## 📋 Como Funciona el Flujo de Autenticación

```
┌─────────────────────────────────────────┐
│  Usuario tapa "Iniciar Llamada"          │
└────────────────┬────────────────────────┘
                 ↓
┌─────────────────────────────────────────┐
│  CallViewModel.initiateCall()            │
└────────────────┬────────────────────────┘
                 ↓
┌─────────────────────────────────────────┐
│  Verificar permiso de micrófono          │
└────────────────┬────────────────────────┘
                 ↓
┌─────────────────────────────────────────┐
│  AWSConnectClient.startOutboundVoiceContact()
│  ├─ Lee credenciales IAM de env vars    │
│  ├─ Inicializa AWS SDK con credenciales│
│  └─ Llama API StartOutboundVoiceContact│
└────────────────┬────────────────────────┘
                 ↓
┌─────────────────────────────────────────┐
│  AWS SDK valida credenciales            │
│  ├─ Verifica Access Key ID              │
│  ├─ Verifica Secret Access Key          │
│  └─ Verifica permisos IAM               │
└────────────────┬────────────────────────┘
                 ↓
      ┌──────────┴──────────┐
      ↓                     ↓
   ÉXITO                  ERROR
   Contact ID             CallError
   generado               (sin permisos,
   ✅                      credenciales inválidas, etc)
                           ❌
```

---

## 🛡️ Seguridad & Mejores Prácticas

### ✅ RECOMENDADO (Desarrollo/Testing)
- ✓ Variables de entorno
- ✓ Info.plist con valores de desarrollo
- ✓ Archivo de configuración sin versionar

### ⚠️ NO RECOMENDADO (Producción)
- ✗ Hardcoding de credenciales en código
- ✗ Commitar credenciales a Git
- ✗ Usar credenciales de root IAM

### 🔐 PARA PRODUCCIÓN

1. **Usar AWS Cognito Federated Identities** (si requieres OAuth):
   - Cambiar a `AWSCognitoCredentialsProvider`
   - Configurar Identity Pool en Cognito
   - Los usuarios se autentican con Cognito
   - Reciben credenciales de sesión temporal

2. **Usar Temporary Security Credentials**:
   - Usar `AWSBasicSessionCredentialsProvider` con `sessionToken`
   - Las credenciales expiran automáticamente
   - Más seguro que permanentes

3. **Integrar con Backend API**:
   - Backend valida usuario
   - Backend retorna credenciales de sesión temporal
   - App usa credenciales temporales
   - Expiración automática

4. **Keychain Storage**:
   - Almacenar credenciales en Keychain del dispositivo
   - No en UserDefaults ni en memoria
   - KeychainSwift ya está en el Podfile

---

## 🧪 Verificar Configuración

### Opción 1: Vía Xcode Console Logs

Ejecutar la app y revisar logs:
```
✅ "Outbound voice contact started with contact ID: xxxxxxxx..."
❌ "Failed to start outbound voice contact: AccessDenied..."
```

### Opción 2: Vía AWS CLI

```bash
# Verificar que el usuario IAM tiene permisos
aws iam get-user-policy --user-name connect-mobile-app-user --policy-name ConnectPolicy
```

### Opción 3: Vía CloudTrail

- Ir a AWS Console → CloudTrail
- Buscar eventos de `StartOutboundVoiceContact`
- Revisar details para ver errores específicos

---

## ❌ Troubleshooting

### Error: "InvalidParameterException: Instance Id is invalid"
- ✓ Verificar Instance ID es correcto
- ✓ Verificar región AWS coincide con Instance

### Error: "AccessDenied"
- ✓ Verificar Access Key ID es válido
- ✓ Verificar Secret Access Key es correcto
- ✓ Verificar usuario IAM tiene permisos `connect:StartOutboundVoiceContact`
- ✓ Verificar ARN en política incluye Instance ID correcto

### Error: "ValidationException: The Queue Id is invalid"
- ✓ Verificar Queue ID es válido
- ✓ Verificar Queue existe en Instance

### Error: "The contact flow does not exist or is not in PUBLISHED state"
- ✓ Verificar Contact Flow ID es correcto
- ✓ Verificar Contact Flow está en estado "Published" (no "Saved Draft")

### La app se conecta pero sin audio
- ✓ Verificar permiso de micrófono está concedido
- ✓ Revisar Contact Flow incluye "Set Microphone Off" → "Set Microphone On"
- ✓ Verificar AWS Connect Instance está configurada para voice

---

## 📞 Soporte

- **AWS IAM Docs**: https://docs.aws.amazon.com/IAM/
- **Amazon Connect Docs**: https://docs.aws.amazon.com/connect/
- **AWS SDK for iOS**: https://docs.aws.amazon.com/sdk-for-ios/

---

**Última actualización**: 8 de mayo de 2026  
**Tipo de Autenticación**: IAM User (Credenciales permanentes)  
**Estado**: ✅ Configuración sin Cognito
