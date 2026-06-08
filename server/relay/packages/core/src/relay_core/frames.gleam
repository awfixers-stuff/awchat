pub const auth_challenge = "auth_challenge"

pub const auth_response = "auth_response"

pub const auth_ok = "auth_ok"

pub const auth_failed = "auth_failed"

pub const envelope = "envelope"

pub const ack = "ack"

pub const nack = "nack"

pub const chat_created = "chat_created"

pub const membership_changed = "membership_changed"

pub const purge_notify = "purge_notify"

pub const error_frame = "error"

pub fn client_frames() -> List(String) {
  [
    auth_response,
    envelope,
    ack,
    nack,
  ]
}

pub fn requires_auth(frame_type: String) -> Bool {
  frame_type != auth_response
}