package me.awfixer.awchat.core.database.entity

import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity(tableName = "chats")
data class ChatEntity(
    @PrimaryKey
    val chatId: String,
    val type: String,
    val name: String?,
    val createdAt: Long,
    val updatedAt: Long,
)
