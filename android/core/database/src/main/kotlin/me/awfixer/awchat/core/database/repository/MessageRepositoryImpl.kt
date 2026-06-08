package me.awfixer.awchat.core.database.repository

import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map
import me.awfixer.awchat.core.common.result.Result
import me.awfixer.awchat.core.database.dao.MessageDao
import me.awfixer.awchat.core.database.mapper.MessageMapper
import me.awfixer.awchat.core.domain.model.Message
import me.awfixer.awchat.core.domain.repository.MessageRepository
import me.awfixer.awchat.core.model.ChatId
import me.awfixer.awchat.core.model.MessageId
import me.awfixer.awchat.core.model.UserId
import java.util.UUID
import javax.inject.Inject

class MessageRepositoryImpl @Inject constructor(
    private val messageDao: MessageDao,
) : MessageRepository {

    override fun observeByChatId(chatId: ChatId): Flow<List<Message>> {
        return messageDao.observeByChatId(chatId.value).map { entities ->
            entities.map(MessageMapper::toDomain)
        }
    }

    override suspend fun getById(messageId: MessageId): Result<Message?> {
        val entity = messageDao.getById(messageId.value)
        return Result.Success(entity?.let(MessageMapper::toDomain))
    }

    override suspend fun sendMessage(chatId: ChatId, body: String): Result<MessageId> {
        val messageId = MessageId("msg_${UUID.randomUUID()}")
        val entity = me.awfixer.awchat.core.database.entity.MessageEntity(
            messageId = messageId.value,
            chatId = chatId.value,
            senderId = "self", // TODO: Replace with actual user ID
            body = body,
            clientTimestamp = System.currentTimeMillis(),
            serverTimestamp = null,
            status = "PENDING",
        )
        messageDao.insert(entity)
        return Result.Success(messageId)
    }

    override suspend fun markAsRead(messageId: MessageId, readerId: UserId): Result<Unit> {
        // TODO: Implement read receipt logic
        return Result.Success(Unit)
    }

    override suspend fun deleteMessage(messageId: MessageId): Result<Unit> {
        messageDao.deleteById(messageId.value)
        return Result.Success(Unit)
    }

    override suspend fun deleteByChatId(chatId: ChatId): Result<Unit> {
        messageDao.deleteByChatId(chatId.value)
        return Result.Success(Unit)
    }
}
