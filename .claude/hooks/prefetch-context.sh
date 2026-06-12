#!/bin/bash
# Session-start hook: Health check + Three-tier context loading + learning
#
# HEALTH CHECK (<200ms, blocking):
#   Redis alive? Qdrant index fresh? Context files valid?
#
# FAST PATH (Redis, <100ms, blocking):
#   Load USER.md + project files + feedback rules → write hot.md
#
# SLOW PATH (Qdrant + learning, ~10s, background):
#   Semantic search → write prefetched.md → warm Redis
#
# FIX 3: Output a system reminder that Claude MUST read hot.md before doing anything.
#   This appears as hook output in the conversation — impossible to miss.

# Ensure Homebrew tools are available (brew, redis-cli, uvx)
export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$HOME/.local/bin:$PATH"

SCRIPTS="$HOME/.claude/scripts"
CONTEXT_DIR="$HOME/.claude/context"
MEMORY_DIR="$HOME/.claude/projects/-Users-vishal-motion/memory"
LOG="$CONTEXT_DIR/prefetch.log"
QDRANT_DIR="$HOME/.qdrant-memory"

mkdir -p "$CONTEXT_DIR"

# ─── HEALTH CHECK (blocking, <200ms) ───
HEALTH_ISSUES=""

# Redis alive? Auto-restart if down.
if ! redis-cli ping &>/dev/null; then
    brew services start redis &>/dev/null
    sleep 1
    if redis-cli ping &>/dev/null; then
        HEALTH_ISSUES="${HEALTH_ISSUES}Redis was down — restarted successfully. "
    else
        # Second attempt: stop then start (handles corrupted state)
        brew services stop redis &>/dev/null 2>&1
        sleep 1
        brew services start redis &>/dev/null
        sleep 1
        if redis-cli ping &>/dev/null; then
            HEALTH_ISSUES="${HEALTH_ISSUES}Redis was stuck — hard-restarted successfully. "
        else
            HEALTH_ISSUES="${HEALTH_ISSUES}Redis FAILED to start after 2 attempts. Hot memory unavailable. "
        fi
    fi
fi

# Qdrant: clean stale .lock files (left behind by crashed sessions)
if [ -f "$QDRANT_DIR/.lock" ]; then
    # Check if the lock holder is still alive
    LOCK_HOLDER=$(lsof "$QDRANT_DIR/.lock" 2>/dev/null | tail -1 | awk '{print $2}')
    if [ -z "$LOCK_HOLDER" ]; then
        # No process holds this lock — it's orphaned. Remove regardless of age.
        rm -f "$QDRANT_DIR/.lock"
        HEALTH_ISSUES="${HEALTH_ISSUES}Orphaned Qdrant lock removed (no holder). "
    fi
fi

# Qdrant index: check staleness by both file changes AND age
if [ -d "$QDRANT_DIR/collection" ]; then
    META_FILE="$QDRANT_DIR/meta.json"
    if [ -f "$META_FILE" ]; then
        INDEX_AGE_SEC=$(( $(date +%s) - $(stat -f %m "$META_FILE" 2>/dev/null || echo 0) ))
        NEWEST_MEMORY=$(find "$MEMORY_DIR" -name "*.md" -newer "$META_FILE" 2>/dev/null | head -1)
        if [ -n "$NEWEST_MEMORY" ]; then
            HEALTH_ISSUES="${HEALTH_ISSUES}Qdrant index stale (new memory files exist). "
        elif [ "$INDEX_AGE_SEC" -gt 86400 ]; then
            HEALTH_ISSUES="${HEALTH_ISSUES}Qdrant index old ($(( INDEX_AGE_SEC / 3600 ))h). Consider re-indexing. "
        fi
    else
        HEALTH_ISSUES="${HEALTH_ISSUES}Qdrant meta.json missing. Run indexer outside Claude Code. "
    fi
else
    HEALTH_ISSUES="${HEALTH_ISSUES}Qdrant not indexed. Run indexer outside Claude Code. "
fi

# Write health status
if [ -n "$HEALTH_ISSUES" ]; then
    echo "<!-- Health: $HEALTH_ISSUES -->" > "$CONTEXT_DIR/health.txt"
    echo "[hot] Health: $HEALTH_ISSUES"
else
    rm -f "$CONTEXT_DIR/health.txt"
fi

# ─── FAST: Redis hot memory (blocking) ───
python3 "$SCRIPTS/hot_memory.py" hook 2>"$LOG.hot"

# ─── Collect feedback memory filenames ───
FEEDBACK_FILES=$(ls "$MEMORY_DIR"/feedback_*.md 2>/dev/null | xargs -I{} basename {} .md | sed 's/^/  - /' | head -20)
FEEDBACK_COUNT=$(ls "$MEMORY_DIR"/feedback_*.md 2>/dev/null | wc -l | tr -d ' ')

# ─── FIX 3: Output mandatory context loading reminder ───
# This appears as hook output in the conversation — Claude sees it directly
HOT_STATUS="not found"
if [ -f "$CONTEXT_DIR/hot.md" ]; then
    HOT_STATUS="ready"
fi

PREFETCH_STATUS="pending (background, ~6s)"
if [ -f "$CONTEXT_DIR/prefetched.md" ]; then
    PREFETCH_STATUS="ready"
fi

echo "[hot] Hot memory: ${HOT_STATUS} | Prefetch: ${PREFETCH_STATUS}"
echo "[hot] MANDATORY: Read ~/.claude/context/hot.md BEFORE responding to user"
echo "[hot] MANDATORY: Read ${FEEDBACK_COUNT} feedback memories BEFORE touching any code"
if [ -n "$FEEDBACK_FILES" ]; then
    echo "[hot] Feedback rules:"
    echo "$FEEDBACK_FILES"
fi
echo "[hot] Learning loop + project switch: AUTOMATED via hooks (no manual commands needed)"

# Clear any previous session's memory-gate flag
rm -f /tmp/claude-memory-gate/hot-read-*.flag 2>/dev/null

# ─── SLOW: Qdrant + learning (background) ───
(
    python3 "$SCRIPTS/learning_loop.py" session-start 2>>"$LOG.hot"

    # Auto re-index if stale (new memory files since last index)
    META_FILE="$QDRANT_DIR/meta.json"
    if [ -f "$META_FILE" ]; then
        NEWEST_MEMORY=$(find "$MEMORY_DIR" -name "*.md" -newer "$META_FILE" 2>/dev/null | head -1)
        if [ -n "$NEWEST_MEMORY" ] && ! lsof "$QDRANT_DIR/.lock" &>/dev/null 2>&1; then
            echo "[reindex] Stale index detected — re-indexing in background" >> "$LOG"
            uvx --with qdrant-client --with sentence-transformers \
                python3 "$SCRIPTS/index_memory_to_qdrant.py" --force \
                >> "$LOG" 2>&1
        fi
    fi

    uvx --with qdrant-client --with sentence-transformers \
        python3 "$SCRIPTS/prefetch_context.py" --hook \
        > "$LOG" 2>&1

    python3 "$SCRIPTS/hot_memory.py" warm 2>>"$LOG.hot"
    python3 "$SCRIPTS/hot_memory.py" get 2>>"$LOG.hot"
) &
