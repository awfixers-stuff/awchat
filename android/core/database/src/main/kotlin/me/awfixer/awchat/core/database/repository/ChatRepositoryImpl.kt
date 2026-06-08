package me.awfixer.awchat.core.database.repository

import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map
import me.awfixer.awchat.core.common.result.Result
import me.awfixer.awchat.core.database.dao.ChatDao
import me.awfixer.awchat.core.database.mapper.ChatMapper
import me.awfixer.awchat.core.domain.model.Chat
import me.awfixer.awchat.core.domain.repository.ChatRepository
import me.awfixer.awchat.core.model.ChatId
import me.awfixer.awchat.core.model.UserId
import javax.inject.Inject

class ChatRepositoryImpl @Inject constructor(
    private val chatDao: ChatDao,
) : ChatRepository {

    override fun observeAll(): Flow<List<Chat>> {
        return chatDao.observeAll().map { entities ->
            entities.map(ChatMapper::toDomain)
        }
    }

    override fun observeById(chatId: ChatId): Flow<Chat?> {
        return chatDao.observeById(chatId.value).map { entity ->
            entity?.let(ChatMapper::toDomain)
        }
    }

    override suspend fun getById(chatId: ChatId): Result<Chat?> {
        val entity = chatDao.getById(chatId.value)
        return Result.Success(entity?.let(ChatMapper::toDomain))
    }

    override suspend fun createDirectChat(peerId: UserId): Result<ChatId> {
        // TODO: Implement direct chat creation logic
        throw NotImplementedError("Direct chat creation requires crypto layer integration")
    }

    override suspend fun createGroupChat(memberIds: List<UserId>, name: String?): Result<ChatId> {
        // TODO: Implement group chat creation logic
        throw NotImplementedError("Group chat creation requires server integration")
    }

    override suspend fun updateGroupMembers(chatId: ChatId, add: List<UserId>, remove: List<UserId>): Result<Unit> {
        // TODO: Implement member update logic
        throw NotImplementedError("Member updates require server integration")
    }

    override suspend fun deleteChat(chatId: ChatId): Result<Unit> {
        chatDao.deleteById(chatId.value)
        return Result.Success(Unit)
    }
}
