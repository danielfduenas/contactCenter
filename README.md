# Amazon Connect Mobile Integration - Technical Challenge

Una solución integral de contact center móvil que integra clientes iOS y Android con AWS Amazon Connect para comunicación de voz en tiempo real.

## 📋 Descripción del Proyecto

Este proyecto implementa un sistema de contact center mobile-first utilizando un enfoque híbrido:
- **App iOS (Swift)**: Aplicación para el cliente final que solicita soporte técnico de forma nativa.
- **App Android (Kotlin)**: Panel del agente para gestionar estados y disponibilidad.
- **Infraestructura AWS**: Instancia de Amazon Connect con colas y flujos de contacto.
- **Ruteo de Audio (PSTN)**: Se utiliza la red celular tradicional (configuración *Desk phone*) para el agente, garantizando 100% de fiabilidad en el audio sin la complejidad técnica de WebRTC en dispositivos móviles.

*(Nota: Para este ejercicio técnico, se omitió el uso de AWS Cognito y Lambdas, utilizando credenciales de usuario IAM inyectadas de forma segura en tiempo de compilación).*

## 🎯 Características Principales

### App iOS (Cliente)
- ✅ Interfaz simple con botón "Llamar a Soporte".
- ✅ Estados de llamada en tiempo real (Conectando → Conectado → Finalizada).
- ✅ Firma de peticiones AWS SigV4.
- ✅ Patrón de arquitectura Clean Architecture.

### App Android (Agente)
- ✅ Gestión de estado del agente mediante **AWS Java SDK v2**.
- ✅ **Ruteo PSTN:** Sin necesidad de WebRTC; las llamadas se reciben directamente en la aplicación de teléfono nativa del celular.
- ✅ Sincronización en tiempo real (API `PutUserStatus` para cambiar entre Disponible/Offline).
- ✅ Arquitectura MVVM con Inyección de Dependencias manual (Factories).
- ✅ Configuración segura mediante `local.properties` y `BuildConfig`.

## 📱 Arquitectura

### Diagrama del Sistema
```text
[App Usuario iOS] 
        ↓ (HTTP/REST via AWS SDK)
[Instancia Amazon Connect]
  ├─ Flujo de Contacto (Contact Flow)
  ├─ Gestión de Colas
  └─ Lógica de Ruteo (Transferir al Agente)
        ↓ (Red Celular / PSTN)
[App Agente Android]
  ├─ UI: Dashboard en Jetpack Compose
  ├─ Lógica: AWS Java SDK v2 (Gestión de Estado)
  └─ Audio: App de Teléfono Nativa (Desvío Desk phone)
```

## 🚀 Inicio Rápido

### Requisitos Previos
- **iOS**: Xcode 14+, Swift 5.7+
- **Android**: Android Studio, Kotlin 1.8+, Gradle 8.0+
- **AWS**: Instancia de Amazon Connect activa y usuario Agente configurado como **Desk phone**.

### Configuración de Android (Agente)
1. Clona el repositorio y abre la carpeta `Android` en Android Studio.
2. Crea un archivo `local.properties` en la raíz del proyecto Android y añade tus credenciales y UUIDs de AWS:

```properties
AWS_ACCESS_KEY_ID=TU_ACCESS_KEY
AWS_SECRET_ACCESS_KEY=TU_SECRET_KEY
AWS_REGION=us-west-2
CONNECT_INSTANCE_ID=ID_DE_TU_INSTANCIA
AGENT_USER_ID=UUID_DEL_USUARIO_EN_CONNECT
AGENT_USERNAME=TU_NOMBRE_DE_USUARIO
AGENT_PASSWORD=TU_CONTRASEÑA
AVAILABLE_STATUS_ID=UUID_DEL_ESTADO_AVAILABLE
OFFLINE_STATUS_ID=UUID_DEL_ESTADO_OFFLINE
```

3. Sincroniza el proyecto con Gradle.
4. Ejecuta la app en tu dispositivo físico.

## 🔐 Seguridad y Configuración

- **Secretos Protegidos**: Todas las llaves y UUIDs se extraen de `local.properties` hacia `BuildConfig`, evitando subirlos al control de versiones.
- **SDK Ligero**: Se utiliza `software.amazon.awssdk:connect` (Java v2) optimizado para Android mediante el uso de `UrlConnectionHttpClient`, evitando dependencias pesadas como Netty o Apache que causan crashes en móviles.
- **Política IAM**: El usuario requiere permisos específicos para `connect:PutUserStatus` y acciones de ruteo.

## 📊 Referencias de API

### Android - AWS Connect Java SDK v2 (Cambio de Estado)
La app actualiza el estado del agente directamente con el SDK nativo al entrar al Dashboard:

```kotlin
val request = PutUserStatusRequest.builder()
    .instanceId(BuildConfig.CONNECT_INSTANCE_ID)
    .userId(BuildConfig.AGENT_USER_ID)
    .agentStatusId(BuildConfig.AVAILABLE_STATUS_ID)
    .build()

connectClient.putUserStatus(request)
```

## 🐛 Solución de Problemas (Troubleshooting)

| Problema | Causa / Solución |
|-------|----------|
| **La llamada se cuelga inmediatamente** | **Causa:** AWS bloquea llamadas internacionales por defecto.<br>**Solución:** Usa un número virtual de EE.UU. (+1) en la configuración de Desk phone o pide el desbloqueo de Colombia (+57) en *Service Quotas* de AWS. |
| **El celular no repica** | **Causa:** El agente está configurado como "Softphone" en la consola de AWS.<br>**Solución:** Cambia el tipo de teléfono a "Desk phone" en la gestión de usuarios de Connect. |
| **Error de compilación `AGENT_PASSWORD`** | **Causa:** Espacios accidentales en el archivo `build.gradle`.<br>**Solución:** Asegúrate de que `buildConfigField` use el formato `\"${properties.getProperty(...)}\"` sin espacios adicionales. |
| **Error `Unresolved reference` en SDK** | **Causa:** Uso de SDKs antiguos o falta de sincronización.<br>**Solución:** Asegúrate de usar la versión `2.25.27` de `software.amazon.awssdk` y haber sincronizado Gradle. |

## 📚 Documentación Adicional

- [ARCHITECTURE.md](ARCHITECTURE.md) - Arquitectura detallada del sistema.
- [IMPLEMENTATION_PLAN.md](IMPLEMENTATION_PLAN.md) - Guía de implementación fase por fase.

---
**Última actualización**: 9 de Mayo de 2026  
**Versión**: 1.1.0  
**Estado**: Integración E2E Android & AWS Completada