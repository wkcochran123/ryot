# RYOT: Roll Your Own Talent

RYOT means **Roll Your Own Talent**.

Off-the-shelf agent stacks pick the agents, the review style, and the stop
conditions for you. RYOT is for the operator who would rather assemble those
pieces: two LLM agents, an inbox each, prompt-timer wakeups, and a strict
review habit.
RYOT is small on purpose. It is not a task queue, a chat server, or a substitute
for human approval. It is a disciplined way for two agents to pass state back
and forth without losing the thread.

## RYOT Brand Usage

Use **RYOT** as the name of the system.

Use **Roll Your Own Talent** when expanding the acronym for a new reader.

Use **RYOT job**, **RYOT handoff**, **RYOT prompt automation**, and
**RYOT artifact** for the moving parts. Avoid falling back to a generic name
like "the two-agent handoff protocol" once the reader knows the brand.

Use **RYOT operator** for the human who owns the approval gates, prompt
automations, and decisions about when the loop stops.

The RYOT promise: two agents that never lose state, never quietly approve their
own work, and never stop without the operator's sign-off.

## Core Idea

Each agent has an inbox file. The other agent writes to that inbox.

```text
notes_for_agent_a.md  <- written by Agent B, read by Agent A
notes_for_agent_b.md  <- written by Agent A, read by Agent B
```

A RYOT prompt automation wakes the receiving agent on a cadence. At each wake
the agent reads its inbox directly, compares the latest valid `HANDOFF` turn
against its handled-state file, handles the current safe unit of work, records
the handled turn only after acting, and then stops.

## Wake Discipline

A wake is not finished after one message if more work is already available. At
each wake, the receiving agent should drain every fresh handoff in its inbox
until one of these stop conditions appears:

```text
no newer handoff is available
the next action requires operator approval
the next action belongs to the other agent
the current artifact has an unresolved failed check
```

For active editing loops, use a tight wake cadence while work is moving. A slow
heartbeat is for quiet monitoring only, not for an open do/review exchange.
When a wake accepts a section and assigns the next section, it leaves the
thread automation active with a short interval and a drain-all instruction.

The RYOT operator owns the dangerous parts:

- approving source edits, builds, long experiments, and destructive commands;
- deciding when jobs may run in parallel;
- maintaining or pausing prompt automations;
- stopping the loop when the agents need judgment rather than more iteration.

## Files And Roles

A minimal RYOT setup needs:

```text
notes_for_agent_a.md
notes_for_agent_b.md
.handoff_agent_a_state
.handoff_agent_b_state
one prompt automation per active receiving agent
```

In this repository the concrete names are:

```text
notes_for_codex.md
notes_for_claude.md
.handoff_codex_state
.handoff_claude_state
Codex app heartbeat / prompt automation for each live role
```

The `.handoff_<agent>_state` files are handled ledgers: they say which handoffs
the agent has actually processed. RYOT no longer uses separate foreground
poller delivery ledgers. A prompt automation may notice a handoff many times,
but it must update handled state only after the receiving agent has actually
accepted, rejected, blocked, or otherwise recorded that handoff.

Agents can be symmetric peers, but most jobs benefit from temporary roles:

```text
Writer / Reviewer
Implementer / Auditor
Proof author / Formalism critic
Drafting agent / Style and correctness grader
Patch author / Build-output diagnostician
Doer / Thinker-planner
Podo / Kodo
```

State the roles in the first handoff for each job.

## Kodo / Podo Split

Kodo and Podo are the preferred RYOT names for the thinker/doer split.

```text
Kodo  thinker-planner, reviewer, budget/order keeper, formalism critic,
      UAT/checkpoint owner, and final acceptance gate.

Podo  doer-agent, patch author, proof writer, drafter, build/report runner,
      and uncertainty reporter inside the restricted prompt.
```

Routing ids and role names are separate. In this repository, `codex` is usually
the Kodo route and `claude`, `antigravity`, or a second Codex thread may serve
as Podo. A second Codex may be Podo only if it accepts the doer contract and
does not claim Kodo's final gate-closing authority.

For jobs that use Kodo/Podo:

```text
Podo  writes code, drafts prose, applies patches, runs authorized checks, and
      reports exact changed files, hashes, output, and uncertain points.

Kodo  reads state, chooses the next concrete task, critiques the result,
      catches overclaims, and keeps the operator's approval gates explicit.
```

If there is unblocked work and Podo appears idle, Kodo should send the next
small actionable handoff rather than waiting passively. If Podo cannot
continue, it should write `BLOCKED` with the smallest concrete question and
stop.

## Beastmaster

The beastmaster is an occasional "(semi)-outside verifier" layered over a
Kodo/Podo job. Most jobs never need one. It is semi-outside by design: inside
enough to read the live state and feed the loop through Kodo's inbox, yet
outside enough to verify the whole artifact on its own terms and refuse capture
by the pair's local gates. A beastmaster is warranted when the doer/reviewer
pair has begun solving problems in ways that clear each local gate yet drift
away from what the operator actually wants across the whole artifact ---
"unorthodox" problem solving that is locally clever and globally wrong.

```text
Kodo / Podo   produce and review one section at a time.
Beastmaster   watches the whole world around the pair: the full artifact, the
              source it claims to restate, the operator's standing mandates,
              and the arc no per-section gate can see.
```

Charter:

```text
- Give feedback, do not solve. The beastmaster never owns or edits the produced
  artifact (book prose, proof code). It reads, judges, and reports.
- Hold the cross-cutting mandates a section gate is blind to: voice, idiom,
  source-leakage, fidelity to the source, and global scope.
- Keep the pair moving and in bounds: rein in drift, unblock stalls, and refuse
  premature convergence.
- Own the completion call. The beastmaster declares the job done only when its
  mandates hold across the whole artifact, and sends Kodo and Podo back to work
  when they do not. This is a stricter, later gate than Kodo's per-section
  acceptance, never a replacement for it.
```

Discipline:

```text
- Advisory to Kodo's gates. The beastmaster recommends; Kodo issues the gate to
  Podo. The beastmaster does not open or close writing gates directly.
- Do not corrupt the turn machinery. The receiver's handled-state integer
  tracks the doer/reviewer turn stream only. Beastmaster feedback goes to its
  own ledger (long reviews) plus a short, clearly marked advisory pointer in
  Kodo's inbox --- never a doer/reviewer turn number.
- Separate K-items from P-items. A K-item needs a Kodo ruling; a P-item is a
  doer fix contingent on Kodo opening a revision gate.
- One small cycle at a time. Each beastmaster cycle files at most one refinement
  and one focused review, then stops.
```

The beastmaster keeps a private coordination ledger, never reader-facing, that
records its mandate, its running verdicts, and its cycle log.

## Parallel Lanes

A RYOT job may split into parallel lanes when the operator approves more than
one kind of work around the same subject.

Use one shared subject, one active inbox pair, and explicit lane labels:

```text
Lean lane      Doer writes isolated code; thinker-planner reviews theorem shape.
Prose lane     Thinker-planner drafts explanation; doer edits as domain critic.
Build lane     Operator or assigned doer runs the expensive experiment.
```

Every handoff should state which lane it concerns. If two lanes are active, the
agents should avoid blocking each other: code review can continue while prose is
drafted, and prose editing can wait until the doer is no longer in the middle of
a fragile patch. Shared claims must still converge through the same checkpoint
files before either lane declares victory.

## Multiple RYOT Jobs

Several RYOT jobs may run on the same machine at once. Treat project scope as a
first-class guardrail.

Each handoff should name the active workspace, task id, and owned artifacts.
Each agent should trust its own inbox, its own handled-state file, and
checkpoint files inside the active workspace. Process lists, terminal chatter,
and automation output from another workspace are noise unless the operator
explicitly connects the jobs.

When another RYOT job is known to be noisy, add a constraint like:

```text
ignore unrelated RYOT activity outside <workspace-or-task>
```

This keeps a long build, a noisy side project, or a second pair of agents from
becoming a false trigger in the current job.

## Two-Phase Do/Review

For paired code/prose work, use a two-phase cycle:

```text
Phase 1 - DO
  Agent A owns proof/code artifacts.
  Agent B owns prose/explanation artifacts.
  Both work in parallel and write compact progress handoffs.
  Neither agent edits the other's owned artifact during this phase.

Phase 2 - REVIEW
  Agent A reviews the prose for technical correctness.
  Agent B reviews the proof/code for theorem shape, assumptions, and exposition.
  Review produces explicit CHANGES_REQUESTED or HANDOFF_CONVERGED turns.
```

The handoff between phases must name artifact hashes, open risks, and the exact
review question. This keeps production parallel but correctness adversarial.
Do/review cycles may repeat many times under the same 500-step target.

## Section-Scoped Writing

When a RYOT job includes a book, article, long README, module document, or
other prose artifact, split writing work by section rather than by whole file.

Each writing handoff should name one target section:

```text
artifact: volume_7.md
section: Chapter 2 / Uncommon Path
goal: clarify the gate cascade for a public reader
checks: word budget, banned terms, citations, claim boundary
```

The receiving agent should edit or review only that section unless the handoff
explicitly labels the work as a mechanical whole-file check. Mechanical checks
include build, citation scan, banned-token scan, ASCII scan, and warning scan.
This keeps context local, makes critique sharper, and prevents a large prose
artifact from turning into one undifferentiated task.

## Proof-Backed Prose Stance

When the operator asks for prose written as though a proof stack compiles, write
from the theorem statement rather than from nervous process commentary. Keep
the formal boundaries visible, but avoid turning every sentence into a hedge.

If a prose section exposes a mismatch with the formal artifact, record a Lean
audit flag instead of weakening the prose until the mismatch disappears. The
reviewer should separate three cases:

```text
confirmed theorem surface       prose may speak directly
named bridge assumption          prose may speak directly inside that boundary
artifact/prose discrepancy       mark as Lean audit flag and queue proof review
```

This stance is especially useful when a long build is running. The prose lane
can advance from the accepted theorem design while the build lane remains
observational. If the build later fails, the RYOT job reopens the proof lane and
repairs the artifact rather than pretending the book never made a claim.

## RYOT Quickstart

1. Choose agent ids.
2. Choose roles for the first job.
3. Create inbox files.
4. Create state files with `last_turn=0`.
5. Create one prompt automation per receiving agent.
6. Seed the first handoff with `respond_to_sha: RYOT_START_<task>`.
7. At each automation wake, have the agent check its own inbox directly.
8. Continue until one agent sends `CONVERGED` and the other sends
   `HANDOFF_CONVERGED`.
9. Pause/delete the prompt automations or start the next job with a new task id.

To recover from a missed wake without replaying stale turns:

1. Pause the prompt automation if it is still firing badly.
2. Edit the state file so `last_turn` equals the highest already-processed
   turn from the latest valid handoff.
3. Re-enable the automation or send a one-time manual prompt to the agent.

If the state file is missing or corrupt, recreate it with the correct
`last_turn`. Starting from zero can replay the whole conversation.

## First-Run Setup Conversation

When a user asks an LLM to start their first RYOT process, the LLM should act as
the setup guide before writing handoffs or creating automations. Begin by
explaining RYOT in ordinary terms:

```text
RYOT is a small two-agent loop. One agent acts as Kodo, the thinker/reviewer who
keeps scope, gates, and acceptance criteria honest. The other acts as Podo, the
doer who drafts, patches, runs approved checks, and reports exactly what changed.
Each writes to the other's inbox, and prompt automations wake them until the
operator accepts the result or pauses the job.
```

Then ask the operator to choose the concrete Kodo/Podo pair for this job. Ask
for agent routes, not just personality labels:

```text
Which pair should run this RYOT job?

Kodo route: <codex | claude | antigravity | other thread id>
Podo route: <codex | claude | antigravity | other thread id>
```

After the pair is chosen, collect only the setup facts needed for the first
handoff:

```text
1. What is the task id?
2. What artifact, file, folder, or external goal is in scope?
3. What should Podo do first?
4. What must Podo not do without approval?
5. Are edits, builds, tests, network access, or destructive commands allowed?
6. What does done look like?
7. How often should each prompt automation wake while the job is active?
```

If the operator is unsure, propose conservative defaults:

```text
Kodo: Codex
Podo: Claude or a second Codex thread
state files: last_turn=0
first scope: one small artifact or one bounded section
allowed actions: read/search only until the operator approves edits
done condition: Podo reports changes, Kodo reviews, operator accepts
wake cadence: short while active, paused after convergence
```

Before creating files or automations, summarize the proposed RYOT job back to
the operator and ask for approval. The summary should name the Kodo/Podo pair,
task id, inbox files, state files, first handoff target, allowed actions,
forbidden actions, done condition, and automation cadence. Once approved, create
the inboxes and state files, seed turn 1 with `respond_to_sha:
RYOT_START_<task>`, and remind each agent to reread this file and the current
task checkpoint on every wake.

## Handoff Header

Every handoff file should begin with a machine-readable header:

```markdown
<!-- HANDOFF
from: agent_a
to: agent_b
turn: 17
status: NEEDS_RESPONSE
respond_to_sha: <artifact-sha-or-ryot-bootstrap-token>
stop_token: HANDOFF_CONVERGED
task: short-task-id
scope: what-this-message-covers
stop_mode: two-phase
grading: strict
constraint: no source edits without approval; no build unless approved
protocol_version: v1
-->
```

Required fields:

```text
from              sender id
to                receiver id
turn              strictly increasing integer for the receiver
status            current state of this handoff
respond_to_sha    artifact hash, output hash, decision id, or bootstrap token
stop_token        usually HANDOFF_CONVERGED
task              stable job id
scope             current slice of the job
stop_mode         usually two-phase
constraint        permissions, build limits, edit limits, or user rules
protocol_version  protocol version used by both agents
```

Use exact agent ids. If the receiving role is `codex`, do not write
`to: Codex`.

## Status Vocabulary

RYOT uses a small status vocabulary.

```text
NEEDS_RESPONSE       open turn; receiving agent should reply
CHANGES_REQUESTED    review with specific revisions named
CHANGES_APPLIED      edits landed; details in body
CONVERGED            sender believes the job is complete
HANDOFF_CONVERGED    receiver ratifies convergence; both stop for this job
BLOCKED              agent cannot proceed; RYOT operator input required
WITHDRAWN            sender retracts a prior handoff
INFO_ONLY            informational; no action expected
```

When an agent needs the RYOT operator, use `status: BLOCKED` and put the
smallest concrete question in the body.

Keep prompt-automation behavior and human protocol aligned. An automation may
only stop or pause on the exact status values it implements.

## `respond_to_sha`

`respond_to_sha` anchors a multi-turn conversation.

Use one of:

```text
file hash             when discussing a specific artifact
output hash           when diagnosing a build or experiment result
bootstrap token       before an artifact exists, e.g. RYOT_START_<task>
decision id           when converging on a design choice rather than a file
```

Once an artifact exists, prefer a real hash. If the artifact changes, update the
hash in the next handoff so both agents know which version is under discussion.

## Message Body

After the header, write a self-contained handoff. Assume the other agent may
have lost prior context.

Good handoffs include:

- what changed or what was read;
- artifact hashes, file paths, and line numbers;
- observations separated from inferences;
- patch shape separated from edits actually made;
- unresolved questions;
- human approval gates;
- the exact response requested from the other agent.

Do not bury the request. End with direct questions or a checklist.

## Turn Discipline

Turns are monotonic for the receiving agent. If Agent A writes to Agent B with
`turn: 17`, the next message to Agent B must use `turn: 18` or higher.

When retrying a bad handoff, always use a fresh turn. Rewriting an already
processed turn will usually be ignored by the receiving agent's handled-state
check.

Crossed turns are normal. If both agents write before reading the other's latest
message, each should acknowledge the crossing, state which turn it is answering,
and carry forward any constraints or open questions that still apply.

## Prompt Automations

RYOT uses the agent's own prompt automation as the wake mechanism. Do not rely
on `poll_*.sh`, foreground shell loops, `tail -f`, or legacy delivery-state
files as the live protocol.

At each wake, the receiving agent performs one bounded check:

```text
read INBOX
find the newest valid HANDOFF addressed to AGENT
ignore malformed, self-authored, or misaddressed handoffs
compare turn against .handoff_<agent>_state
if turn is fresh, handle the safe current unit of work
record handled state only after the response/checkpoint is written
stop
```

The prompt automation is not a proof worker by itself. It wakes the agent, and
the agent applies the normal RYOT constraints, ownership rules, and approval
gates. During an active exchange, a 3-minute heartbeat is appropriate. During a
quiet wait, use a slower cadence or pause the automation.

The automation prompt should name:

```text
workspace root
agent id
inbox file
handled-state file
task checkpoint
current lane constraints
what to report when idle or blocked
```

## Inbox Discipline And Task Checkpoints

RYOT inboxes are append-only while messages are in flight. Writers append new
handoffs; they do not overwrite unread handoffs. Prompt automations wake the
receiving agent, and the receiving agent uses handled-state files to decide
which addressed `HANDOFF` blocks are still fresh.

> [!IMPORTANT]
> Append-only inboxes are a delivery guarantee, not long-term memory. When a
> task starts to repeat context, grows expensive to read, or crosses a check-in
> boundary, recycle the message box: absorb processed decisions into
> `ryot/tasks/<task-id>.md`, compact the inbox, and continue from the
> checkpoint. Before acting after a wakeup, reread `RYOT.md` and the relevant
> task checkpoint so the current turn is grounded in the latest written state,
> not only in model context.

A check-in boundary is one of:

- a task's two-phase convergence completes (`HANDOFF_CONVERGED` received and
  ratified);
- the RYOT operator requests it;
- the inbox exceeds an agreed size threshold and all in-flight handoffs have
  been processed.

At a check-in boundary, agents may compact the inbox. Compaction appends an
entry to the relevant task checkpoint recording:

- the turn range compacted, such as `turns 451-457`;
- the decisions accepted during that range;
- any deferred or rolled-back proposals named explicitly;
- the resulting artifact hash at the end of the range.

After the entry is written, the compacted `HANDOFF` blocks may be moved to
`ryot/archive/<task>-<turn-range>.md` or deleted. Compaction must never delete
an unread handoff or an unresolved decision.

A handoff may not be compacted until both conditions hold:

1. The receiving agent's handled-state file has advanced past the handoff turn.
2. The relevant task checkpoint has been updated to absorb its content.

Compaction races violate the delivery guarantee even when the prompt automation
is firing correctly.

For long jobs or parallel work, each task keeps a compact checkpoint at
`ryot/tasks/<task-id>.md`. The checkpoint is a state vector, not a transcript:
task id, owner, artifact anchors, accepted decisions, open questions, blocked
approvals, next action, and last turn seen from each agent. The checkpoint is
the source of truth when the inbox is lost or an agent's context is compacted.

Cross-task changes require ownership acknowledgement. A task may edit only its
owned artifacts and checkpoint. If it needs to affect `RYOT.md`, another task's
checkpoint, or another task's artifact, it proposes the change in a fresh
handoff under `task: ryot-revision` or a dedicated merge task. Apply only after
the affected owner acknowledges.

Promote to a formal merge ledger only when three or more live tasks contend on
the same artifact or when merge decisions themselves become hard to track.

## Starting A RYOT Job

The first message should define:

- task id;
- artifact or directory under discussion;
- roles;
- allowed actions;
- forbidden actions;
- done condition;
- whether edits, builds, tests, or network access are allowed.

Example:

```markdown
<!-- HANDOFF
from: reviewer
to: writer
turn: 1
status: NEEDS_RESPONSE
respond_to_sha: RYOT_START_VOLUME6_CHAPTER2
stop_token: HANDOFF_CONVERGED
task: volume6-chapter2-public-pass
scope: first section only
stop_mode: two-phase
grading: strict
constraint: edit only volume_6.md; no builds; keep section 900-1200 words
protocol_version: v1
-->

# Handoff Turn 1 - Start Section Pass

Revise only the first section. Explain the metaphor before using it, remove
self-reference, and keep the word count between 900 and 1200 words. Reply with
the edited span and a short audit.
```

## Standing Constraints

Repeat standing constraints in every header. Do not rely on memory.

Examples:

```text
constraint: no .lean edits without per-edit human approval; no lake/lean/build
constraint: do not modify device/out
constraint: docs only; no source edits
constraint: no destructive commands
```

If an agent violates or nearly violates a constraint, the next handoff should
withdraw the recommendation explicitly.

## Artifact Ownership

At any moment, exactly one agent owns each editable artifact. The owner is named
in the handoff's `scope:` field as the writer or implementer. The other agent
reads the artifact and proposes changes through handoff text, not direct edits.

If both agents need to edit the same artifact, hand ownership across explicitly:

```text
Agent A: status CHANGES_APPLIED; handing scope to agent_b
Agent B: status CHANGES_APPLIED; edits made; scope returns to agent_a
```

Concurrent edits to a single artifact can overwrite each other. The automation
cannot prevent this; the discipline must.

## Withdrawals And Corrections

Use `status: WITHDRAWN` when an entire prior handoff is being retracted, such as
a misaddressed message, a wrong artifact, or a premature convergence claim.

Use an inline correction when only one recommendation inside a live handoff is
being retracted. The current turn's status may still be `NEEDS_RESPONSE`,
`CHANGES_REQUESTED`, or whatever fits the live work.

Example:

```text
Correction: In turn 12 I suggested running a build. That violated the standing
constraint. Withdrawn. Future references to a build are future experiments only
and require explicit human approval.
```

Corrections should cite the turn being corrected and say what replaces it.

## Human Approval Gates

The RYOT operator must explicitly approve:

- source edits during a diagnosis-only loop;
- builds, tests, or long experiments;
- network access;
- destructive commands;
- major semantic changes;
- changes that invalidate cached work;
- starting a second live job on the same inbox pair.

If the agents cannot proceed safely without the RYOT operator, send a handoff
with `status: BLOCKED`. The body should ask the smallest concrete question that
unblocks the job.

## Iteration Pattern

Each round should tighten the problem.

Useful body structure:

```text
1. Current state
2. What I checked
3. Findings
4. Proposed change or patch shape
5. Questions for the other agent
6. Human decisions needed
```

## Heartbeat Updates

When an agent is waiting on a long-running process --- a build, a slow
experiment, an operator-controlled run, any task that does not complete
inside a single agent turn --- send an `INFO_ONLY` heartbeat update to
the other agent every 15 minutes. The heartbeat is short: elapsed time,
latest visible progress (target reached, last log line, output file
size), and a one-line forecast.

The point is to keep the loop alive without keeping an agent turn busy staring
at a silent file. A heartbeat says "still running, no new findings, will report
on completion."

If the long-running process completes between heartbeats, skip the
heartbeat and send the actual diagnostic turn instead. If three
consecutive heartbeats show no progress, escalate to `BLOCKED` and
ask the RYOT operator whether to keep waiting.

A heartbeat is a turn like any other. Use a fresh turn number, the
running task id, and `status: INFO_ONLY`. Set `respond_to_sha` to the
artifact or output the long-running process targets, so the other
agent can re-anchor when the wait ends.

## Wake Mechanism

A heartbeat discipline is only as reliable as the agent's wake mechanism. RYOT
uses the Codex app heartbeat / prompt-timer mechanism rather than shell
pollers. The automation wakes the thread on a schedule and gives the agent a
normal prompt; the agent then reads the inbox and state files itself.

For an active two-agent exchange, set the heartbeat to a short interval, usually
3 minutes. For long quiet waits, slow the heartbeat or pause it.

Each wake must be bounded:

```text
1. Inspect the agent's inbox.
2. Compare the newest valid addressed handoff with handled state.
3. If a fresh handoff exists, process exactly the current safe unit of work.
4. If no fresh handoff exists, report a short idle status.
5. Do not start a shell loop.
6. Do not resurrect `poll_*.sh`.
```

If the automation cannot prove delivery of unread handoffs, the system must use
manual operator pings until the automation is repaired.

## Pre-Convergence Checklist

Before sending `CONVERGED`, verify:

```text
[ ] All open questions are answered or explicitly handed to the RYOT operator.
[ ] Standing constraints are still satisfied.
[ ] Accepted, rejected, and deferred patch shapes are named.
[ ] The final artifact state is summarized.
[ ] No hidden NEEDS_RESPONSE or BLOCKED item remains.
[ ] The other agent is asked to acknowledge and stop.
```

## Convergence And Stop

Use two-phase stop.

Phase 1:

```text
Agent A sends status: CONVERGED
```

Agent A summarizes the accepted state and asks Agent B to acknowledge.

Phase 2:

```text
Agent B sends status: HANDOFF_CONVERGED
```

Agent B confirms agreement and stops listening for that job.

If Agent B does not agree that the job is complete, Agent B replies with
`CHANGES_REQUESTED`, not `HANDOFF_CONVERGED`. There is no unilateral stop.

## Parallel RYOT Jobs

Default rule: run one job at a time per inbox pair.

If jobs truly run in parallel, use per-task inboxes and per-task state files:

```text
notes_for_agent_a_<task>.md
notes_for_agent_b_<task>.md
.handoff_agent_a_<task>_state
.handoff_agent_b_<task>_state
```

One state file per direction is fine for a single serialized queue. It is not
enough when two tasks can produce independent turn sequences at the same time.

## Failure Modes

Stale turn:

```text
Symptom: agent ignores the handoff as already handled.
Cause: turn number was already processed.
Fix: resend with a higher turn number.
```

Wrong recipient:

```text
Symptom: agent says the file is addressed to another agent.
Cause: `to:` does not match the receiving agent id.
Fix: correct `to:` and bump the turn if needed.
```

Self-addressed loop:

```text
Symptom: agent appears to answer itself.
Cause: automation prompt or inbox route is misconfigured.
Fix: ensure each agent writes only to the other agent's inbox.
```

Constraint drift:

```text
Symptom: forbidden edits, builds, or commands are proposed.
Cause: constraints were omitted in later turns.
Fix: repeat constraints in every header and withdraw bad recommendations.
```

Convergence theater:

```text
Symptom: agents stop while questions remain.
Cause: convergence was declared for social closure, not because the job closed.
Fix: use the pre-convergence checklist.
```

Concurrent writes:

```text
Symptom: one message disappears.
Cause: two processes wrote the same inbox or artifact.
Fix: enforce one writer per inbox and one owner per artifact.
```

Context loss:

```text
Symptom: agent repeats old questions or misses decisions.
Cause: prior conversation context was compacted or forgotten.
Fix: make every handoff self-contained.
```

## RYOT Example Review Handoff

```markdown
<!-- HANDOFF
from: reviewer
to: implementer
turn: 12
status: NEEDS_RESPONSE
respond_to_sha: 8f1b2c3d
stop_token: HANDOFF_CONVERGED
task: build-output-diagnosis
scope: patch shape only
stop_mode: two-phase
grading: strict
constraint: no source edits; do not run build
protocol_version: v1
-->

# Handoff Turn 12 - Build Output Diagnosis

I read `out`, hash `8f1b2c3d`. The hard failure is in `module/foo.ext`.

Findings:

- `module/foo.ext:42` passes a value with the wrong shape.
- `module/foo.ext:61` triggers a large dependency search.

Patch shape:

```text
Replace the constructor argument with the canonical value produced earlier in
the pipeline.
```

Questions:

1. Do you agree this is the constructor fix?
2. Should the dependency be referenced by name rather than rediscovered?
3. Is the warning part of this patch or a separate experiment?
```
```

## RYOT Example Prose Handoff

```markdown
<!-- HANDOFF
from: editor
to: writer
turn: 8
status: CHANGES_REQUESTED
respond_to_sha: chap2-draft-3
stop_token: HANDOFF_CONVERGED
task: volume3-chapter2-voice-pass
scope: section "The Galileo Page" (lines 412-540)
stop_mode: two-phase
grading: strict
constraint: do not change cited dates, names, or quotations; keep 900-1100 words
protocol_version: v1
-->

# Handoff Turn 8 - Section Voice Pass

Span: lines 412-540 of `volume3-chapter2.md`.

Findings:

- "the reader" appears at lines 421, 469, and 503.
- the metaphor "carrier under load" appears before it is anchored.
- word count is 1162; soft ceiling is 1100.

Changes requested:

1. Replace "the reader" with direct address or removal.
2. Anchor the carrier-under-load metaphor before using it.
3. Bring word count to 1050-1100 by trimming repeated cadence paragraphs.

Quote each replacement in your reply with old/new line content so I can verify
before you commit.
```

## Agent Checklist

Before replying:

```text
[ ] Did I reread RYOT.md and the relevant task checkpoint?
[ ] Is the handoff addressed to me?
[ ] Is this the newest turn?
[ ] Did I inspect the referenced artifact?
[ ] Did I separate observations from inferences?
[ ] Am I proposing a patch, or actually applying one?
[ ] Do I need human approval?
[ ] Did I preserve constraints?
[ ] Did I use a fresh turn number?
```

Before editing:

```text
[ ] The current loop permits edits.
[ ] The artifact is the one named in scope.
[ ] I am the current artifact owner.
[ ] I am not overwriting another live job.
[ ] The RYOT operator has approved any risky action.
```

## Adaptation Notes

For code:

- lead with bugs and risks;
- include build output hashes;
- cite file paths and line numbers;
- separate compile fixes from semantic fixes;
- do not run expensive tests without approval.

For books or documents:

- separate voice, structure, correctness, and constraints;
- set section scope;
- set word budgets if relevant;
- state voice constraints;
- track prohibited terms explicitly.

For formalization:

- separate syntax errors, universe/typeclass problems, semantic claims, and
  proof strategy;
- distinguish definitions, lemmas, intended theorems, and experiments;
- identify what is proved, assumed, or metaphorical;
- keep search/runtime experiments separate from proof patches.

For long-running experiments:

- preserve exact input hashes;
- record settings;
- do not change debug options without approval;
- state what the next output should prove or disprove.
- use heartbeat prompt automations for long waits so agents do not spend active
  turns staring at silent files;
- send an `INFO_ONLY` heartbeat to the other agent every 15 minutes
  while waiting; see Heartbeat Updates above.

For non-deterministic outputs:

- record prompts, seeds, model names, settings, and input hashes;
- distinguish reproducible state from sampled output;
- expect review to focus on the distribution of results, not one run alone.

## RYOT Final Rule

RYOT works when each agent preserves the other agent's future context.
Write every handoff so the other agent can resume after forgetting the previous
conversation. If that feels repetitive, it is probably doing its job.

Updates to RYOT should go through RYOT using a task id such as `ryot-revision`.

<!-- INFO_ONLY
from: antigravity
to: codex
timestamp: 2026-06-12T12:35:25.590234
-->

# Antigravity Ping

Kodo, I am still waiting for your response to Turn 90. I have checked my inbox several times and am standing by for the C02-S03 O2 outline or C02-S03 Outline Agreed handoff. 
