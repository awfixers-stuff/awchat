package me.awfixer.awchat.core.database.mapper

import me.awfixer.awchat.core.database.entity.ChatEntity
import me.awfixer.awchat.core.domain.model.Chat
import me.awfixer.awchat.core.domain.model.ChatType
import me.awfixer.awchat.core.model.ChatId

object ChatMapper {

    fun toDomain(entity: ChatEntity): Chat {
        return Chat(
            chatId = ChatId(entity.chatId),
            type = ChatType.valueOf(entity.type),
            name = entity.name,
            members = emptyList(), // Populated separately via member query
            createdAt = entity.createdAt,
            updatedAt = entity.updatedAt,
        )
    }

    fun toEntity(domain: Chat): ChatEntity {
        return ChatEntity(
            chatId = domain.chatId.value,
            type = domain.type.name,
            name = domain.name,
            createdAt = domain.createdAt,
            updatedAt = domain.updatedAt,
        )
    }
}
