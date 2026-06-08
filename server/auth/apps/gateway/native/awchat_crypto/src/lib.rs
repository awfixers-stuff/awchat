use base64::{engine::general_purpose::STANDARD, Engine as _};
use libsignal_core::curve::PublicKey;
use rustler::Binary;
use sha2::{Digest, Sha256};

fn hash_body(body: &[u8]) -> String {
    let digest = Sha256::digest(body);
    STANDARD.encode(digest)
}

fn rest_sign_input(
    method: &str,
    path: &str,
    body: &[u8],
    timestamp: &str,
    user_id: &str,
) -> String {
    let body_hash = hash_body(body);
    format!("{method}|{path}|{body_hash}|{timestamp}|{user_id}")
}

#[rustler::nif]
fn rest_body_hash(body: Binary<'_>) -> String {
    hash_body(body.as_slice())
}

#[rustler::nif]
fn build_rest_sign_input(
    method: &str,
    path: &str,
    body: Binary<'_>,
    timestamp: &str,
    user_id: &str,
) -> String {
    rest_sign_input(method, path, body.as_slice(), timestamp, user_id)
}

#[rustler::nif]
fn verify_rest_signature(
    identity_key: Binary<'_>,
    method: &str,
    path: &str,
    body: Binary<'_>,
    timestamp: &str,
    user_id: &str,
    signature_b64: &str,
) -> bool {
    let Ok(signature) = STANDARD.decode(signature_b64) else {
        return false;
    };

    let Ok(public_key) = PublicKey::deserialize(identity_key.as_slice()) else {
        return false;
    };

    let sign_input = rest_sign_input(method, path, body.as_slice(), timestamp, user_id);
    public_key.verify_signature(sign_input.as_bytes(), &signature)
}

#[rustler::nif]
fn verify_ws_signature(
    identity_key: Binary<'_>,
    nonce_b64: &str,
    user_id: &str,
    server_time: &str,
    signature_b64: &str,
) -> bool {
    let Ok(nonce) = STANDARD.decode(nonce_b64) else {
        return false;
    };

    if nonce.len() != 32 {
        return false;
    }

    let Ok(signature) = STANDARD.decode(signature_b64) else {
        return false;
    };

    let Ok(public_key) = PublicKey::deserialize(identity_key.as_slice()) else {
        return false;
    };

    public_key.verify_signature_for_multipart_message(
        &[&nonce, b"|", user_id.as_bytes(), b"|", server_time.as_bytes()],
        &signature,
    )
}

#[rustler::nif]
fn verify_identity_key(identity_key: Binary<'_>) -> bool {
    PublicKey::deserialize(identity_key.as_slice()).is_ok()
}

#[rustler::nif]
fn verify_registration_proof(
    identity_key: Binary<'_>,
    user_id: &str,
    identity_key_b64: &str,
    signature_b64: &str,
) -> bool {
    let Ok(decoded_key) = STANDARD.decode(identity_key_b64) else {
        return false;
    };

    if identity_key.as_slice() != decoded_key.as_slice() {
        return false;
    };

    let Ok(signature) = STANDARD.decode(signature_b64) else {
        return false;
    };

    let Ok(public_key) = PublicKey::deserialize(identity_key.as_slice()) else {
        return false;
    };

    let sign_input = format!("register|{user_id}|{identity_key_b64}");
    public_key.verify_signature(sign_input.as_bytes(), &signature)
}

rustler::init!("Elixir.Gateway.Native.Crypto");