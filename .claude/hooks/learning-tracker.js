#!/usr/bin/env node
// Learning Tracker v2 — FULLY AUTOMATIC
//
// Principle: If the hook can't observe it, it doesn't get tracked.
// Claude is unreliable — 135 sessions, 0 manual tracking calls.
// So we track everything from hook observations alone.
//
// PostToolUse (this hook):
//   - On Read: record which memory files were read (= useful)
//   - On Read prefetched.md: extract all source files listed
//   - Track tool call count for session stats
//
// Stop hook (learning-gate.js):
//   - Diff: sources retrieved (from prefetched.md) vs sources read
//   - Retrieved but never read = auto-ignored
//   - Read during session = auto-useful
//   - Write stats to learning/retrieval-stats.json
//   - No blocking, no nagging — just auto-track

const fs = require('fs');
const os = require('os');
const path = require('path');

const SESSION_FLAG_DIR = path.join(os.tmpdir(), 'claude-memory-gate');
const PREFETCH_PATH = path.join(os.homedir(), '.claude', 'context', 'prefetched.md');
const MEMORY_BASE = path.join(os.homedir(), '.claude', 'projects', '-Users-vishal-motion', 'memory');
const LEARNING_DIR = path.join(os.homedir(), '.claude', 'context', 'learning');

let input = '';
process.stdin.setEncoding('utf8');
process.stdin.on('data', (chunk) => { input += chunk; });
process.stdin.on('end', () => {
  try {
    const data = JSON.parse(input);
    const result = handlePostToolUse(data);
    if (result) {
      process.stdout.write(JSON.stringify(result));
    }
  } catch (e) {
    // Silent fail — never break tool flow
    process.exit(0);
  }
});

function getSessionId() {
  const today = new Date().toISOString().split('T')[0];
  return `${today}-${process.ppid}`;
}

function getSessionState() {
  const stateFile = path.join(SESSION_FLAG_DIR, `learning-v2-${getSessionId()}.json`);
  try {
    if (fs.existsSync(stateFile)) {
      return JSON.parse(fs.readFileSync(stateFile, 'utf8'));
    }
  } catch {}
  return {
    toolCalls: 0,
    retrievedSources: [],  // Sources listed in prefetched.md
    readFiles: [],          // Memory files actually read during session
    prefetchRead: false,    // Whether prefetched.md was read
  };
}

function saveSessionState(state) {
  fs.mkdirSync(SESSION_FLAG_DIR, { recursive: true });
  const stateFile = path.join(SESSION_FLAG_DIR, `learning-v2-${getSessionId()}.json`);
  fs.writeFileSync(stateFile, JSON.stringify(state));
}

function extractSourcesFromPrefetch() {
  try {
    if (!fs.existsSync(PREFETCH_PATH)) return [];
    const content = fs.readFileSync(PREFETCH_PATH, 'utf8');
    const sources = [];
    const regex = /\*\*\[([^\]]+)\]\*\*/g;
    let match;
    while ((match = regex.exec(content)) !== null) {
      const source = match[1].trim();
      if (source && source !== 'unknown' && !sources.includes(source)) {
        sources.push(source);
      }
    }
    return sources;
  } catch {
    return [];
  }
}

function isMemoryFile(filePath) {
  // Check if a Read target is a memory system file
  return filePath.includes('.claude/projects/') ||
         filePath.includes('.claude/context/') ||
         filePath.includes('/memory/');
}

function normalizeSource(filePath) {
  // Normalize to relative path matching prefetched.md format
  if (filePath.includes(MEMORY_BASE)) {
    return filePath.replace(MEMORY_BASE + '/', '');
  }
  return path.basename(filePath);
}

function handlePostToolUse(data) {
  const toolName = data?.tool_name || data?.tool || '';
  const toolInput = data?.tool_input || {};
  const state = getSessionState();

  state.toolCalls = (state.toolCalls || 0) + 1;

  // Auto-track: when Claude reads a memory file, record it
  if (toolName === 'Read') {
    const filePath = toolInput?.file_path || '';

    // Track prefetched.md read — extract retrieved sources
    if (filePath.includes('prefetched.md')) {
      state.prefetchRead = true;
      const sources = extractSourcesFromPrefetch();
      state.retrievedSources = sources;
    }

    // Track any memory file read
    if (isMemoryFile(filePath)) {
      const normalized = normalizeSource(filePath);
      if (!state.readFiles.includes(normalized)) {
        state.readFiles.push(normalized);
      }
    }
  }

  saveSessionState(state);
  return null; // No output — silent tracking
}
