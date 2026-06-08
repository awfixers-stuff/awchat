package me.awfixer.awchat.core.domain.repository

import kotlinx.coroutines.flow.Flow
import me.awfixer.awchat.core.common.result.Result
import me.awfixer.awchat.core.domain.model.Message
import me.awfixer.awchat.core.model.ChatId
import me.awfixer.awchat.core.model.MessageId
import me.awfixer.awchat.core.model.UserId

interface MessageRepository {
    fun observeByChatId(chatId: ChatId): Flow<List<Message>>
    suspend fun getById(messageId: MessageId): Result<Message?>
    suspend fun sendMessage(chatId: ChatId, body: String): Result<MessageId>
    suspend fun markAsRead(messageId: MessageId, readerId: UserId): Result<Unit>
    suspend fun deleteMessage(messageId: MessageId): Result<Unit>
    suspend fun deleteByChatId(chatId: ChatId): Result<Unit>
}
