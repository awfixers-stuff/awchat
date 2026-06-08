import gleeunit
import relay_core

pub fn main() -> Nil {
  gleeunit.main()
}

pub fn valid_user_id_test() {
  assert relay_core.valid_user_id("awchat:ABC123")
  assert !relay_core.valid_user_id("awchat:")
  assert !relay_core.valid_user_id("other:ABC")
}

pub fn group_size_test() {
  assert relay_core.valid_group_size(1)
  assert relay_core.valid_group_size(5)
  assert !relay_core.valid_group_size(6)
}

pub fn replay_window_test() {
  assert relay_core.within_replay_window(1_000, 1_000)
  assert relay_core.within_replay_window(1_000, 880)
  assert !relay_core.within_replay_window(1_000, 800)
}