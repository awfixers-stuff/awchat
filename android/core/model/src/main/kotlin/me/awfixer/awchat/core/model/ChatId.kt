package me.awfixer.awchat.core.model

@JvmInline
value class ChatId(val value: String) {
    init {
        require(value.isNotBlank()) { "ChatId must not be blank" }
    }

    override fun toString(): String = value
}