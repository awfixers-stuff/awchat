package me.awfixer.awchat.core.domain.usecase

import kotlinx.coroutines.flow.Flow
import me.awfixer.awchat.core.domain.model.Contact
import me.awfixer.awchat.core.domain.repository.ContactRepository
import javax.inject.Inject

class GetContactsUseCase @Inject constructor(
    private val contactRepository: ContactRepository,
) {
    operator fun invoke(): Flow<List<Contact>> = contactRepository.observeAll()
}
