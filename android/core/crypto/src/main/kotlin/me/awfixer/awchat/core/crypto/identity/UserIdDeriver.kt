package me.awfixer.awchat.core.crypto.identity

import me.awfixer.awchat.core.model.UserId
import org.signal.libsignal.protocol.IdentityKeyPair
import java.security.MessageDigest

object UserIdDeriver {
    fun derive(identityKeyPair: IdentityKeyPair): UserId {
        val fingerprint =
            MessageDigest.getInstance("SHA-256")
                .digest(identityKeyPair.publicKey.serialize())
        return UserId(UserId.PREFIX + Base32.encode(fingerprint))
    }
}
