package me.awfixer.awchat.core.database.dao

import androidx.room.Dao
import androidx.room.Delete
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query
import me.awfixer.awchat.core.database.entity.SessionEntity

@Dao
interface SessionDao {
    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insert(session: SessionEntity)

    @Delete
    suspend fun delete(session: SessionEntity)

    @Query("DELETE FROM sessions WHERE peerId = :peerId")
    suspend fun deleteByPeerId(peerId: String)

    @Query("SELECT * FROM sessions WHERE peerId = :peerId")
    suspend fun getByPeerId(peerId: String): SessionEntity?

    @Query("DELETE FROM sessions")
    suspend fun deleteAll()
}
