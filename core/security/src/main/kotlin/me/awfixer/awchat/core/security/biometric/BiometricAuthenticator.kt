package me.awfixer.awchat.core.security.biometric

interface BiometricAuthenticator {
    suspend fun authenticate(): BiometricResult
}

sealed interface BiometricResult {
    data object Success : BiometricResult
    data class Error(val code: Int, val message: String) : BiometricResult
    data object Cancelled : BiometricResult
    data object NotAvailable : BiometricResult
}
