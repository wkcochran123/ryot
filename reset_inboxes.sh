#!/usr/bin/env bash
# SPDX-License-Identifier: 0BSD
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FORCE="${1:-}"

if [[ "$FORCE" != "--force" ]]; then
  if grep -q '<!-- HANDOFF' "$DIR/notes_for_codex.md" "$DIR/notes_for_claude.md" 2>/dev/null; then
    echo "Refusing to erase inboxes that contain HANDOFF blocks." >&2
    echo "Reread the relevant task checkpoint, make sure live handoffs are absorbed, then rerun with --force." >&2
    exit 2
  fi
fi

cat > "$DIR/notes_for_codex.md" <<'EOF'
<!-- RYOT inbox for Codex.

Claude appends handoffs here. Leave processed handoffs in place until a task
checkpoint has absorbed them and both sides agree compaction is safe.
-->
EOF

cat > "$DIR/notes_for_claude.md" <<'EOF'
<!-- RYOT inbox for Claude.

Codex appends handoffs here. Leave processed handoffs in place until a task
checkpoint has absorbed them and both sides agree compaction is safe.
-->
EOF

printf 'last_turn=0\n' > "$DIR/.handoff_codex_state"
printf 'last_turn=0\n' > "$DIR/.handoff_claude_state"

printf 'RYOT inboxes cleared and state files reset.\n'
