package me.awfixer.awchat.core.crypto.internal

import me.awfixer.awchat.core.crypto.identity.IdentityMaterial
import org.signal.libsignal.protocol.state.impl.InMemorySignalProtocolStore

internal object ProtocolStoreFactory {
    fun create(material: IdentityMaterial): InMemorySignalProtocolStore =
        InMemorySignalProtocolStore(material.identityKeyPair, material.registrationId)
}