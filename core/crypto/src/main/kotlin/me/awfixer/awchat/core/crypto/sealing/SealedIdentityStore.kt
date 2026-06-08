package me.awfixer.awchat.core.crypto.sealing

import org.signal.libsignal.protocol.IdentityKeyPair
import java.io.File

class SealedIdentityStore(
    private val sealer: AesGcmSealer,
    private val identityFile: File,
) {
    fun save(identityKeyPair: IdentityKeyPair) {
        identityFile.parentFile?.mkdirs()
        identityFile.writeBytes(sealer.seal(identityKeyPair.serialize()))
    }

    fun load(): IdentityKeyPair {
        val sealed = identityFile.readBytes()
        return IdentityKeyPair(sealer.unseal(sealed))
    }

    fun exists(): Boolean = identityFile.exists()
}