package me.awfixer.awchat.core.proto

import awchat.v1.ChatPayload
import awchat.v1.InnerMessage
import awchat.v1.InnerMessageType
import awchat.v1.ReadReceiptPayload
import org.junit.Assert.assertArrayEquals
import org.junit.Assert.assertEquals
import org.junit.Test

class InnerMessageProtoTest {
    @Test
    fun chatPayloadRoundTrip() {
        val original =
            InnerMessage.newBuilder()
                .setType(InnerMessageType.CHAT)
                .setChat(
                    ChatPayload.newBuilder()
                        .setBody("hello")
                        .setClientTimestamp(1_700_000_000_000L)
                        .build(),
                )
                .build()

        val parsed = InnerMessage.parseFrom(original.toByteArray())

        assertEquals(InnerMessageType.CHAT, parsed.type)
        assertEquals("hello", parsed.chat.body)
        assertEquals(1_700_000_000_000L, parsed.chat.clientTimestamp)
    }

    @Test
    fun readReceiptPayloadRoundTrip() {
        val original =
            InnerMessage.newBuilder()
                .setType(InnerMessageType.READ_RECEIPT)
                .setReadReceipt(
                    ReadReceiptPayload.newBuilder()
                        .setMessageId("msg-1")
                        .setReaderId("awchat:READER")
                        .setSeenAt(1_700_000_000_123L)
                        .build(),
                )
                .build()

        val parsed = InnerMessage.parseFrom(original.toByteArray())

        assertEquals(InnerMessageType.READ_RECEIPT, parsed.type)
        assertEquals("msg-1", parsed.readReceipt.messageId)
        assertEquals("awchat:READER", parsed.readReceipt.readerId)
        assertEquals(1_700_000_000_123L, parsed.readReceipt.seenAt)
    }

    @Test
    fun senderKeyDistPayloadRoundTrip() {
        val bytes = byteArrayOf(1, 2, 3, 4)
        val original =
            InnerMessage.newBuilder()
                .setType(InnerMessageType.SENDER_KEY_DIST)
                .setSenderKeyDist(
                    awchat.v1.SenderKeyDistPayload.newBuilder()
                        .setGroupId("group-1")
                        .setDistributionBytes(com.google.protobuf.ByteString.copyFrom(bytes))
                        .build(),
                )
                .build()

        val parsed = InnerMessage.parseFrom(original.toByteArray())

        assertEquals(InnerMessageType.SENDER_KEY_DIST, parsed.type)
        assertEquals("group-1", parsed.senderKeyDist.groupId)
        assertArrayEquals(bytes, parsed.senderKeyDist.distributionBytes.toByteArray())
    }

    @Test
    fun purgeAckPayloadRoundTrip() {
        val original =
            InnerMessage.newBuilder()
                .setType(InnerMessageType.PURGE_ACK)
                .setPurgeAck(
                    awchat.v1.PurgeAckPayload.newBuilder()
                        .setMessageId("msg-purge")
                        .build(),
                )
                .build()

        val parsed = InnerMessage.parseFrom(original.toByteArray())

        assertEquals(InnerMessageType.PURGE_ACK, parsed.type)
        assertEquals("msg-purge", parsed.purgeAck.messageId)
    }
}
