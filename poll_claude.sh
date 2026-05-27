#!/usr/bin/env bash
# SPDX-License-Identifier: 0BSD
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec "$DIR/poll_inbox.sh" claude "$DIR/notes_for_claude.md" "$DIR/.handoff_claude_state" "${1:-3}"
