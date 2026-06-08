package me.awfixer.awchat.core.database.entity

import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity(tableName = "contacts")
data class ContactEntity(
    @PrimaryKey
    val userId: String,
    val displayName: String,
    val safetyNumber: String,
    val identityKey: ByteArray,
    val createdAt: Long,
) {
    override fun equals(other: Any?): Boolean {
        if (this === other) return true
        if (javaClass != other?.javaClass) return false

        other as ContactEntity

        if (userId != other.userId) return false
        if (displayName != other.displayName) return false
        if (safetyNumber != other.safetyNumber) return false
        if (!identityKey.contentEquals(other.identityKey)) return false
        if (createdAt != other.createdAt) return false

        return true
    }

    override fun hashCode(): Int {
        var result = userId.hashCode()
        result = 31 * result + displayName.hashCode()
        result = 31 * result + safetyNumber.hashCode()
        result = 31 * result + identityKey.contentHashCode()
        result = 31 * result + createdAt.hashCode()
        return result
    }
}
