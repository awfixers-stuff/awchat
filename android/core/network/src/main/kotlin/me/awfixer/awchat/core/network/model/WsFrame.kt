package me.awfixer.awchat.core.network.model

import kotlinx.serialization.Serializable

@Serializable
sealed interface WsFrame {
    val type: String
}

@Serializable
data class AuthChallenge(
    val nonce: String,
    val serverTime: String,
    val ttlSec: Int,
) : WsFrame {
    override val type: String = "auth_challenge"
}

@Serializable
data class AuthResponse(
    val userId: String,
    val nonce: String,
    val serverTime: String,
    val signature: String,
) : WsFrame {
    override val type: String = "auth_response"
}

@Serializable
data class AuthOk(
    val connectionId: String,
) : WsFrame {
    override val type: String = "auth_ok"
}

@Serializable
data class AuthFailed(
    val code: String,
    val message: String,
) : WsFrame {
    override val type: String = "auth_failed"
}

@Serializable
data class EnvelopeFrame(
    val id: String,
    val chatId: String,
    val senderId: String,
    val ciphertext: String,
    val sentAt: String,
) : WsFrame {
    override val type: String = "envelope"
}

@Serializable
data class AckFrame(
    val envelopeId: String,
    val receivedAt: String,
) : WsFrame {
    override val type: String = "ack"
}

@Serializable
data class NackFrame(
    val envelopeId: String,
    val reason: String,
) : WsFrame {
    override val type: String = "nack"
}

@Serializable
data class PurgeNotifyFrame(
    val messageId: String,
    val chatId: String,
    val purgedAt: String,
) : WsFrame {
    override val type: String = "purge_notify"
}

@Serializable
data class ErrorFrame(
    val code: String,
    val message: String,
) : WsFrame {
    override val type: String = "error"
}
