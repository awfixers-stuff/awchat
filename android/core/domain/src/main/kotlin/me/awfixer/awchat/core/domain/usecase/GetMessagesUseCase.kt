package me.awfixer.awchat.core.domain.usecase

import kotlinx.coroutines.flow.Flow
import me.awfixer.awchat.core.domain.model.Message
import me.awfixer.awchat.core.domain.repository.MessageRepository
import me.awfixer.awchat.core.model.ChatId
import javax.inject.Inject

class GetMessagesUseCase @Inject constructor(
    private val messageRepository: MessageRepository,
) {
    operator fun invoke(chatId: ChatId): Flow<List<Message>> = messageRepository.observeByChatId(chatId)
}
