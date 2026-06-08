package me.awfixer.awchat.core.database.dao

import androidx.room.Dao
import androidx.room.Delete
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query
import kotlinx.coroutines.flow.Flow
import me.awfixer.awchat.core.database.entity.MessageEntity

@Dao
interface MessageDao {
    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insert(message: MessageEntity)

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertAll(messages: List<MessageEntity>)

    @Delete
    suspend fun delete(message: MessageEntity)

    @Query("DELETE FROM messages WHERE messageId = :messageId")
    suspend fun deleteById(messageId: String)

    @Query("DELETE FROM messages WHERE chatId = :chatId")
    suspend fun deleteByChatId(chatId: String)

    @Query("SELECT * FROM messages WHERE chatId = :chatId ORDER BY clientTimestamp ASC")
    fun observeByChatId(chatId: String): Flow<List<MessageEntity>>

    @Query("SELECT * FROM messages WHERE messageId = :messageId")
    suspend fun getById(messageId: String): MessageEntity?

    @Query("SELECT * FROM messages WHERE chatId = :chatId ORDER BY clientTimestamp DESC LIMIT 1")
    suspend fun getLatestByChatId(chatId: String): MessageEntity?
}
