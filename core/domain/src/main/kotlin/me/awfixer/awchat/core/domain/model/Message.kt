package me.awfixer.awchat.core.domain.model

import me.awfixer.awchat.core.model.ChatId
import me.awfixer.awchat.core.model.MessageId
import me.awfixer.awchat.core.model.UserId

data class Message(
    val messageId: MessageId,
    val chatId: ChatId,
    val senderId: UserId,
    val body: String,
    val clientTimestamp: Long,
    val serverTimestamp: Long?,
    val status: MessageStatus,
)

enum class MessageStatus {
    PENDING,
    SENT,
    DELIVERED,
    READ,
    FAILED,
}
