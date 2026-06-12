---
name: feedback_vercel_commit_author
description: Vercel rejects deployments when commit author email isn't linked to a GitHub account the Vercel team recognizes
type: feedback
originSessionId: c04d07d1-65e3-448f-acfe-d135255df6b2
---
When deploys fail on Vercel with status "Error" and no useful CLI logs, check the GitHub commit status endpoint first:

```bash
gh api repos/OWNER/REPO/commits/$(git rev-parse HEAD)/statuses --jq '.[] | "\(.state) \(.context) — \(.description)"'
```

If you see `No GitHub account was found matching the commit author email address`, the root cause is the commit was authored with an email that isn't linked to the GitHub account the Vercel team is hooked to. Git's auto-detected local hostname identity (`user@machine.local`) will always fail this check.

**Why**: Vercel's GitHub integration requires commit authors to be a known GitHub user for billing/authorization. If unrecognized, Vercel marks the deployment as Error at 0ms with no build logs surfaced via `vercel inspect --logs` or `vercel logs`.

**How to apply**: Before pushing to a Vercel-linked repo, verify `git config user.email` matches an email on file at the GitHub account that owns (or is a member of) the Vercel team. For shared accounts like `zeeel-ai`, either:
- `gh auth login` with that account + `gh auth setup-git`
- OR use the GitHub noreply email `ID+username@users.noreply.github.com` in git config

**Secondary signal**: if CLI-direct `vercel deploy` also fails with "Unexpected error", it's likely cascading from the same account-level auth issue, not a separate build break. Fixing the commit author usually unblocks both paths.

**Preflight (mandatory) before claiming a Vercel-linked push is "live"**: After `git push`, run the gh statuses query above for the new HEAD sha. If state == failure with the email-mismatch message, immediately amend with `git commit --amend --author="<known-good>" --no-edit && git push --force-with-lease`. Don't tell the user the deploy is shipping until the status flips to success. This bit me 2026-04-30 in content-ops despite the rule above existing — the cost of skipping the preflight is the user finding the broken deploy themselves.

**Known-good authors per repo**:
- `zeeel-ai/content-ops` → `Zeel <zeel@knowai.club>` (verified working through 2026-04-30)
