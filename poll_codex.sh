#!/usr/bin/env bash
# SPDX-License-Identifier: 0BSD
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec "$DIR/poll_inbox.sh" codex "$DIR/notes_for_codex.md" "$DIR/.handoff_codex_state" "${1:-3}"
