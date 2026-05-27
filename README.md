# RYOT

RYOT means **Roll Your Own Talent**: a small handoff protocol for running two
coding agents with explicit inboxes, review turns, and operator approval.

The default protocol lives in [`ryot.md`](ryot.md).

## Quickstart

1. Start the first agent.
2. In the coding panel, ask the first agent to start the RYOT process described
   in `ryot.md`.
3. Once the process is started, start the second agent.
4. In the coding panel, ask the second agent to join the RYOT process.

Different branches contain example working scenarios for Claude and Codex.

## Keeping Agents Polling

Some coding agents need a little poking and prodding before they reliably keep
polling their RYOT inboxes. If an agent stops noticing new handoffs, keep asking
it to debug and fix the bug where it is not polling its inbox. The protocol
expects the agent to inspect its watcher state, inbox file, state file, and last
processed turn before continuing.

## Reset Inboxes

To commit the RYOT infrastructure without carrying an active handoff history
forward, run this after all live handoffs have been absorbed into a checkpoint:

```sh
./reset_inboxes.sh --force
```

This clears `notes_for_codex.md` and `notes_for_claude.md`, then resets
`.handoff_codex_state` and `.handoff_claude_state` to `last_turn=0`.

## License

RYOT is distributed under the Zero-Clause BSD license (`0BSD`). See
[`LICENSE`](LICENSE).
