package me.awfixer.awchat.core.security.passphrase

interface PassphraseProvider {
    fun getOrCreateDatabasePassphrase(): ByteArray
}
