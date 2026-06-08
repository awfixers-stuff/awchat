package me.awfixer.awchat.core.database.entity

import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity(tableName = "sessions")
data class SessionEntity(
    @PrimaryKey
    val peerId: String,
    val sessionState: ByteArray,
    val updatedAt: Long,
) {
    override fun equals(other: Any?): Boolean {
        if (this === other) return true
        if (javaClass != other?.javaClass) return false

        other as SessionEntity

        if (peerId != other.peerId) return false
        if (!sessionState.contentEquals(other.sessionState)) return false
        if (updatedAt != other.updatedAt) return false

        return true
    }

    override fun hashCode(): Int {
        var result = peerId.hashCode()
        result = 31 * result + sessionState.contentHashCode()
        result = 31 * result + updatedAt.hashCode()
        return result
    }
}
