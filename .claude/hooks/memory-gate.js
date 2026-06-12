#!/usr/bin/env node
// Memory Gate — PreToolUse hook (ENFORCED)
//
// BLOCKS non-Read tool calls until hot.md has been read this session.
// This prevents Claude from doing any work without loading context first.
//
// Flow:
// 1. Read/Glob/Grep tools → always allowed (how you load context)
// 2. First non-read tool call → BLOCKED with "read hot.md first"
// 3. After hot.md is read → flag file created, all tools pass through
// 4. Also injects feedback file reminders as additionalContext

const fs = require("fs");
const os = require("os");
const path = require("path");

const SESSION_FLAG_DIR = path.join(os.tmpdir(), "claude-memory-gate");
const HOT_MEMORY_PATH = path.join(os.homedir(), ".claude", "context", "hot.md");
const MEMORY_DIR = path.join(
  os.homedir(),
  ".claude",
  "projects",
  "-Users-vishal-motion",
  "memory",
);

// Tools that are always allowed (read-only, needed to load context)
const ALWAYS_ALLOWED = new Set([
  "Read",
  "Glob",
  "Grep",
  "Agent",
  "Skill",
  "ToolSearch",
]);

// Max tool calls to block before giving up (safety valve — don't infinite-block)
const MAX_BLOCKS = 3;
const BLOCK_COUNT_PATH = path.join(SESSION_FLAG_DIR, "block-count.txt");

let input = "";
process.stdin.setEncoding("utf8");
process.stdin.on("data", (chunk) => {
  input += chunk;
});
process.stdin.on("end", () => {
  try {
    const event = JSON.parse(input);
    const result = handleEvent(event);
    console.log(JSON.stringify(result));
  } catch (e) {
    // Don't block on errors — pass through
    console.log(JSON.stringify({ allow: true }));
  }
});

function getSessionId() {
  const today = new Date().toISOString().split("T")[0];
  return `${today}-${process.ppid}`;
}

function getSessionFlagPath(type = "hot") {
  return path.join(SESSION_FLAG_DIR, `${type}-read-${getSessionId()}.flag`);
}

function hasReadHotMemory() {
  return fs.existsSync(getSessionFlagPath("hot"));
}

function hasReadPrefetch() {
  return fs.existsSync(getSessionFlagPath("prefetch"));
}

function markHotMemoryRead() {
  fs.mkdirSync(SESSION_FLAG_DIR, { recursive: true });
  fs.writeFileSync(getSessionFlagPath("hot"), new Date().toISOString());
}

function markPrefetchRead() {
  fs.mkdirSync(SESSION_FLAG_DIR, { recursive: true });
  fs.writeFileSync(getSessionFlagPath("prefetch"), new Date().toISOString());
}

function getBlockCount() {
  try {
    const countFile = path.join(
      SESSION_FLAG_DIR,
      `blocks-${getSessionId()}.txt`,
    );
    if (fs.existsSync(countFile)) {
      return parseInt(fs.readFileSync(countFile, "utf8").trim()) || 0;
    }
  } catch {}
  return 0;
}

function incrementBlockCount() {
  fs.mkdirSync(SESSION_FLAG_DIR, { recursive: true });
  const countFile = path.join(SESSION_FLAG_DIR, `blocks-${getSessionId()}.txt`);
  const count = getBlockCount() + 1;
  fs.writeFileSync(countFile, String(count));
  return count;
}

function getToolName(event) {
  return event?.tool_name || event?.tool || "";
}

function getFeedbackFiles() {
  try {
    const files = fs.readdirSync(MEMORY_DIR);
    return files.filter((f) => f.startsWith("feedback_") && f.endsWith(".md"));
  } catch {
    return [];
  }
}

function handleEvent(event) {
  const toolName = getToolName(event);

  // Always allow read-type tools — that's how context gets loaded
  if (ALWAYS_ALLOWED.has(toolName)) {
    const filePath = event?.tool_input?.file_path || "";
    if (filePath.includes("hot.md") || filePath.includes("MEMORY.md")) {
      markHotMemoryRead();
    }
    if (filePath.includes("prefetched.md")) {
      markPrefetchRead();
    }

    // AUTO project switch: when Claude reads a project's CONTEXT.md,
    // trigger background re-prefetch for that project automatically.
    // No command needed — the hook observes the Read and acts.
    if (filePath.includes("/projects/") && filePath.includes("CONTEXT.md")) {
      const match = filePath.match(/projects\/([^/]+)\//);
      if (match) {
        const project = match[1];
        const switchFlagPath = path.join(
          SESSION_FLAG_DIR,
          `switched-${getSessionId()}.flag`,
        );
        if (!fs.existsSync(switchFlagPath)) {
          fs.mkdirSync(SESSION_FLAG_DIR, { recursive: true });
          fs.writeFileSync(switchFlagPath, project);
          // Fire background re-prefetch — non-blocking
          const { exec } = require("child_process");
          const scriptsDir = path.join(os.homedir(), ".claude", "scripts");
          exec(
            `uvx --with qdrant-client --with sentence-transformers python3 "${scriptsDir}/prefetch_context.py" --project "${project}" && python3 "${scriptsDir}/hot_memory.py" warm --project "${project}" && python3 "${scriptsDir}/hot_memory.py" get`,
            { timeout: 60000 },
            () => {}, // fire and forget
          );
        }
      }
    }

    return { allow: true };
  }

  // If hot memory has been read, check if prefetch also read
  if (hasReadHotMemory()) {
    if (!hasReadPrefetch()) {
      // Nudge ONCE after 3rd tool call, then stop. One clear reminder, not spam.
      const nudgeFlagPath = path.join(
        SESSION_FLAG_DIR,
        `prefetch-nudged-${getSessionId()}.flag`,
      );
      const alreadyNudged = fs.existsSync(nudgeFlagPath);
      const toolCountPath = path.join(
        SESSION_FLAG_DIR,
        `tool-count-${getSessionId()}.txt`,
      );

      let toolCount = 0;
      try {
        toolCount =
          parseInt(fs.readFileSync(toolCountPath, "utf8").trim()) || 0;
      } catch {}
      toolCount++;
      fs.mkdirSync(SESSION_FLAG_DIR, { recursive: true });
      fs.writeFileSync(toolCountPath, String(toolCount));

      if (!alreadyNudged && toolCount >= 3) {
        const prefetchPath = path.join(
          os.homedir(),
          ".claude",
          "context",
          "prefetched.md",
        );
        if (fs.existsSync(prefetchPath)) {
          fs.writeFileSync(nudgeFlagPath, new Date().toISOString());
          return {
            allow: true,
            additionalContext: `[MEMORY GATE] Read ~/.claude/context/prefetched.md — it has Qdrant semantic context for your current project. This is the only reminder.`,
          };
        }
      }
    }
    return { allow: true };
  }

  // Safety valve: after MAX_BLOCKS, stop blocking (prevents stuck sessions)
  const blockCount = incrementBlockCount();
  if (blockCount > MAX_BLOCKS) {
    // Give up blocking, but still inject reminder
    return {
      allow: true,
      additionalContext: `[MEMORY GATE WARNING] hot.md was NEVER read this session. Context may be missing. Feedback rules may be violated.`,
    };
  }

  // BLOCK non-read tools until hot.md is read
  const feedbackFiles = getFeedbackFiles();
  const feedbackList =
    feedbackFiles.length > 0
      ? `\nFeedback memories to read: ${feedbackFiles.map((f) => f.replace(".md", "")).join(", ")}`
      : "";

  return {
    allow: false,
    reason: `[MEMORY GATE] BLOCKED: You must read ~/.claude/context/hot.md BEFORE doing any work. Use the Read tool to load it now. Also read all feedback memories listed in MEMORY.md.${feedbackList}\n\nThis is block ${blockCount}/${MAX_BLOCKS} — after ${MAX_BLOCKS} blocks, the gate opens automatically.`,
  };
}
