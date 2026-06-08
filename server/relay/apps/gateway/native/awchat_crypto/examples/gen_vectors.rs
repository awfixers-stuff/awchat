use base64::{engine::general_purpose::STANDARD, Engine as _};
use libsignal_core::curve::KeyPair;
use rand::rngs::OsRng;
use sha2::{Digest, Sha256};

fn main() {
    let mut csprng = OsRng;
    let key_pair = KeyPair::generate(&mut csprng);
    let pub_bytes = key_pair.public_key.serialize();
    let identity_b64 = STANDARD.encode(&pub_bytes);
    let digest = Sha256::digest(&pub_bytes);
    let user_id = format!("awchat:{}", hex::encode(&digest[..8]));
    let reg_input = format!("register|{user_id}|{identity_b64}");
    let reg_sig = key_pair.private_key.calculate_signature(reg_input.as_bytes(), &mut csprng).expect("sig");
    let reg_sig_b64 = STANDARD.encode(reg_sig.as_ref());
    let method = "POST";
    let path = "/v1/invites";
    let body = "";
    let timestamp = "2026-06-07T12:00:00Z";
    let body_hash = STANDARD.encode(Sha256::digest(body.as_bytes()));
    let rest_input = format!("{method}|{path}|{body_hash}|{timestamp}|{user_id}");
    let rest_sig = key_pair.private_key.calculate_signature(rest_input.as_bytes(), &mut csprng).expect("sig");
    let rest_sig_b64 = STANDARD.encode(rest_sig.as_ref());
    println!("USER_ID={user_id}");
    println!("IDENTITY_KEY_B64={identity_b64}");
    println!("REG_SIG_B64={reg_sig_b64}");
    println!("REST_SIG_B64={rest_sig_b64}");
}
