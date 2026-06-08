package me.awfixer.awchat.core.database.mapper

import me.awfixer.awchat.core.database.entity.MessageEntity
import me.awfixer.awchat.core.domain.model.Message
import me.awfixer.awchat.core.domain.model.MessageStatus
import me.awfixer.awchat.core.model.ChatId
import me.awfixer.awchat.core.model.MessageId
import me.awfixer.awchat.core.model.UserId

object MessageMapper {

    fun toDomain(entity: MessageEntity): Message {
        return Message(
            messageId = MessageId(entity.messageId),
            chatId = ChatId(entity.chatId),
            senderId = UserId(entity.senderId),
            body = entity.body,
            clientTimestamp = entity.clientTimestamp,
            serverTimestamp = entity.serverTimestamp,
            status = MessageStatus.valueOf(entity.status),
        )
    }

    fun toEntity(domain: Message): MessageEntity {
        return MessageEntity(
            messageId = domain.messageId.value,
            chatId = domain.chatId.value,
            senderId = domain.senderId.value,
            body = domain.body,
            clientTimestamp = domain.clientTimestamp,
            serverTimestamp = domain.serverTimestamp,
            status = domain.status.name,
        )
    }
}
