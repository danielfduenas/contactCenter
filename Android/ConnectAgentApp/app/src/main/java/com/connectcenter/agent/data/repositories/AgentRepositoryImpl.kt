package com.connectcenter.agent.data.repositories

import com.connectcenter.agent.BuildConfig
import com.connectcenter.agent.domain.entities.Agent
import com.connectcenter.agent.domain.entities.AgentState
import com.connectcenter.agent.domain.repositories.AgentRepository
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.flow
import kotlinx.coroutines.withContext

// Importamos el SDK v2 moderno
import software.amazon.awssdk.auth.credentials.AwsBasicCredentials
import software.amazon.awssdk.auth.credentials.StaticCredentialsProvider
import software.amazon.awssdk.http.urlconnection.UrlConnectionHttpClient
import software.amazon.awssdk.regions.Region
import software.amazon.awssdk.services.connect.ConnectClient
// El request correcto para la API de Connect
import software.amazon.awssdk.services.connect.model.PutUserStatusRequest

class AgentRepositoryImpl : AgentRepository {

    // Cargamos las credenciales inyectadas de forma segura
    private val accessKey = BuildConfig.AWS_ACCESS_KEY_ID
    private val secretKey = BuildConfig.AWS_SECRET_ACCESS_KEY
    private val region = BuildConfig.AWS_REGION
    private val instanceId = BuildConfig.CONNECT_INSTANCE_ID

    private lateinit var connectClient: ConnectClient

    // Cargamos los IDs de configuración
    private val agentUserId = BuildConfig.AGENT_USER_ID
    private val availableStatusId = BuildConfig.AVAILABLE_STATUS_ID
    private val offlineStatusId = BuildConfig.OFFLINE_STATUS_ID

    init {
        setupAWS()
    }

    private fun setupAWS() {
        val credentials = StaticCredentialsProvider.create(
            AwsBasicCredentials.create(accessKey, secretKey)
        )

        // Usamos el cliente nativo HTTP de Android para evitar crashes
        connectClient = ConnectClient.builder()
            .region(Region.of(region))
            .credentialsProvider(credentials)
            .httpClientBuilder(UrlConnectionHttpClient.builder())
            .build()

        println("📱 AWS Connect V2 Client inicializado para la instancia: $instanceId")
    }

    override suspend fun getAgentStatus(): Result<Agent> = withContext(Dispatchers.IO) {
        return@withContext try {
            val agent = Agent(
                id = agentUserId,
                username = BuildConfig.AGENT_USERNAME,
                name = "Agente PSTN",
                state = AgentState.AVAILABLE
            )
            Result.success(agent)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    override suspend fun setAgentStatus(state: String): Result<Boolean> = withContext(Dispatchers.IO) {
        return@withContext try {
            val targetStatusId = if (state.equals("AVAILABLE", ignoreCase = true)) {
                availableStatusId
            } else {
                offlineStatusId
            }

            // Usamos el PutUserStatusRequest del SDK v2
            val request = PutUserStatusRequest.builder()
                .instanceId(this@AgentRepositoryImpl.instanceId)
                .userId(agentUserId)
                .agentStatusId(targetStatusId)
                .build()

            // Llamamos a la API correcta: putUserStatus
            connectClient.putUserStatus(request)
            println("✅ Estado del agente actualizado a: $state en AWS Connect")

            Result.success(true)
        } catch (e: Exception) {
            println("❌ Error actualizando estado en AWS: ${e.message}")
            e.printStackTrace()
            Result.failure(e)
        }
    }

    override fun monitorAgentStatus(): Flow<Agent> = flow {
        // TODO: En el futuro se puede implementar un EventBridge o Polling aquí
    }
}