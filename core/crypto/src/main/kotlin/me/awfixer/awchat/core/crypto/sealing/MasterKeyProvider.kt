package me.awfixer.awchat.core.crypto.sealing

interface MasterKeyProvider {
    fun getOrCreateMasterKey(): ByteArray
}