package me.awfixer.awchat.core.common.result

import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Test

class ResultTest {
    @Test
    fun successReturnsValue() {
        val result = Result.Success(42)
        assertEquals(42, result.getOrNull())
        assertEquals(42, result.getOrThrow())
    }

    @Test
    fun failureReturnsNullAndThrows() {
        val error = IllegalStateException("boom")
        val result = Result.Failure(error)
        assertNull(result.getOrNull())
        try {
            result.getOrThrow()
            error("Expected exception")
        } catch (caught: IllegalStateException) {
            assertEquals("boom", caught.message)
        }
    }
}
