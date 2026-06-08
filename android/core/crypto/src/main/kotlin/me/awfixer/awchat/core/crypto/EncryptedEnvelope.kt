package me.awfixer.awchat.core.crypto

data class EncryptedEnvelope(
    val ciphertext: ByteArray,
    val messageType: Int,
) {
    override fun equals(other: Any?): Boolean {
        if (this === other) return true
        if (other !is EncryptedEnvelope) return false
        return messageType == other.messageType && ciphertext.contentEquals(other.ciphertext)
    }

    override fun hashCode(): Int {
        var result = messageType
        result = 31 * result + ciphertext.contentHashCode()
        return result
    }
}