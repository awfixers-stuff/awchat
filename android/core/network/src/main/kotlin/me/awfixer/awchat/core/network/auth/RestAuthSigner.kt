package me.awfixer.awchat.core.network.auth

import android.util.Base64
import me.awfixer.awchat.core.model.UserId
import org.signal.libsignal.protocol.ecc.ECPrivateKey
import java.security.MessageDigest

object RestAuthSigner {

    @Suppress("LongParameterList")
    fun signRequest(
        identityPrivateKey: ECPrivateKey,
        method: String,
        path: String,
        body: ByteArray,
        userId: UserId,
        timestamp: String,
    ): String {
        val bodyHash = Base64.encodeToString(
            MessageDigest.getInstance("SHA-256").digest(body),
            Base64.NO_WRAP,
        )
        val signInput = "$method|$path|$bodyHash|$timestamp|$userId"
        val signature = identityPrivateKey.calculateSignature(signInput.toByteArray())
        return Base64.encodeToString(signature, Base64.NO_WRAP)
    }
}
