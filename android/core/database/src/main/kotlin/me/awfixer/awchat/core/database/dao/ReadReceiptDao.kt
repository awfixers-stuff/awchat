package me.awfixer.awchat.core.database.dao

import androidx.room.Dao
import androidx.room.Delete
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query
import me.awfixer.awchat.core.database.entity.ReadReceiptEntity

@Dao
interface ReadReceiptDao {
    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insert(receipt: ReadReceiptEntity)

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertAll(receipts: List<ReadReceiptEntity>)

    @Delete
    suspend fun delete(receipt: ReadReceiptEntity)

    @Query("DELETE FROM read_receipts WHERE messageId = :messageId")
    suspend fun deleteByMessageId(messageId: String)

    @Query("SELECT * FROM read_receipts WHERE messageId = :messageId")
    suspend fun getByMessageId(messageId: String): List<ReadReceiptEntity>
}
