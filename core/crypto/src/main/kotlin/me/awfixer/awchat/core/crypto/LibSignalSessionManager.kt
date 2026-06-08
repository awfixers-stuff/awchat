package me.awfixer.awchat.core.crypto

import kotlinx.coroutines.withContext
import me.awfixer.awchat.core.common.dispatcher.AwChatDispatchers
import me.awfixer.awchat.core.common.result.Result
import me.awfixer.awchat.core.crypto.internal.SignalProtocolAddresses
import me.awfixer.awchat.core.model.UserId
import org.signal.libsignal.protocol.SessionBuilder
import org.signal.libsignal.protocol.SessionCipher
import org.signal.libsignal.protocol.message.CiphertextMessage
import org.signal.libsignal.protocol.message.PreKeySignalMessage
import org.signal.libsignal.protocol.message.SignalMessage
import org.signal.libsignal.protocol.state.PreKeyBundle
import org.signal.libsignal.protocol.state.SignalProtocolStore

class LibSignalSessionManager(
    private val store: SignalProtocolStore,
    private val dispatchers: AwChatDispatchers = AwChatDispatchers(),
) : SessionManager {
    override suspend fun establishSession(
        peerId: UserId,
        preKeyBundle: PreKeyBundle,
    ): Result<Unit> =
        withContext(dispatchers.computation) {
            try {
                SessionBuilder(store, SignalProtocolAddresses.fromUserId(peerId))
                    .process(preKeyBundle)
                Result.Success(Unit)
            } catch (error: Exception) {
                Result.Failure(error)
            }
        }

    override suspend fun encrypt(
        peerId: UserId,
        plaintext: ByteArray,
    ): EncryptedEnvelope =
        withContext(dispatchers.computation) {
            val message =
                SessionCipher(store, SignalProtocolAddresses.fromUserId(peerId))
                    .encrypt(plaintext)
            EncryptedEnvelope(
                ciphertext = message.serialize(),
                messageType = message.type,
            )
        }

    override suspend fun decrypt(
        peerId: UserId,
        envelope: EncryptedEnvelope,
    ): Result<ByteArray> =
        withContext(dispatchers.computation) {
            try {
                val cipher = SessionCipher(store, SignalProtocolAddresses.fromUserId(peerId))
                val plaintext =
                    when (envelope.messageType) {
                        CiphertextMessage.PREKEY_TYPE ->
                            cipher.decrypt(PreKeySignalMessage(envelope.ciphertext))
                        CiphertextMessage.WHISPER_TYPE ->
                            cipher.decrypt(SignalMessage(envelope.ciphertext))
                        else -> error("Unsupported ciphertext type: ${envelope.messageType}")
                    }
                Result.Success(plaintext)
            } catch (error: Exception) {
                Result.Failure(error)
            }
        }
}