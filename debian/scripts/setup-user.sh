#!/usr/bin/env bash
# Compatibility entry point; personal configs now track upstream.
set -euo pipefail
exec bash "$(dirname -- "${BASH_SOURCE[0]}")/../install-personal_configs.sh" "$@"
