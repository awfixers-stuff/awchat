package me.awfixer.awchat.core.crypto.internal

import org.signal.libsignal.protocol.InvalidKeyException
import org.signal.libsignal.protocol.ecc.ECKeyPair
import org.signal.libsignal.protocol.kem.KEMKeyPair
import org.signal.libsignal.protocol.kem.KEMKeyType
import org.signal.libsignal.protocol.state.KyberPreKeyRecord
import org.signal.libsignal.protocol.state.PreKeyBundle
import org.signal.libsignal.protocol.state.PreKeyRecord
import org.signal.libsignal.protocol.state.SignalProtocolStore
import org.signal.libsignal.protocol.state.SignedPreKeyRecord
import org.signal.libsignal.protocol.util.Medium
import kotlin.random.Random

internal object PreKeyBundleFactory {
    @Throws(InvalidKeyException::class)
    fun createBundle(store: SignalProtocolStore): PreKeyBundle {
        val preKeyPair = ECKeyPair.generate()
        val signedPreKeyPair = ECKeyPair.generate()
        val signedPreKeySignature =
            store.identityKeyPair.privateKey.calculateSignature(
                signedPreKeyPair.publicKey.serialize(),
            )
        val kyberPreKeyPair = KEMKeyPair.generate(KEMKeyType.KYBER_1024)
        val kyberPreKeySignature =
            store.identityKeyPair.privateKey.calculateSignature(
                kyberPreKeyPair.publicKey.serialize(),
            )

        val preKeyId = Random.nextInt(Medium.MAX_VALUE)
        val signedPreKeyId = Random.nextInt(Medium.MAX_VALUE)
        val kyberPreKeyId = Random.nextInt(Medium.MAX_VALUE)

        store.storePreKey(preKeyId, PreKeyRecord(preKeyId, preKeyPair))
        store.storeSignedPreKey(
            signedPreKeyId,
            SignedPreKeyRecord(
                signedPreKeyId,
                System.currentTimeMillis(),
                signedPreKeyPair,
                signedPreKeySignature,
            ),
        )
        store.storeKyberPreKey(
            kyberPreKeyId,
            KyberPreKeyRecord(
                kyberPreKeyId,
                System.currentTimeMillis(),
                kyberPreKeyPair,
                kyberPreKeySignature,
            ),
        )

        return PreKeyBundle(
            store.localRegistrationId,
            1,
            preKeyId,
            preKeyPair.publicKey,
            signedPreKeyId,
            signedPreKeyPair.publicKey,
            signedPreKeySignature,
            store.identityKeyPair.publicKey,
            kyberPreKeyId,
            kyberPreKeyPair.publicKey,
            kyberPreKeySignature,
        )
    }
}
