package me.awfixer.awchat.core.network.websocket

import io.ktor.client.HttpClient
import io.ktor.client.plugins.websocket.webSocketSession
import io.ktor.websocket.Frame
import io.ktor.websocket.readText
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.MutableSharedFlow
import kotlinx.coroutines.flow.asSharedFlow
import kotlinx.coroutines.flow.filter
import kotlinx.coroutines.flow.flow
import kotlinx.coroutines.flow.map
import kotlinx.serialization.encodeToString
import kotlinx.serialization.json.Json
import me.awfixer.awchat.core.network.model.AuthChallenge
import me.awfixer.awchat.core.network.model.AuthResponse
import me.awfixer.awchat.core.network.model.EnvelopeFrame
import me.awfixer.awchat.core.network.model.PurgeNotifyFrame
import me.awfixer.awchat.core.network.model.WsFrame
import javax.inject.Inject

class AwChatWebSocketClient @Inject constructor(
    private val client: HttpClient,
    private val json: Json,
) {

    private val _incomingFrames = MutableSharedFlow<WsFrame>()
    val incomingFrames: Flow<WsFrame> = _incomingFrames.asSharedFlow()

    suspend fun connect(url: String) {
        val session = client.webSocketSession(url)
        for (frame in session.incoming) {
            when (frame) {
                is Frame.Text -> {
                    val text = frame.readText()
                    val wsFrame = parseFrame(text)
                    _incomingFrames.emit(wsFrame)
                }
                else -> { /* ignore binary frames */ }
            }
        }
    }

    fun observeEnvelopes(): Flow<EnvelopeFrame> {
        return incomingFrames
            .filter { it is EnvelopeFrame }
            .map { it as EnvelopeFrame }
    }

    fun observePurgeNotifies(): Flow<PurgeNotifyFrame> {
        return incomingFrames
            .filter { it is PurgeNotifyFrame }
            .map { it as PurgeNotifyFrame }
    }

    private fun parseFrame(text: String): WsFrame {
        return json.decodeFromString<WsFrame>(text)
    }
}
