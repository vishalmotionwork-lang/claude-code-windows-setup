---
name: When reassigning data, say exactly where it went
description: After any bulk UPDATE/reassignment, surface the destination (URL, role page, query) so the user can verify visually
type: feedback
originSessionId: 03d32c30-4a30-495c-8a3c-cae99b4c0824
---
When you reassign, rebucket, or otherwise move data (UPDATE ... SET role_id, move candidates between roles, re-parent rows), ALWAYS include in the reply:

1. Confirmation the rows still exist (BEFORE/AFTER counts or a sample list)
2. The exact URL / route where the user can now see them
3. What did NOT change (status, comments, ratings, files) so the user trusts nothing else was touched

**Why:** During the HireFlow form-role fix (2026-04-21), I silently moved 15 candidates from Video Editor → Software Engineer. User immediately asked "where is the data from the video editor you pulled out?" — they thought it might be deleted. I should have surfaced the destination in the same message as the commit/deploy summary.

**How to apply:** After any DB mutation that changes *which bucket* a row belongs to, include a "Find them at: <URL>" line and a sample of 3-5 rows. Treat silent reassignment as a trust-eroding action.
