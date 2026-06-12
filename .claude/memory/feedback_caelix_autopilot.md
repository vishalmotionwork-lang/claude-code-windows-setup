---
name: Caelix autopilot mode
description: When user says autopilot/AFK/no waiting — chain all GSD phases without stopping, skip verification loops, use parallel agents
type: feedback
originSessionId: 5f0361a6-2f4b-4776-8b67-615f9eb88d10
---
When user says "autopilot", "no permissions", "no waiting", "AFK", or "I'm going to be pissed if you wait":
- Chain discuss → plan → execute for each phase without stopping
- Skip plan-checker verification loops (saves 5-10 min per phase)
- Use parallel agents for independent work (Wave 2+ plans that touch different files)
- Write context inline instead of spawning separate discuss-phase agents
- No AskUserQuestion calls — auto-select recommended options
- Skip human checkpoints in plans

**Why:** Vishal got frustrated that planning took too long on Caelix. Sequential agent overhead (researcher → planner → checker → executor) adds up. When user is AFK, skip optional verification and maximize parallelism.

**How to apply:** When Caelix or any project has "full autopilot" instruction, collapse the GSD pipeline: inline context, skip researcher if domain is well-known, skip checker, execute immediately after planner returns.
