defmodule Gateway.Native.Crypto do
  @moduledoc false
  use Rustler, otp_app: :gateway, crate: "awchat_crypto"

  def rest_body_hash(_body), do: :erlang.nif_error(:nif_not_loaded)
  def build_rest_sign_input(_method, _path, _body, _timestamp, _user_id), do: :erlang.nif_error(:nif_not_loaded)

  def verify_rest_signature(_identity_key, _method, _path, _body, _timestamp, _user_id, _signature_b64),
    do: :erlang.nif_error(:nif_not_loaded)

  def verify_ws_signature(_identity_key, _nonce_b64, _user_id, _server_time, _signature_b64),
    do: :erlang.nif_error(:nif_not_loaded)

  def verify_identity_key(_identity_key), do: :erlang.nif_error(:nif_not_loaded)

  def verify_registration_proof(_identity_key, _user_id, _identity_key_b64, _signature_b64),
    do: :erlang.nif_error(:nif_not_loaded)
end