package me.awfixer.awchat.core.domain.repository

import kotlinx.coroutines.flow.Flow
import me.awfixer.awchat.core.common.result.Result
import me.awfixer.awchat.core.domain.model.Contact
import me.awfixer.awchat.core.model.UserId

interface ContactRepository {
    fun observeAll(): Flow<List<Contact>>
    suspend fun getById(userId: UserId): Result<Contact?>
    suspend fun addContact(contact: Contact): Result<Unit>
    suspend fun updateContact(contact: Contact): Result<Unit>
    suspend fun deleteContact(userId: UserId): Result<Unit>
}
