package me.awfixer.awchat.core.crypto.identity

import me.awfixer.awchat.core.model.UserId
import org.signal.libsignal.protocol.IdentityKeyPair

data class IdentityMaterial(
    val identityKeyPair: IdentityKeyPair,
    val registrationId: Int,
    val userId: UserId,
)