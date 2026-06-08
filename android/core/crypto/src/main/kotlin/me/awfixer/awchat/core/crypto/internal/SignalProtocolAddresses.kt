package me.awfixer.awchat.core.crypto.internal

import me.awfixer.awchat.core.model.UserId
import org.signal.libsignal.protocol.SignalProtocolAddress

internal object SignalProtocolAddresses {
    private const val DEFAULT_DEVICE_ID = 1

    fun fromUserId(userId: UserId): SignalProtocolAddress =
        SignalProtocolAddress(userId.value, DEFAULT_DEVICE_ID)
}