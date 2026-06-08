package me.awfixer.awchat.core.database.dao

import androidx.room.Dao
import androidx.room.Delete
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query
import me.awfixer.awchat.core.database.entity.SenderKeyEntity

@Dao
interface SenderKeyDao {
    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insert(senderKey: SenderKeyEntity)

    @Delete
    suspend fun delete(senderKey: SenderKeyEntity)

    @Query("DELETE FROM sender_keys WHERE groupId = :groupId AND senderId = :senderId")
    suspend fun deleteByGroupAndSender(groupId: String, senderId: String)

    @Query("DELETE FROM sender_keys WHERE groupId = :groupId")
    suspend fun deleteByGroupId(groupId: String)

    @Query("SELECT * FROM sender_keys WHERE groupId = :groupId")
    suspend fun getByGroupId(groupId: String): List<SenderKeyEntity>

    @Query("SELECT * FROM sender_keys WHERE groupId = :groupId AND senderId = :senderId")
    suspend fun getByGroupAndSender(groupId: String, senderId: String): SenderKeyEntity?

    @Query("DELETE FROM sender_keys")
    suspend fun deleteAll()
}
