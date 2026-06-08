import gleam/string

pub const max_group_size = 5

pub const replay_window_seconds = 120

pub const auth_nonce_ttl_seconds = 120

pub const envelope_ttl_hours = 48

pub const stale_prekey_hours = 24

pub fn user_id_prefix() -> String {
  "awchat:"
}

pub fn valid_user_id(user_id: String) -> Bool {
  case user_id |> string.starts_with(user_id_prefix()) {
    True -> string.length(user_id) > string.length(user_id_prefix())
    False -> False
  }
}

pub fn valid_group_size(member_count: Int) -> Bool {
  member_count >= 1 && member_count <= max_group_size
}

pub fn within_replay_window(
  server_unix: Int,
  timestamp_unix: Int,
) -> Bool {
  let diff = case server_unix > timestamp_unix {
    True -> server_unix - timestamp_unix
    False -> timestamp_unix - server_unix
  }
  diff <= replay_window_seconds
}

pub type AuthError {
  InvalidUserId
  ReplayWindowExpired
  InvalidSignature
}

pub fn decode_result(ok: Bool, error: AuthError) -> Result(Nil, AuthError) {
  case ok {
    True -> Ok(Nil)
    False -> Error(error)
  }
}