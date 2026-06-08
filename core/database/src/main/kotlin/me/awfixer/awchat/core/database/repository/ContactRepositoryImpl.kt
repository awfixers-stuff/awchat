package me.awfixer.awchat.core.database.repository

import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map
import me.awfixer.awchat.core.common.result.Result

import me.awfixer.awchat.core.database.dao.ContactDao
import me.awfixer.awchat.core.database.mapper.ContactMapper
import me.awfixer.awchat.core.domain.model.Contact
import me.awfixer.awchat.core.domain.repository.ContactRepository
import me.awfixer.awchat.core.model.UserId
import javax.inject.Inject

class ContactRepositoryImpl @Inject constructor(
    private val contactDao: ContactDao,
) : ContactRepository {

    override fun observeAll(): Flow<List<Contact>> {
        return contactDao.observeAll().map { entities ->
            entities.map(ContactMapper::toDomain)
        }
    }

    override suspend fun getById(userId: UserId): Result<Contact?> {
        val entity = contactDao.getById(userId.value)
        return Result.Success(entity?.let(ContactMapper::toDomain))
    }

    override suspend fun addContact(contact: Contact): Result<Unit> {
        contactDao.insert(ContactMapper.toEntity(contact))
        return Result.Success(Unit)
    }

    override suspend fun updateContact(contact: Contact): Result<Unit> {
        contactDao.update(ContactMapper.toEntity(contact))
        return Result.Success(Unit)
    }

    override suspend fun deleteContact(userId: UserId): Result<Unit> {
        contactDao.deleteById(userId.value)
        return Result.Success(Unit)
    }
}
