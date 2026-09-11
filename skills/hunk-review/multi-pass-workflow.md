# Hunk Review — Local Multi-Pass Workflow

**Status:** general convention for any repo, usable across sessions.

## Why this exists

PR review comments come in via a live Hunk session (`hunk session ...`). Fixes and replies happen
across multiple agent sessions/passes before the branch is pushed. This doc defines how those
passes should behave so each session picks up cleanly where the last one left off.

## Ground rules

0. **Prefer `--repo "$HOST_PWD"` over `--repo .`** when running inside an agent sandbox. The Hunk
   daemon runs on the host and matches sessions by the repo's real path on disk. If the sandbox
   mounts the repo at a different path (e.g. `/workspace`), `--repo .` resolves to a path the Hunk
   daemon doesn't recognize and the session lookup fails. Outside a sandbox, `--repo .` is fine.
1. **Passes are local-only.** Nothing here is about the remote PR/thread state — that's handled
   separately by the human reviewer marking threads resolved on the remote repo, with one final
   reply per thread.
2. **Commits get squashed before push (if that's this repo/PR's convention).** Don't preserve
   fix-history across passes for its own sake (e.g. "fixed in pass 2, see pass 1 note") if there's
   no long-lived audit trail to protect locally. Skip this rule if the repo/PR keeps full history.
3. **Exactly one live Hunk reply per comment thread, always current.** Do not stack "not addressed
   yet" → "now fixed" replies on the same thread across passes. When a later pass fixes something
   an earlier pass left open:
   - Delete the earlier reply: `hunk session comment rm --repo "$HOST_PWD" <comment-id>`
   - Add one fresh reply describing the final state, same `threadId` in `--rationale`, `--author agent`
   (Find the comment-id / threadId pairing via `hunk session comment list --repo "$HOST_PWD" --json --type all`.)

## Per-pass procedure

1. `hunk session comment list --repo "$HOST_PWD" --json --type all` — get the current state of every thread
   (including this agent's own prior replies, which show up with `"author": "agent"`... actually
   note the CLI always reports the *original human reviewer's* author on the comment view; the
   agent's own reply is a separate note in the same thread — match by `threadId` in the body/`rationale`,
   not by author, when looking for "my previous reply to this thread").
2. Decide, per thread, one of:
   - **Fix it now** → make the code/config/doc change, then reply once with what changed.
   - **Still deferring** → leave (or write, if it's the first pass) a single reply explaining why,
     kept up to date each pass (see rule 3).
   - **Needs external info** → if the repo has its own "needs-info" or knowledge-gap convention
     (check that repo's `AGENTS.md`), follow it; otherwise just tell the user what's missing.
3. Before replying, check `git log -p -- <file>` for the touched lines — a *previous* pass or an
   unrelated commit may have already fixed the exact thing a comment is about. Call this out
   explicitly in the reply ("already fixed by commit X, not this pass") rather than re-doing the
   change or claiming credit for it in this pass.
4. Apply replies as a single batch via `hunk session comment apply --repo "$HOST_PWD" --stdin`, one JSON
   object per thread: `{"filePath", "newLine"|"hunk"|"oldLine", "summary", "rationale": "threadId: <id>", "author": "agent"}`.
5. When a later pass supersedes an earlier reply, delete-then-recreate (rule 3) rather than
   appending — keep it to one reply per thread at all times.

## What "done" looks like before push

- Every open thread has exactly one current agent reply reflecting the final local state (fixed /
  deferred-with-reason / needs-info).
- Local commits are squashed/organized per that repo's own convention for the push.
- The human reviewer marks each remote thread resolved with that final reply (or their own
  paraphrase of it) on the actual remote repo — this workflow only governs the local Hunk
  session, not the remote PR state.

## Related

- Check the target repo's own `AGENTS.md` for any repo-specific overrides (e.g. a `needs-info`
  process, or a no-squash convention) before applying this workflow verbatim.
- `SKILL.md` (this skill's main file) for the underlying `hunk session ...` CLI mechanics.
