package me.awfixer.awchat.core.common.security

interface MasterKeyProvider {
    fun getOrCreateMasterKey(): ByteArray
}
