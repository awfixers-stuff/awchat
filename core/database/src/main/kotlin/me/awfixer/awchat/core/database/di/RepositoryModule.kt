package me.awfixer.awchat.core.database.di

import dagger.Binds
import dagger.Module
import dagger.hilt.InstallIn
import dagger.hilt.components.SingletonComponent
import me.awfixer.awchat.core.database.repository.ChatRepositoryImpl
import me.awfixer.awchat.core.database.repository.ContactRepositoryImpl
import me.awfixer.awchat.core.database.repository.MessageRepositoryImpl
import me.awfixer.awchat.core.domain.repository.ChatRepository
import me.awfixer.awchat.core.domain.repository.ContactRepository
import me.awfixer.awchat.core.domain.repository.MessageRepository

@Module
@InstallIn(SingletonComponent::class)
interface RepositoryModule {

    @Binds
    fun bindChatRepository(impl: ChatRepositoryImpl): ChatRepository

    @Binds
    fun bindMessageRepository(impl: MessageRepositoryImpl): MessageRepository

    @Binds
    fun bindContactRepository(impl: ContactRepositoryImpl): ContactRepository
}
