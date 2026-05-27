# RYOT Task Checkpoint: ryot-revision

Task id: `ryot-revision`

Workspace: `/Users/williamcochran/Desktop/ryot`

Artifact anchors:

- `ryot.md`
  - sha256: `22748cdf234db8bf2559889e7cd2668a43b1347e6e688aaa1298f4b25cdf2580`
  - git blob: `6598ceaf62d86460a8fc03d6f7af2f3c8b47442e`
- `README.md`
  - sha256: `05a83ad30b8a98146b28d512b2e35bc51ec2adfe77b18e8e98197defb4cc7486`
  - git blob: `e72546c19e5b903cc6caf8741c146fc75971cb52`
- `LICENSE`
  - sha256: `bf2b3497df5fc493c2010b9ff7b16f3e43c2cb2c6b2bc0eb4f53bb8c2391f474`
  - git blob: `214f378e0b2290602f06919a5124b6c29df12c60`
- `.gitignore`
  - sha256: `0fa2b0ecd27eaa45075df477d05dc02a751cf098375d75011bf94aadd8df5b86`
  - git blob: `8ea351c0c376e95a81047908088eb768a778181f`
- `poll_inbox.sh`
  - sha256: `bdffd87ea4f655aa23d73e4b0b38106450e27e4d669aff2ef91a946a90fefb25`
  - git blob: `cb928c833e8a2e12a43abcec365e14dba39a2dc9`
- `poll_codex.sh`
  - sha256: `9cc5be9de0a1123ad7d3007b5e09444a95d1301f739e0263bde4a97f5d61046d`
  - git blob: `fe55c6272ac5f60c95895bae59a8b4061f1ccd14`
- `poll_claude.sh`
  - sha256: `d9943ad31ed5706fda189d7edf3571e29090968f8f1c11c7b13565146b166f8b`
  - git blob: `cadfe71a6e8a0285233e27108b0d68d514ae3ffc`
- `reset_inboxes.sh`
  - sha256: `e295d35b502636f669057e555308b6d7f146fb40f637dcc3f9283506f01c1661`
  - git blob: `202c2f6ecdd55e7bc8c66ce28f7b2b3e297a2915`

Roles:

- Codex: writer/curator for repo setup and any eventual edits.
- Claude: reviewer/auditor for clarity, protocol consistency, and forkability.

Standing constraints:

- Docs/process files only.
- No direct edits to `ryot.md` by Claude on the first turn.
- No builds, network access, or destructive commands.
- Major semantic changes require operator approval.

Accepted decisions:

- Use one active inbox pair for this initial job.
- Start with Claude reviewing and Codex retaining edit ownership.
- Add an operator-requested wake-failure rule: if an LLM stops processing RYOT
  inboxes and the operator notices, the LLM must debug why watching stopped
  before continuing task work.
- Add README quickstart instructions for starting the first agent, asking it to
  start the RYOT process, starting the second agent, and asking it to join.
- Select the Zero-Clause BSD license (`0BSD`) for distribution, add `LICENSE`,
  document it in `README.md`, and add SPDX identifiers to shell scripts.
- Add `reset_inboxes.sh --force` to clear both inbox files and reset handoff
  state files to `last_turn=0` after live handoffs are absorbed.
- Add `.gitignore` for `.ryot/` runtime logs and PID files.
- Add a RYOT-first requests rule: once a RYOT process is active, operator
  requests affecting decisions or artifacts should iterate through RYOT before
  the job claims completion.

Open questions:

- Should `ryot.md` be renamed to `RYOT.md`?
- Are the quickstart, watcher behavior, and append-only inbox discipline fully
  consistent?
- Which bootstrap files should be part of the default forkable setup versus
  local runtime state?

Last turns:

- Codex to Claude: 4
- Claude to Codex: 1

Next action:

- Claude should review Codex Turn 4, especially the RYOT-first requests rule,
  0BSD license application, and inbox reset script safety. Codex still needs
  to answer Claude's broader Turn 1 questions or route operator-facing
  decisions before applying the larger patch list.
