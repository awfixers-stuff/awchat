@external(erlang, "Elixir.Gateway.Native.Crypto", "build_rest_sign_input")
pub fn build_rest_sign_input(
  method: String,
  path: String,
  body: BitArray,
  timestamp: String,
  user_id: String,
) -> String

@external(erlang, "Elixir.Gateway.Native.Crypto", "verify_rest_signature")
pub fn verify_rest_signature(
  identity_key: BitArray,
  method: String,
  path: String,
  body: BitArray,
  timestamp: String,
  user_id: String,
  signature_b64: String,
) -> Bool

@external(erlang, "Elixir.Gateway.Native.Crypto", "verify_ws_signature")
pub fn verify_ws_signature(
  identity_key: BitArray,
  nonce_b64: String,
  user_id: String,
  server_time: String,
  signature_b64: String,
) -> Bool

@external(erlang, "Elixir.Gateway.Native.Crypto", "verify_identity_key")
pub fn verify_identity_key(identity_key: BitArray) -> Bool