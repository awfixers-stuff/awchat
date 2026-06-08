package me.awfixer.awchat.core.database.entity

import androidx.room.Entity
import androidx.room.ForeignKey
import androidx.room.Index

@Entity(
    tableName = "read_receipts",
    primaryKeys = ["messageId", "readerId"],
    foreignKeys = [
        ForeignKey(
            entity = MessageEntity::class,
            parentColumns = ["messageId"],
            childColumns = ["messageId"],
            onDelete = ForeignKey.CASCADE,
        ),
    ],
    indices = [
        Index(value = ["messageId"]),
    ],
)
data class ReadReceiptEntity(
    val messageId: String,
    val readerId: String,
    val seenAt: Long,
)
