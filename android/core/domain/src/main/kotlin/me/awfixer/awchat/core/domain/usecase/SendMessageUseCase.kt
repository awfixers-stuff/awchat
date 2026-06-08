package me.awfixer.awchat.core.domain.usecase

import me.awfixer.awchat.core.common.result.Result
import me.awfixer.awchat.core.domain.repository.MessageRepository
import me.awfixer.awchat.core.model.ChatId
import me.awfixer.awchat.core.model.MessageId
import javax.inject.Inject

class SendMessageUseCase @Inject constructor(
    private val messageRepository: MessageRepository,
) {
    suspend operator fun invoke(chatId: ChatId, body: String): Result<MessageId> {
        return messageRepository.sendMessage(chatId, body)
    }
}
