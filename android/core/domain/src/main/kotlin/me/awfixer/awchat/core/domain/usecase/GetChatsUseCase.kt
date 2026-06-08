package me.awfixer.awchat.core.domain.usecase

import kotlinx.coroutines.flow.Flow
import me.awfixer.awchat.core.domain.model.Chat
import me.awfixer.awchat.core.domain.repository.ChatRepository
import javax.inject.Inject

class GetChatsUseCase @Inject constructor(
    private val chatRepository: ChatRepository,
) {
    operator fun invoke(): Flow<List<Chat>> = chatRepository.observeAll()
}
