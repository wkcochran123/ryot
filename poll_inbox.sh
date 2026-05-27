#!/usr/bin/env bash
# SPDX-License-Identifier: 0BSD
set -euo pipefail

AGENT="${1:?usage: poll_inbox.sh <agent_id> <inbox_file> <state_file> [interval]}"
INBOX="${2:?}"
STATE_FILE="${3:?}"
INTERVAL="${4:-3}"

read_last_turn() {
  awk -F= '
    $1 == "last_turn" {
      print $2
      found = 1
    }
    END {
      if (!found) {
        exit 1
      }
    }
  ' "$STATE_FILE"
}

while true; do
  if [[ ! -f "$INBOX" ]]; then
    echo "INBOX_MISSING inbox=$INBOX" >&2
    exit 2
  fi

  if [[ ! -f "$STATE_FILE" ]]; then
    echo "STATE_CORRUPT missing=$STATE_FILE" >&2
    exit 2
  fi

  LAST="$(read_last_turn || true)"
  if [[ ! "$LAST" =~ ^[0-9]+$ ]]; then
    echo "STATE_CORRUPT invalid_last_turn=$LAST file=$STATE_FILE" >&2
    exit 2
  fi

  OUTPUT="$(
    awk -v agent="$AGENT" -v last="$LAST" '
      function reset_header() {
        delete header
      }

      function parse_header_line(line, key, value) {
        sub(/^[ \t]+/, "", line)
        if (line ~ /^[A-Za-z_]+:[ \t]*/) {
          key = line
          sub(/:.*/, "", key)
          value = line
          sub(/^[^:]+:[ \t]*/, "", value)
          header[key] = value
        }
      }

      function emit_message(raw_turn, turn) {
        raw_turn = header["turn"]
        turn = -1
        if (raw_turn ~ /^[0-9]+$/) {
          turn = raw_turn + 0
        }

        if (header["to"] == agent && header["from"] != agent && turn > last) {
          print "=== NEW HANDOFF turn=" raw_turn " from=" header["from"] " status=" header["status"] " task=" header["task"] " ==="
          printf "%s", message
          print "=== END HANDOFF turn=" raw_turn " ==="
          if (turn > max_turn) {
            max_turn = turn
          }
        }
      }

      BEGIN {
        in_message = 0
        in_header = 0
        max_turn = last + 0
      }

      /<!-- HANDOFF/ {
        if (in_message) {
          emit_message()
        }
        in_message = 1
        in_header = 1
        message = $0 ORS
        reset_header()
        next
      }

      in_message {
        message = message $0 ORS
        if (in_header && /-->/) {
          in_header = 0
          next
        }
        if (in_header) {
          parse_header_line($0)
        }
        next
      }

      END {
        if (in_message) {
          emit_message()
        }
        print "__RYOT_MAX_TURN__" max_turn
      }
    ' "$INBOX"
  )"

  MAX_TURN="$(printf '%s\n' "$OUTPUT" | sed -n 's/^__RYOT_MAX_TURN__//p' | tail -n 1)"
  BODY="$(printf '%s\n' "$OUTPUT" | sed '/^__RYOT_MAX_TURN__/d')"

  if [[ -n "$BODY" ]]; then
    printf '%s\n' "$BODY"
    echo "last_turn=$MAX_TURN" > "$STATE_FILE"
  fi

  sleep "$INTERVAL"
done
