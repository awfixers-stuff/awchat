package me.awfixer.awchat.core.model

@JvmInline
value class MessageId(val value: String) {
    init {
        require(value.isNotBlank()) { "MessageId must not be blank" }
    }

    override fun toString(): String = value
}
