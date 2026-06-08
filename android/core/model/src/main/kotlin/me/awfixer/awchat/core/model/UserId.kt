package me.awfixer.awchat.core.model

@JvmInline
value class UserId(val value: String) {
    init {
        require(value.startsWith(PREFIX)) { "UserId must start with $PREFIX" }
        require(value.length > PREFIX.length) { "UserId must include a fingerprint after $PREFIX" }
    }

    override fun toString(): String = value

    companion object {
        const val PREFIX = "awchat:"
    }
}
