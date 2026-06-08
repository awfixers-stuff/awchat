package me.awfixer.awchat.core.domain.model

import me.awfixer.awchat.core.model.ChatId
import me.awfixer.awchat.core.model.UserId

data class Chat(
    val chatId: ChatId,
    val type: ChatType,
    val name: String?,
    val members: List<UserId>,
    val createdAt: Long,
    val updatedAt: Long,
)

enum class ChatType {
    DIRECT,
    GROUP,
}
