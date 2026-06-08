package me.awfixer.awchat.core.security.passphrase

import android.content.Context
import dagger.hilt.android.qualifiers.ApplicationContext
import me.awfixer.awchat.core.common.security.MasterKeyProvider
import me.awfixer.awchat.core.security.keystore.KeystoreException
import java.io.File
import java.nio.ByteBuffer
import java.security.SecureRandom
import javax.crypto.Cipher
import javax.crypto.spec.GCMParameterSpec
import javax.crypto.spec.SecretKeySpec
import javax.inject.Inject

class KeystorePassphraseProvider @Inject constructor(
    @ApplicationContext context: Context,
    private val masterKeyProvider: MasterKeyProvider,
) : PassphraseProvider {

    private val passphraseFile: File = File(context.filesDir, PASSPHRASE_FILE_NAME)

    override fun getOrCreateDatabasePassphrase(): ByteArray {
        if (passphraseFile.exists()) {
            return unsealPassphrase(passphraseFile.readBytes())
        }

        val passphrase = ByteArray(PASSPHRASE_SIZE).also { SecureRandom().nextBytes(it) }
        val sealed = sealPassphrase(passphrase)
        passphraseFile.parentFile?.mkdirs()
        passphraseFile.writeBytes(sealed)
        return passphrase.copyOf()
    }

    private fun sealPassphrase(passphrase: ByteArray): ByteArray {
        val masterKey = masterKeyProvider.getOrCreateMasterKey()
        val nonce = ByteArray(GCM_IV_SIZE).also { SecureRandom().nextBytes(it) }
        val cipher = Cipher.getInstance(TRANSFORMATION).apply {
            init(
                Cipher.ENCRYPT_MODE,
                SecretKeySpec(masterKey, ALGORITHM),
                GCMParameterSpec(GCM_TAG_BITS, nonce),
            )
        }
        val ciphertext = cipher.doFinal(passphrase)
        return ByteBuffer.allocate(nonce.size + ciphertext.size)
            .put(nonce)
            .put(ciphertext)
            .array()
    }

    private fun unsealPassphrase(sealed: ByteArray): ByteArray {
        return try {
            require(sealed.size > GCM_IV_SIZE) { "Sealed passphrase too short" }
            val masterKey = masterKeyProvider.getOrCreateMasterKey()
            val nonce = sealed.copyOfRange(0, GCM_IV_SIZE)
            val ciphertext = sealed.copyOfRange(GCM_IV_SIZE, sealed.size)
            val cipher = Cipher.getInstance(TRANSFORMATION).apply {
                init(
                    Cipher.DECRYPT_MODE,
                    SecretKeySpec(masterKey, ALGORITHM),
                    GCMParameterSpec(GCM_TAG_BITS, nonce),
                )
            }
            cipher.doFinal(ciphertext)
        } catch (e: Exception) {
            throw KeystoreException(
                "Failed to unseal database passphrase. " +
                    "The master key or passphrase file may be corrupted.",
                e,
            )
        }
    }

    companion object {
        private const val PASSPHRASE_FILE_NAME = "awchat_db_passphrase.enc"
        private const val PASSPHRASE_SIZE = 32
        private const val TRANSFORMATION = "AES/GCM/NoPadding"
        private const val ALGORITHM = "AES"
        private const val GCM_IV_SIZE = 12
        private const val GCM_TAG_BITS = 128
    }
}
