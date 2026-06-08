package me.awfixer.awchat.core.security.keystore

import android.content.Context
import android.os.Build
import android.security.keystore.KeyGenParameterSpec
import android.security.keystore.KeyProperties
import android.security.keystore.StrongBoxUnavailableException
import dagger.hilt.android.qualifiers.ApplicationContext
import me.awfixer.awchat.core.common.security.MasterKeyProvider
import java.io.File
import java.nio.ByteBuffer
import java.security.KeyStore
import java.security.SecureRandom
import javax.crypto.Cipher
import javax.crypto.KeyGenerator
import javax.crypto.SecretKey
import javax.crypto.spec.GCMParameterSpec
import javax.inject.Inject

class KeystoreMasterKeyProvider @Inject constructor(
    @ApplicationContext context: Context,
    private val keyAlias: String = MASTER_KEY_ALIAS,
) : MasterKeyProvider {

    private val keyStore: KeyStore = KeyStore.getInstance(ANDROID_KEYSTORE).apply { load(null) }
    private val masterKeyFile: File = File(context.filesDir, MASTER_KEY_FILE_NAME)

    override fun getOrCreateMasterKey(): ByteArray {
        if (masterKeyFile.exists()) {
            return unwrapMasterKey(masterKeyFile.readBytes())
        }

        val masterKey = ByteArray(MASTER_KEY_SIZE).also { SecureRandom().nextBytes(it) }
        val wrapped = wrapMasterKey(masterKey)
        masterKeyFile.parentFile?.mkdirs()
        masterKeyFile.writeBytes(wrapped)
        return masterKey.copyOf()
    }

    private fun wrapMasterKey(masterKey: ByteArray): ByteArray {
        val keystoreKey = getOrCreateKeystoreKey()
        val cipher = Cipher.getInstance(TRANSFORMATION)
        cipher.init(Cipher.ENCRYPT_MODE, keystoreKey)
        val iv = cipher.iv
        val ciphertext = cipher.doFinal(masterKey)
        return ByteBuffer.allocate(Int.SIZE_BYTES + iv.size + ciphertext.size)
            .putInt(iv.size)
            .put(iv)
            .put(ciphertext)
            .array()
    }

    private fun unwrapMasterKey(wrapped: ByteArray): ByteArray {
        return try {
            val buffer = ByteBuffer.wrap(wrapped)
            val ivSize = buffer.int
            require(ivSize == GCM_IV_SIZE) { "Unexpected IV size: $ivSize" }
            val iv = ByteArray(ivSize).also { buffer.get(it) }
            val ciphertext = ByteArray(buffer.remaining()).also { buffer.get(it) }
            val keystoreKey = getOrCreateKeystoreKey()
            val cipher = Cipher.getInstance(TRANSFORMATION)
            cipher.init(Cipher.DECRYPT_MODE, keystoreKey, GCMParameterSpec(GCM_TAG_BITS, iv))
            cipher.doFinal(ciphertext)
        } catch (e: Exception) {
            throw KeystoreException(
                "Failed to unwrap master key. " +
                    "This can happen after device reset or if the keystore key was invalidated.",
                e,
            )
        }
    }

    private fun getOrCreateKeystoreKey(): SecretKey {
        val existing = keyStore.getEntry(keyAlias, null) as? KeyStore.SecretKeyEntry
        if (existing != null) {
            return existing.secretKey
        }

        return try {
            generateKeystoreKey(useStrongBox = true)
        } catch (e: StrongBoxUnavailableException) {
            generateKeystoreKey(useStrongBox = false)
        } catch (e: Exception) {
            if (e.message?.contains("strongbox", ignoreCase = true) == true) {
                generateKeystoreKey(useStrongBox = false)
            } else {
                throw KeystoreException("Failed to generate keystore key", e)
            }
        }
    }

    private fun generateKeystoreKey(useStrongBox: Boolean): SecretKey {
        val builder = KeyGenParameterSpec.Builder(
            keyAlias,
            KeyProperties.PURPOSE_ENCRYPT or KeyProperties.PURPOSE_DECRYPT,
        )
            .setBlockModes(KeyProperties.BLOCK_MODE_GCM)
            .setEncryptionPaddings(KeyProperties.ENCRYPTION_PADDING_NONE)
            .setKeySize(KEY_SIZE_BITS)
            .setRandomizedEncryptionRequired(true)

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P && useStrongBox) {
            builder.setIsStrongBoxBacked(true)
        }

        val keyGenerator = KeyGenerator.getInstance(
            KeyProperties.KEY_ALGORITHM_AES,
            ANDROID_KEYSTORE,
        )
        keyGenerator.init(builder.build())
        return keyGenerator.generateKey()
    }

    companion object {
        private const val ANDROID_KEYSTORE = "AndroidKeyStore"
        private const val MASTER_KEY_ALIAS = "awchat_master_key"
        private const val MASTER_KEY_FILE_NAME = "awchat_master_key.enc"
        private const val MASTER_KEY_SIZE = 32
        private const val KEY_SIZE_BITS = 256
        private const val TRANSFORMATION = "AES/GCM/NoPadding"
        private const val GCM_IV_SIZE = 12
        private const val GCM_TAG_BITS = 128
    }
}
