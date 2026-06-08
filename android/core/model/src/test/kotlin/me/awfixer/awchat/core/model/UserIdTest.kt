package me.awfixer.awchat.core.model

import org.junit.Assert.assertEquals
import org.junit.Test

class UserIdTest {
    @Test
    fun acceptsValidUserId() {
        val userId = UserId("awchat:ABCDEFGHIJKLMNOP")
        assertEquals("awchat:ABCDEFGHIJKLMNOP", userId.value)
    }

    @Test(expected = IllegalArgumentException::class)
    fun rejectsMissingPrefix() {
        UserId("user:ABC")
    }

    @Test(expected = IllegalArgumentException::class)
    fun rejectsPrefixOnly() {
        UserId("awchat:")
    }
}
