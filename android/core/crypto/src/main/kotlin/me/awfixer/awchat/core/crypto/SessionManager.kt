package me.awfixer.awchat.core.crypto

import me.awfixer.awchat.core.common.result.Result
import me.awfixer.awchat.core.model.UserId
import org.signal.libsignal.protocol.state.PreKeyBundle

interface SessionManager {
    suspend fun establishSession(
        peerId: UserId,
        preKeyBundle: PreKeyBundle,
    ): Result<Unit>

    suspend fun encrypt(
        peerId: UserId,
        plaintext: ByteArray,
    ): EncryptedEnvelope

    suspend fun decrypt(
        peerId: UserId,
        envelope: EncryptedEnvelope,
    ): Result<ByteArray>
}
