package me.awfixer.awchat.core.database.mapper

import me.awfixer.awchat.core.database.entity.ContactEntity
import me.awfixer.awchat.core.domain.model.Contact
import me.awfixer.awchat.core.model.UserId

object ContactMapper {

    fun toDomain(entity: ContactEntity): Contact {
        return Contact(
            userId = UserId(entity.userId),
            displayName = entity.displayName,
            safetyNumber = entity.safetyNumber,
            identityKey = entity.identityKey,
            createdAt = entity.createdAt,
        )
    }

    fun toEntity(domain: Contact): ContactEntity {
        return ContactEntity(
            userId = domain.userId.value,
            displayName = domain.displayName,
            safetyNumber = domain.safetyNumber,
            identityKey = domain.identityKey,
            createdAt = domain.createdAt,
        )
    }
}
