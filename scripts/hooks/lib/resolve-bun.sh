# POSIX shell helper: resolve an executable bun binary for hook subprocesses.
# Hook runners (Grok, Cursor, lefthook) often inherit a minimal PATH without
# login-shell init, so `command -v bun` fails even when ~/.bun/bin/bun exists.
#
# Usage (source from another script):
#   . "$root/scripts/hooks/lib/resolve-bun.sh"
#   awchat_resolve_bun || exit 1
#   "$AWCHAT_BUN" path/to/script.ts

awchat_resolve_bun() {
  if [ -n "${AWCHAT_BUN:-}" ] && [ -x "$AWCHAT_BUN" ]; then
    return 0
  fi

  if [ -n "${BUN_INSTALL:-}" ] && [ -x "$BUN_INSTALL/bin/bun" ]; then
    AWCHAT_BUN="$BUN_INSTALL/bin/bun"
    export AWCHAT_BUN
    return 0
  fi

  home="${HOME:-}"
  if [ -z "$home" ]; then
    home=$(cd ~ && pwd 2>/dev/null) || true
  fi

  for candidate in \
    "$home/.bun/bin/bun" \
    "$home/.local/bin/bun" \
    "$home/.nix-profile/bin/bun" \
    /usr/local/bin/bun \
    /nix/var/nix/profiles/default/bin/bun
  do
    if [ -n "$candidate" ] && [ -x "$candidate" ]; then
      AWCHAT_BUN="$candidate"
      export AWCHAT_BUN
      return 0
    fi
  done

  if [ -n "${AWCHAT_REPO_ROOT:-}" ] && [ -x "$AWCHAT_REPO_ROOT/.direnv/bin/bun" ]; then
    AWCHAT_BUN="$AWCHAT_REPO_ROOT/.direnv/bin/bun"
    export AWCHAT_BUN
    return 0
  fi

  if command -v bun >/dev/null 2>&1; then
    AWCHAT_BUN=$(command -v bun)
    export AWCHAT_BUN
    return 0
  fi

  return 1
}