package me.awfixer.awchat.core.crypto.identity

import org.signal.libsignal.protocol.IdentityKeyPair
import org.signal.libsignal.protocol.util.KeyHelper

object IdentityGenerator {
    fun generate(): IdentityMaterial {
        val identityKeyPair = IdentityKeyPair.generate()
        val registrationId = KeyHelper.generateRegistrationId(false)
        val userId = UserIdDeriver.derive(identityKeyPair)
        return IdentityMaterial(
            identityKeyPair = identityKeyPair,
            registrationId = registrationId,
            userId = userId,
        )
    }
}
