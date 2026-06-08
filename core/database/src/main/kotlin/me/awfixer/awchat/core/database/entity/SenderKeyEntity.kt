package me.awfixer.awchat.core.database.entity

import androidx.room.Entity
import androidx.room.Index

@Entity(
    tableName = "sender_keys",
    primaryKeys = ["groupId", "senderId"],
    indices = [
        Index(value = ["groupId"]),
    ],
)
data class SenderKeyEntity(
    val groupId: String,
    val senderId: String,
    val distributionId: String?,
    val senderKeyState: ByteArray,
    val status: String,
    val updatedAt: Long,
) {
    override fun equals(other: Any?): Boolean {
        if (this === other) return true
        if (javaClass != other?.javaClass) return false

        other as SenderKeyEntity

        if (groupId != other.groupId) return false
        if (senderId != other.senderId) return false
        if (distributionId != other.distributionId) return false
        if (!senderKeyState.contentEquals(other.senderKeyState)) return false
        if (status != other.status) return false
        if (updatedAt != other.updatedAt) return false

        return true
    }

    override fun hashCode(): Int {
        var result = groupId.hashCode()
        result = 31 * result + senderId.hashCode()
        result = 31 * result + (distributionId?.hashCode() ?: 0)
        result = 31 * result + senderKeyState.contentHashCode()
        result = 31 * result + status.hashCode()
        result = 31 * result + updatedAt.hashCode()
        return result
    }
}
