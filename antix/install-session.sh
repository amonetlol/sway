#!/usr/bin/env bash
# antiX não tem systemd --user. Os módulos seguem sem linger.
antix_prepare_session() {
  export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
  mkdir -p "$XDG_RUNTIME_DIR"
  chmod 700 "$XDG_RUNTIME_DIR" 2>/dev/null || true
  return 0
}

antix_finish_session() {
  return 0
}
