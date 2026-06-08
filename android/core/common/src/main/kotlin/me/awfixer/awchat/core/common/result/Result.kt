package me.awfixer.awchat.core.common.result

sealed interface Result<out T> {
    data class Success<T>(val value: T) : Result<T>

    data class Failure(val error: Throwable) : Result<Nothing>
}

fun <T> Result<T>.getOrNull(): T? =
    when (this) {
        is Result.Success -> value
        is Result.Failure -> null
    }

fun <T> Result<T>.getOrThrow(): T =
    when (this) {
        is Result.Success -> value
        is Result.Failure -> throw error
    }
