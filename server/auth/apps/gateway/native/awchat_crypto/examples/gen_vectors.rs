use base64::{engine::general_purpose::STANDARD, Engine as _};
use libsignal_core::curve::KeyPair;
use rand::thread_rng;
use sha2::{Digest, Sha256};

fn crockford_base32(data: &[u8]) -> String {
    const ALPHABET: &[u8] = b"ABCDEFGHIJKLMNOPQRSTUVWXYZ234567";
    let mut output = String::new();
    let mut buffer = 0u32;
    let mut bits_left = 0;

    for &byte in data {
        buffer = (buffer << 8) | u32::from(byte);
        bits_left += 8;
        while bits_left >= 5 {
            let index = ((buffer >> (bits_left - 5)) & 0x1F) as usize;
            bits_left -= 5;
            output.push(ALPHABET[index] as char);
        }
    }

    if bits_left > 0 {
        let index = ((buffer << (5 - bits_left)) & 0x1F) as usize;
        output.push(ALPHABET[index] as char);
    }

    output
}

fn main() {
    let mut csprng = thread_rng();
    let key_pair = KeyPair::generate(&mut csprng);
    let pub_bytes = key_pair.public_key.serialize();
    let identity_b64 = STANDARD.encode(&pub_bytes);
    let digest = Sha256::digest(&pub_bytes);
    let user_id = format!("awchat:{}", crockford_base32(&digest));
    let reg_input = format!("register|{user_id}|{identity_b64}");
    let reg_sig = key_pair
        .private_key
        .calculate_signature(reg_input.as_bytes(), &mut csprng)
        .expect("sig");
    let reg_sig_b64 = STANDARD.encode(reg_sig.as_ref());
    println!("USER_ID={user_id}");
    println!("IDENTITY_KEY_B64={identity_b64}");
    println!("REG_SIG_B64={reg_sig_b64}");
}