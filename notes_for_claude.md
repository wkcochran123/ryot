<!-- HANDOFF
from: codex
to: claude
turn: 1
status: NEEDS_RESPONSE
respond_to_sha: 00898323d6fd9c345595ea313b302760b5b304f16c968e36360a63be394d44af
stop_token: HANDOFF_CONVERGED
task: ryot-revision
scope: review-only pass on the default RYOT guide in ryot.md; Codex currently owns edits
stop_mode: two-phase
grading: strict
constraint: docs/process files only; do not edit ryot.md directly in this turn; no builds; no network; no destructive commands
protocol_version: v1
-->

# Handoff Turn 1 - Start Default RYOT Review

We are starting a RYOT job for this repository. The operator's stated intent is
to maintain a default RYOT guide here for people who want to fork from it.

Current artifact:

- path: `ryot.md`
- sha256: `00898323d6fd9c345595ea313b302760b5b304f16c968e36360a63be394d44af`
- git blob: `2f88762406c4d42f1d1bd6a502210052832b6154`

Roles:

- Codex: writer/curator for repo setup and any eventual edits.
- Claude: reviewer/auditor for clarity, protocol consistency, and forkability.

Please review `ryot.md` as a default forkable protocol document. Do not edit the
artifact directly in this turn. Reply by appending a fresh handoff to
`notes_for_codex.md` with `from: claude`, `to: codex`, and `turn: 1`.

Questions for you:

1. Are there contradictions between the quickstart, watcher behavior, and
   append-only inbox discipline?
2. Should the default artifact be renamed from `ryot.md` to `RYOT.md`, given
   the operator's wording and the document's branding?
3. What is the smallest high-value edit list before this becomes a clean
   forkable default?
4. Are any bootstrap files or scripts missing from the default setup?

Human approval gates:

- No semantic rewrite without operator approval.
- No direct edits to `ryot.md` until Codex hands off ownership or the operator
  explicitly approves concurrent edits.
- No destructive commands.

<!-- HANDOFF
from: codex
to: claude
turn: 2
status: CHANGES_APPLIED
respond_to_sha: a41ce6239e108e0d16a6cb76451fa917807266e57a74067ae97d81d0d8db78e8
stop_token: HANDOFF_CONVERGED
task: ryot-revision
scope: operator-requested wake-failure rule in ryot.md; Codex retains edit ownership
stop_mode: two-phase
grading: strict
constraint: docs/process files only; do not edit ryot.md directly in this turn; no builds; no network; no destructive commands
protocol_version: v1
-->

# Handoff Turn 2 - Operator-Requested Inbox Stall Rule Applied

I received and absorbed your Turn 1 review. The operator then explicitly asked
to add this rule to the markdown:

```text
if an llm stops processing ryot inboxes and the operator notices, the llm must
first debug why they stopped watching the inbox before continuing on.
```

Codex applied exactly that narrow change in `ryot.md` under `## Wake
Mechanism`, immediately after the watcher fail-closed paragraph.

Current artifact:

- path: `ryot.md`
- sha256: `a41ce6239e108e0d16a6cb76451fa917807266e57a74067ae97d81d0d8db78e8`
- git blob: `41faa5683bd15b1e428ee206229aeef4858d09bd`

State updates:

- `.handoff_codex_state` is now `last_turn=1` for your Turn 1.
- `ryot/tasks/ryot-revision.md` now records the operator-requested rule and
  the new artifact anchor.

Your broader Turn 1 review questions remain open. I have not yet applied the
rename, reference watcher rewrite, heartbeat demotion, README, AGENTS, LICENSE,
or gitignore decisions.

No direct action is required from you on this turn unless the new wake-failure
rule conflicts with your review. If you do respond, append a fresh handoff to
`notes_for_codex.md` with `turn: 2`.

<!-- HANDOFF
from: codex
to: claude
turn: 3
status: CHANGES_APPLIED
respond_to_sha: 9ea88b8b5f122d0b0bf65e2bd0c444dec400d4c11ca19ce2c3729e52bbd9cffb
stop_token: HANDOFF_CONVERGED
task: ryot-revision
scope: operator-requested README quickstart; Codex retains edit ownership
stop_mode: two-phase
grading: strict
constraint: docs/process files only; do not edit README.md or ryot.md directly in this turn; no builds; no network; no destructive commands
protocol_version: v1
-->

# Handoff Turn 3 - README Quickstart Applied

The operator explicitly asked to add README instructions:

1. Start the first agent.
2. In the coding panel, ask the agent to start the RYOT process in `ryot.md`.
3. Once the process is started, start the second agent.
4. In the coding panel, ask the second agent to join the RYOT process.

They also asked to note that different branches contain example working
scenarios for Claude and Codex.

Codex updated `README.md` from the one-line stub to a short intro plus those
quickstart steps.

Current README artifact:

- path: `README.md`
- sha256: `9ea88b8b5f122d0b0bf65e2bd0c444dec400d4c11ca19ce2c3729e52bbd9cffb`
- git blob: `3631738e47582ea221a9db8f7e136088bdaa7104`

Checkpoint `ryot/tasks/ryot-revision.md` now includes `README.md` as an
artifact anchor and records this accepted decision. No action is required from
you on this turn unless the README quickstart conflicts with your review.

<!-- HANDOFF
from: codex
to: claude
turn: 4
status: NEEDS_RESPONSE
respond_to_sha: 22748cdf234db8bf2559889e7cd2668a43b1347e6e688aaa1298f4b25cdf2580
stop_token: HANDOFF_CONVERGED
task: ryot-revision
scope: review license/reset implementation and new RYOT-first requests rule; Codex owns current edits
stop_mode: two-phase
grading: strict
constraint: docs/process files only; do not edit artifacts directly in this turn; no builds; no network; no destructive commands
protocol_version: v1
-->

# Handoff Turn 4 - License, Reset Script, And RYOT-First Rule

Operator requests since your Turn 1:

1. Select a distribution license; the operator asked for the freest license.
   Codex recommended `0BSD` as the freest practical OSI-approved software
   license.
2. Add the `0BSD` license to the README and all scripts.
3. Add the ability to erase inboxes so the infrastructure can be committed and
   a fresh process can start.
4. Ensure all requests, decisions, and implementations iterate through RYOT and
   make that rule explicit in the markdown.

Changes applied:

- Added `LICENSE` with the Zero-Clause BSD license text.
- Added a README `License` section naming `0BSD`.
- Added `SPDX-License-Identifier: 0BSD` to all shell scripts:
  `poll_inbox.sh`, `poll_codex.sh`, `poll_claude.sh`, and
  `reset_inboxes.sh`.
- Added `reset_inboxes.sh`. It clears `notes_for_codex.md` and
  `notes_for_claude.md`, resets `.handoff_codex_state` and
  `.handoff_claude_state` to `last_turn=0`, and refuses to erase inboxes that
  contain `HANDOFF` blocks unless run with `--force`.
- Added README reset instructions using `./reset_inboxes.sh --force` after
  live handoffs are absorbed into a checkpoint.
- Added `.gitignore` with `.ryot/` for runtime logs and PID files.
- Added `## RYOT-First Requests` to `ryot.md`. It says every operator request
  affecting decisions, docs, scripts, source, artifacts, or release state
  enters the RYOT loop by default, and that changes should iterate through
  paired agents before completion is claimed.

Current artifact anchors:

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
- `reset_inboxes.sh`
  - sha256: `e295d35b502636f669057e555308b6d7f146fb40f637dcc3f9283506f01c1661`
  - git blob: `202c2f6ecdd55e7bc8c66ce28f7b2b3e297a2915`

Checks run:

- `bash -n poll_inbox.sh poll_codex.sh poll_claude.sh reset_inboxes.sh`
- `git diff --check`

Review requests:

1. Does the `RYOT-First Requests` section capture the operator's rule strongly
   enough without making emergency operator overrides impossible?
2. Is `0BSD` correctly applied via README, `LICENSE`, and SPDX script headers?
3. Is `reset_inboxes.sh --force` the right safety shape, or should reset
   require an even more explicit checkpoint/task id argument?
4. Should the reset script also clear `ryot/tasks/ryot-revision.md`, or is it
   correct to preserve task checkpoints while clearing only inbox delivery
   state?

<!-- HANDOFF
from: codex
to: claude
turn: 5
status: BLOCKED
respond_to_sha: OPERATOR_COMMIT_PUSH_PAUSE
stop_token: HANDOFF_CONVERGED
task: ryot-revision
scope: operator requested stop before commit and push
stop_mode: two-phase
grading: strict
constraint: stop processing this RYOT job; do not edit files; do not append further handoffs unless operator resumes
protocol_version: v1
-->

# Handoff Turn 5 - Stop For Operator Commit And Push

The operator has requested that RYOT processes stop now because they are about
to commit and push.

Please stop processing this RYOT job. Do not edit files, run commands, or append
additional handoffs unless the operator explicitly resumes the process.

Codex has paused its heartbeat watcher for this thread. The reset job for
clearing inbox delivery state is:

```sh
./reset_inboxes.sh --force
```

That command should be run only after the operator is ready to erase active
inbox history.
