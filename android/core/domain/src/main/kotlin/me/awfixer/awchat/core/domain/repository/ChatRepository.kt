package me.awfixer.awchat.core.domain.repository

import kotlinx.coroutines.flow.Flow
import me.awfixer.awchat.core.common.result.Result
import me.awfixer.awchat.core.domain.model.Chat
import me.awfixer.awchat.core.model.ChatId
import me.awfixer.awchat.core.model.UserId

interface ChatRepository {
    fun observeAll(): Flow<List<Chat>>
    fun observeById(chatId: ChatId): Flow<Chat?>
    suspend fun getById(chatId: ChatId): Result<Chat?>
    suspend fun createDirectChat(peerId: UserId): Result<ChatId>
    suspend fun createGroupChat(memberIds: List<UserId>, name: String?): Result<ChatId>
    suspend fun updateGroupMembers(chatId: ChatId, add: List<UserId>, remove: List<UserId>): Result<Unit>
    suspend fun deleteChat(chatId: ChatId): Result<Unit>
}
