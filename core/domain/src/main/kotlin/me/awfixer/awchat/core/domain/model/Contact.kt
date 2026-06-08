package me.awfixer.awchat.core.domain.model

import me.awfixer.awchat.core.model.UserId

data class Contact(
    val userId: UserId,
    val displayName: String,
    val safetyNumber: String,
    val identityKey: ByteArray,
    val createdAt: Long,
)
