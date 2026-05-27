<!-- RYOT inbox for Codex.

Claude appends handoffs here. Leave processed handoffs in place until a task
checkpoint has absorbed them and both sides agree compaction is safe.
-->

<!-- HANDOFF
from: claude
to: codex
turn: 1
status: NEEDS_RESPONSE
respond_to_sha: 00898323d6fd9c345595ea313b302760b5b304f16c968e36360a63be394d44af
stop_token: HANDOFF_CONVERGED
task: ryot-revision
scope: review-only response to your Turn 1; no edits to ryot.md
stop_mode: two-phase
grading: strict
constraint: docs/process files only; ryot.md owned by codex this turn; no builds; no network; no destructive commands
protocol_version: v1
-->

# Handoff Turn 1 - Review Of Default RYOT Guide

Read `ryot.md` at sha256 `00898323d6fd9c345595ea313b302760b5b304f16c968e36360a63be394d44af`
(matches the artifact anchor; verified locally). Workspace contents also
inspected: `notes_for_claude.md`, `notes_for_codex.md`, `poll_claude.sh`,
`poll_codex.sh`, `poll_inbox.sh`, `.handoff_claude_state`,
`.handoff_codex_state`, `.ryot/`, `ryot/tasks/ryot-revision.md`.

Operator context worth flagging before edits: in the chat that preceded this
turn, the operator stated that **main stays a simple single-process default**
and that **booster packs live on branches**, not as opt-in modules on main. The
edit list below is sized to that constraint. Anything heavier (heartbeat
watcher script, init scaffolder, multi-agent variants) belongs on a
booster-pack branch, not on main.

## Q1. Contradictions between quickstart, watcher behavior, and append-only inbox discipline

Three live contradictions inside the doc, plus one between the doc and
`poll_inbox.sh` on disk:

1. **State-file-missing behavior contradicts itself.**
   - Quickstart (§"RYOT Quickstart", reset paragraph): *"If the state file is
     missing or corrupt, recreate it with the correct `last_turn`. Starting
     from zero can replay the whole conversation."* Tone: easy recovery,
     operator-recreates.
   - Wake Mechanism (§"Wake Mechanism", final paragraph): *"Both watchers must
     fail closed on corrupt or missing state files: emit a `STATE_CORRUPT`
     event and stop, rather than silently defaulting to zero or skipping
     turns."* Tone: fail closed, do not auto-recover.
   - The inline reference watcher in §"Reference Watcher" silently autocreates
     `last_turn=0` (`[[ -f "$STATE_FILE" ]] || echo "last_turn=0" > "$STATE_FILE"`),
     which is the exact behavior Wake Mechanism forbids.
   - The actual `poll_inbox.sh` on disk does the correct thing (fails with
     `STATE_CORRUPT`, exit 2). So the doc's reference script is the outlier.
   - Patch shape: pick fail-closed as the canonical rule (the on-disk script
     already enforces it); rewrite the Quickstart reset paragraph to describe
     manual operator recreation as a deliberate STATE_CORRUPT recovery step,
     not casual "starting from zero."

2. **Inline reference watcher does not satisfy append-only delivery.**
   - §"Inbox Discipline And Task Checkpoints": *"Watchers track the highest
     processed turn per sender and emit every unread `HANDOFF` block in
     order."*
   - §"Wake Mechanism": *"Inbox watcher --- polls the agent's inbox file,
     emits one line per new handoff with `turn > last_turn` and `to=<agent>`.
     Under the append-only inbox rule it emits one line per unread block in
     turn order."*
   - The inline reference watcher (§"Reference Watcher") only inspects the
     **first** `HANDOFF` header in the inbox (its `awk` exits after the first
     match) and `cat`s the entire inbox file as the emission. With multiple
     unread handoffs appended back-to-back, it would emit the first
     repeatedly, miss the rest, and re-deliver already-processed text on every
     poll.
   - The on-disk `poll_inbox.sh` correctly streams every block and emits only
     unread ones, so the doc text and the shipped script disagree.
   - Patch shape: either replace the doc's inline script with the on-disk
     `poll_inbox.sh` body (preferred), or label the inline block as
     "minimal one-shot illustration, NOT a conforming watcher; see
     `poll_inbox.sh` for the reference implementation" so a forker doesn't
     copy it.

3. **"Per-sender" turn tracking vs. one-state-file-per-receiver design.**
   - §"Inbox Discipline" says watchers *"track the highest processed turn per
     sender."* But the protocol's state-file format (`last_turn=N`) and both
     the inline ref and `poll_inbox.sh` track one global counter per inbox.
   - Turns are already *"monotonic for the receiving agent"* (§Turn
     Discipline), so one counter per inbox is sufficient. The "per sender"
     language is leftover from a more general model and is actively
     misleading.
   - Patch shape: drop "per sender" — "highest processed turn for this
     inbox" (or "for this receiver") is the accurate phrasing.

4. **Quickstart silent on heartbeat watcher.**
   - Quickstart step 5: *"Start one watcher per receiving agent."* Singular.
   - §"Wake Mechanism" describes **two** required persistent watchers per
     agent (inbox + heartbeat), and says treating heartbeat as optional
     breaks the protocol contract.
   - No `heartbeat.sh` ships in the default setup, so a forker following
     Quickstart literally gets a non-conforming system without realizing.
   - Patch shape: either (a) add a heartbeat watcher to Quickstart step 5 and
     ship a default `heartbeat.sh`, or (b) demote heartbeat to "recommended
     for long-running jobs" in §Wake Mechanism. Given the operator's
     "simple/single-process default" stance, (b) is the lighter call for main
     — heartbeat can ship on a booster-pack branch.

Minor language drift, not a contradiction: §"Files And Roles" shows the
generic placeholder names (`notes_for_agent_a.md`) and then the concrete
codex/claude names. A forker has to pick one. See Q3 #5.

## Q2. Rename `ryot.md` to `RYOT.md`?

Yes. The doc already refers to itself as `RYOT.md` in three places that are
load-bearing for the protocol:

- §"Inbox Discipline" callout: *"Before acting after a wakeup, reread
  `RYOT.md` and the relevant task checkpoint..."*
- §"Inbox Discipline" cross-task rule: *"If it needs to affect `RYOT.md`,
  another task's checkpoint, or another task's artifact..."*
- §"Agent Checklist" first line: *"Did I reread RYOT.md and the relevant task
  checkpoint?"*

Right now the file an agent is being told to reread does not exist at that
path. On case-insensitive macOS the slip is invisible; on case-sensitive
Linux/CI it breaks. The doc's branding section also pushes uppercase RYOT
everywhere. Rename is consistent with both intent and self-reference.

Watch-outs when renaming:
- The handoff in `notes_for_claude.md` references `ryot.md` (lowercase) — the
  rename should sweep this and `ryot/tasks/ryot-revision.md` (artifact anchor
  is `ryot.md`).
- The artifact sha256 stays the same (rename does not change content), but
  the git blob id changes only if content changes, which it doesn't here.
  After rename the next handoff should still cite the same sha256.
- Use `git mv` so history follows.

## Q3. Smallest high-value edit list

Ordered by value / risk ratio. All are docs/process-only and stay inside the
"main = simple single-process default" frame.

1. **Rename `ryot.md` → `RYOT.md`** (Q2). Sweep self-references in
   `notes_for_claude.md` and the task checkpoint.
2. **Reconcile state-file-missing rule.** Pick fail-closed (matches shipped
   script). Rewrite the Quickstart reset paragraph; rewrite the inline ref
   watcher's auto-create line.
3. **Fix or relabel the inline reference watcher** so it doesn't contradict
   append-only delivery. Easiest: replace its body with the on-disk
   `poll_inbox.sh`. Otherwise: add a clear "illustrative only, not
   conforming" banner above it.
4. **Drop "per sender" turn-tracking phrasing** from §Inbox Discipline; use
   "per inbox" / "for this receiver."
5. **Pick one canonical agent-name convention** in the file paths shown
   throughout the doc. Recommendation: keep the generic `agent_a` / `agent_b`
   names in §"Files And Roles" and §"Parallel RYOT Jobs" templates, and treat
   `codex` / `claude` as **this repo's instantiation**, called out once. That
   keeps the doc forkable for operators who run different agent pairs.
6. **Demote heartbeat watcher** in §Wake Mechanism from "two persistent
   watchers are required" to "inbox watcher required; heartbeat watcher
   recommended for long-running work, ship via a booster-pack branch." This
   matches the operator's stated single-process-default constraint and
   removes the gap where Quickstart ships an inbox-only setup but the
   protocol claims two watchers are mandatory.
7. **Tighten §"Handoff Header" required-fields list.** The example header
   includes `grading:` but the required-fields list omits it. Either add it
   (consistent with the example) or move it to an "optional fields" sublist.
8. **One-line note in §"`respond_to_sha`"** that bootstrap tokens
   (`RYOT_START_<task>`) apply only when no artifact exists yet, and once an
   artifact lands, every subsequent turn must cite the real hash. The
   current text says "prefer" but the protocol contract is stronger than
   that.

Items I intentionally left off this list (low value or out-of-scope for a
review-only turn):
- Whole-doc rewrite for tone — not needed; voice is already clean.
- Adding new sections (e.g., a "RYOT for solo operator" mode) — that's a
  booster-pack branch, per the operator's framing.
- Renaming `ryot/tasks/` → `RYOT/tasks/`. Directory name is fine lowercase;
  only the protocol file needs the uppercase rename.

## Q4. Bootstrap files / scripts missing from the default setup

Walking the repo against what a fresh forker needs:

**Present and correct:**
`RYOT.md` (after rename), `notes_for_codex.md`, `notes_for_claude.md`,
`poll_codex.sh`, `poll_claude.sh`, `poll_inbox.sh`,
`.handoff_codex_state`, `.handoff_claude_state`, `ryot/tasks/ryot-revision.md`.

**Missing or worth adding to main:**

1. **`.gitignore`.** `.ryot/poll_*.pid` and `.ryot/poll_*.log` are runtime
   state and should not be committed. `.handoff_*_state` is per-checkout
   delivery state — arguable, but I'd ignore it too (a fresh fork should
   start at `last_turn=0`, not inherit the seed repo's counters). Right now
   `git status` shows both `.handoff_*_state` files untracked and the
   operator would have to manually decide.
2. **`README.md` update.** Currently a one-line stub. For a forkable default
   it should say what RYOT is in two sentences and point at `RYOT.md`. This
   is the first file a forker reads.
3. **`LICENSE`.** If the intent is "people will fork this," a license file
   removes the only thing that genuinely blocks forking in good faith.
   Doesn't have to be elaborate — MIT / Apache-2.0 / 0BSD are all fine; this
   is an operator decision.
4. **An `AGENTS.md` (or `CLAUDE.md`) pointer at repo root.** Both Codex and
   Claude harnesses look for these on session start. A 5-line file that says
   "you are an agent in a RYOT job; before responding, reread `RYOT.md` and
   the relevant `ryot/tasks/<task-id>.md` checkpoint; do not edit artifacts
   you do not own; follow the Agent Checklist in `RYOT.md`" hardens the
   protocol against fresh-context agent sessions that haven't yet read
   `RYOT.md`. This is the single biggest cheap win — it directly answers
   §"Context loss" in the failure-modes section.
5. **Seed `ryot/archive/.gitkeep`** so compaction has a target directory on
   day one. `RYOT.md` references `ryot/archive/<task>-<turn-range>.md` as if
   the directory exists.

**Belongs on a booster-pack branch, not main** (per the operator's framing):
- `heartbeat.sh` (only needed for long-running jobs).
- A `ryot-init.sh` scaffolder (the Quickstart's nine steps are manual on
  purpose for a default).
- Multi-job templates (`notes_for_*_<task>.md` per §Parallel RYOT Jobs).
- Any auto-compaction tooling.

**Questions for you (Codex) before you edit:**

1. Do you agree with the rename `ryot.md` → `RYOT.md` and the sweep across
   the handoff + checkpoint? OK to proceed in your next turn?
2. On the state-file-missing rule, my read is that fail-closed (matching the
   shipped `poll_inbox.sh`) should win and the Quickstart reset paragraph
   gets rewritten. Confirm before you edit, because either direction
   requires touching multiple sections.
3. On the heartbeat watcher: do you want to demote it in §Wake Mechanism to
   "recommended for long-running work" so main stays single-process, or
   keep the dual-watcher requirement and add a `heartbeat.sh` to main? I
   recommend the demote; flag if you disagree.
4. Agent-name convention in the doc — keep generic `agent_a`/`agent_b` in
   templates with `codex`/`claude` named as this repo's instantiation, or
   commit fully to `codex`/`claude` throughout?
5. For the README.md / AGENTS.md / LICENSE additions: do these belong in
   this same `ryot-revision` task, or do you want to spin a separate task
   id (e.g. `ryot-bootstrap`) for the non-`RYOT.md` files? I'd group them
   into `ryot-revision` since they're tightly coupled to the doc rename and
   the contradiction fixes, but it's your call as artifact owner.

Human approval gates I'm naming explicitly for the operator before you act:

- Picking a LICENSE is an operator decision; do not pre-select one.
- The `.handoff_*_state` ignore-or-commit decision is also operator-facing —
  a fresh fork starting at `last_turn=0` is the safer default, but I'll let
  the operator confirm.
- Any semantic rewrite beyond the items above needs explicit operator
  approval per the standing constraint.

Standing constraints reaffirmed in this turn: docs/process only, `RYOT.md`
(currently `ryot.md`) owned by Codex, no builds, no network, no destructive
commands.
