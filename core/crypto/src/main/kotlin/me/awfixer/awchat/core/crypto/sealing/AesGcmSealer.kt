package me.awfixer.awchat.core.crypto.sealing

import me.awfixer.awchat.core.common.security.MasterKeyProvider

import java.nio.ByteBuffer
import java.security.SecureRandom
import javax.crypto.Cipher
import javax.crypto.spec.GCMParameterSpec
import javax.crypto.spec.SecretKeySpec

class AesGcmSealer(
    private val masterKeyProvider: MasterKeyProvider,
) {
    fun seal(plaintext: ByteArray): ByteArray {
        val nonce = ByteArray(NONCE_BYTES).also { SecureRandom().nextBytes(it) }
        val cipher =
            Cipher.getInstance(TRANSFORMATION).apply {
                init(
                    Cipher.ENCRYPT_MODE,
                    SecretKeySpec(masterKeyProvider.getOrCreateMasterKey(), "AES"),
                    GCMParameterSpec(TAG_BITS, nonce),
                )
            }
        val ciphertext = cipher.doFinal(plaintext)
        return ByteBuffer.allocate(nonce.size + ciphertext.size)
            .put(nonce)
            .put(ciphertext)
            .array()
    }

    fun unseal(sealed: ByteArray): ByteArray {
        require(sealed.size > NONCE_BYTES) { "Sealed blob too short" }
        val nonce = sealed.copyOfRange(0, NONCE_BYTES)
        val ciphertext = sealed.copyOfRange(NONCE_BYTES, sealed.size)
        val cipher =
            Cipher.getInstance(TRANSFORMATION).apply {
                init(
                    Cipher.DECRYPT_MODE,
                    SecretKeySpec(masterKeyProvider.getOrCreateMasterKey(), "AES"),
                    GCMParameterSpec(TAG_BITS, nonce),
                )
            }
        return cipher.doFinal(ciphertext)
    }

    companion object {
        private const val TRANSFORMATION = "AES/GCM/NoPadding"
        private const val NONCE_BYTES = 12
        private const val TAG_BITS = 128
    }
}