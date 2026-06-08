package me.awfixer.awchat.core.database

import androidx.room.Database
import androidx.room.RoomDatabase
import me.awfixer.awchat.core.database.dao.ChatDao
import me.awfixer.awchat.core.database.dao.ContactDao
import me.awfixer.awchat.core.database.dao.MessageDao
import me.awfixer.awchat.core.database.dao.ReadReceiptDao
import me.awfixer.awchat.core.database.dao.SenderKeyDao
import me.awfixer.awchat.core.database.dao.SessionDao
import me.awfixer.awchat.core.database.entity.ChatEntity
import me.awfixer.awchat.core.database.entity.ContactEntity
import me.awfixer.awchat.core.database.entity.MessageEntity
import me.awfixer.awchat.core.database.entity.ReadReceiptEntity
import me.awfixer.awchat.core.database.entity.SenderKeyEntity
import me.awfixer.awchat.core.database.entity.SessionEntity

@Database(
    entities = [
        ChatEntity::class,
        MessageEntity::class,
        ReadReceiptEntity::class,
        SessionEntity::class,
        SenderKeyEntity::class,
        ContactEntity::class,
    ],
    version = 1,
    exportSchema = true,
)
abstract class AwChatDatabase : RoomDatabase() {
    abstract fun chatDao(): ChatDao
    abstract fun messageDao(): MessageDao
    abstract fun readReceiptDao(): ReadReceiptDao
    abstract fun sessionDao(): SessionDao
    abstract fun senderKeyDao(): SenderKeyDao
    abstract fun contactDao(): ContactDao
}
