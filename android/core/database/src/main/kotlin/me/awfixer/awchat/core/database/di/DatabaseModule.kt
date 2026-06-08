package me.awfixer.awchat.core.database.di

import android.content.Context
import androidx.room.Room
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.android.qualifiers.ApplicationContext
import dagger.hilt.components.SingletonComponent
import me.awfixer.awchat.core.database.AwChatDatabase
import me.awfixer.awchat.core.database.dao.ChatDao
import me.awfixer.awchat.core.database.dao.ContactDao
import me.awfixer.awchat.core.database.dao.MessageDao
import me.awfixer.awchat.core.database.dao.ReadReceiptDao
import me.awfixer.awchat.core.database.dao.SenderKeyDao
import me.awfixer.awchat.core.database.dao.SessionDao
import me.awfixer.awchat.core.security.passphrase.PassphraseProvider
import net.zetetic.database.sqlcipher.SupportOpenHelperFactory
import javax.inject.Singleton

@Module
@InstallIn(SingletonComponent::class)
object DatabaseModule {

    @Provides
    @Singleton
    fun provideDatabase(
        @ApplicationContext context: Context,
        passphraseProvider: PassphraseProvider,
    ): AwChatDatabase {
        val passphrase = passphraseProvider.getOrCreateDatabasePassphrase()
        return Room.databaseBuilder(
            context,
            AwChatDatabase::class.java,
            "awchat.db",
        )
            .openHelperFactory(SupportOpenHelperFactory(passphrase))
            .fallbackToDestructiveMigration(false)
            .build()
    }

    @Provides
    fun provideChatDao(database: AwChatDatabase): ChatDao = database.chatDao()

    @Provides
    fun provideMessageDao(database: AwChatDatabase): MessageDao = database.messageDao()

    @Provides
    fun provideReadReceiptDao(database: AwChatDatabase): ReadReceiptDao = database.readReceiptDao()

    @Provides
    fun provideSessionDao(database: AwChatDatabase): SessionDao = database.sessionDao()

    @Provides
    fun provideSenderKeyDao(database: AwChatDatabase): SenderKeyDao = database.senderKeyDao()

    @Provides
    fun provideContactDao(database: AwChatDatabase): ContactDao = database.contactDao()
}
