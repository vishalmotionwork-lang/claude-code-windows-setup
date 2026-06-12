#!/usr/bin/env node
// Learning Gate v2 — AUTOMATIC tracking at session end
//
// When session ends:
// 1. Read the session state (what was retrieved vs what was read)
// 2. Auto-mark: retrieved + read = useful, retrieved + NOT read = ignored
// 3. Write to retrieval-stats.json via learning_loop.py
// 4. NEVER block session end — just track silently
//
// This replaces the old "nag Claude to run commands" approach.
// 135 sessions with 0 manual calls proved that doesn't work.

const fs = require('fs');
const os = require('os');
const path = require('path');
const { execSync } = require('child_process');

const SESSION_FLAG_DIR = path.join(os.tmpdir(), 'claude-memory-gate');
const SCRIPTS_DIR = path.join(os.homedir(), '.claude', 'scripts');

let input = '';
process.stdin.setEncoding('utf8');
process.stdin.on('data', (chunk) => { input += chunk; });
process.stdin.on('end', () => {
  try {
    const data = JSON.parse(input);
    handleStop(data);
    // Always allow stop — never block
    console.log(JSON.stringify({}));
  } catch (e) {
    console.log(JSON.stringify({}));
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
  return null;
}

function handleStop(data) {
  const state = getSessionState();
  if (!state) return;

  // Skip very short sessions
  if ((state.toolCalls || 0) < 5) return;

  const retrieved = state.retrievedSources || [];
  const read = state.readFiles || [];

  if (retrieved.length === 0 && read.length === 0) return;

  // Auto-classify: retrieved + read = useful, retrieved + NOT read = ignored
  const useful = [];
  const ignored = [];

  for (const source of retrieved) {
    const wasRead = read.some(r =>
      r.includes(source) || source.includes(r) ||
      path.basename(r) === path.basename(source)
    );
    if (wasRead) {
      useful.push(source);
    } else {
      ignored.push(source);
    }
  }

  // Memory files read directly (not from prefetch) = also useful
  for (const readFile of read) {
    const wasRetrieved = retrieved.some(s =>
      readFile.includes(s) || s.includes(readFile) ||
      path.basename(readFile) === path.basename(s)
    );
    if (!wasRetrieved && !useful.includes(readFile)) {
      useful.push(readFile);
    }
  }

  // Write tracking data via learning_loop.py
  for (const source of useful) {
    try {
      execSync(
        `python3 "${SCRIPTS_DIR}/learning_loop.py" track-useful --source "${source}" --query "auto-tracked"`,
        { timeout: 5000, stdio: 'ignore' }
      );
    } catch {}
  }

  for (const source of ignored) {
    try {
      execSync(
        `python3 "${SCRIPTS_DIR}/learning_loop.py" track-ignored --source "${source}" --query "auto-tracked"`,
        { timeout: 5000, stdio: 'ignore' }
      );
    } catch {}
  }

  // Log summary
  try {
    const logDir = path.join(os.homedir(), '.claude', 'context', 'logs');
    const today = new Date().toISOString().split('T')[0];
    const summary = `- learning: ${useful.length} useful, ${ignored.length} ignored (auto-tracked)\n`;
    fs.appendFileSync(path.join(logDir, `${today}.md`), summary);
  } catch {}
}
