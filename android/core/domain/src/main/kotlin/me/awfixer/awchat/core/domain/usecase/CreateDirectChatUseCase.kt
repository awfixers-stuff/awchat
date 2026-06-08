package me.awfixer.awchat.core.domain.usecase

import me.awfixer.awchat.core.common.result.Result
import me.awfixer.awchat.core.domain.repository.ChatRepository
import me.awfixer.awchat.core.model.ChatId
import me.awfixer.awchat.core.model.UserId
import javax.inject.Inject

class CreateDirectChatUseCase @Inject constructor(
    private val chatRepository: ChatRepository,
) {
    suspend operator fun invoke(peerId: UserId): Result<ChatId> {
        return chatRepository.createDirectChat(peerId)
    }
}
