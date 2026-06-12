---
name: vercel-git-caution
description: Never connect GitHub repos to Vercel without checking identity/permissions first
type: feedback
---

Never run `vercel git connect` or suggest connecting a GitHub repo to Vercel without first verifying:
1. The git committer email matches the Vercel team member
2. The GitHub account is linked to the Vercel account
3. The user actually wants auto-deploys from git

**Why:** Connected the HireFlow GitHub repo which caused "Blocked" deploys because the git committer identity (`vishal.motion@Vishals-MacBook-Pro.local`) wasn't authorized on the Vercel team. This cascaded into all subsequent CLI deploys failing with "Unexpected error", requiring manual redeploy from dashboard.

**How to apply:** Always deploy via `vercel deploy --prod` from CLI. Only suggest GitHub integration if the user explicitly asks. Keep git and Vercel deployment separate unless configured by the user.
