package me.awfixer.awchat.core.security.di

import dagger.Binds
import dagger.Module
import dagger.hilt.InstallIn
import dagger.hilt.components.SingletonComponent
import me.awfixer.awchat.core.common.security.MasterKeyProvider
import me.awfixer.awchat.core.security.keystore.KeystoreMasterKeyProvider
import me.awfixer.awchat.core.security.passphrase.KeystorePassphraseProvider
import me.awfixer.awchat.core.security.passphrase.PassphraseProvider

@Module
@InstallIn(SingletonComponent::class)
interface SecurityModule {

    @Binds
    fun bindMasterKeyProvider(impl: KeystoreMasterKeyProvider): MasterKeyProvider

    @Binds
    fun bindPassphraseProvider(impl: KeystorePassphraseProvider): PassphraseProvider
}
