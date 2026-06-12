<#
  ============================================================================
  Claude Code - COMPLETE Windows mirror (one command)
  ----------------------------------------------------------------------------
  Reproduces the full working environment:
    - Toolchain: PowerShell 7, Git, Node LTS, Python, uv, ffmpeg, yt-dlp, jq, gh, ripgrep
    - Global packages: @anthropic-ai/sdk, codex, gemini-cli, firecrawl-cli, vercel,
      pnpm, yarn  +  pip: anthropic, openai-whisper, pillow, requests
    - Claude Code (official native installer; npm fallback)
    - ~/.claude mirror: CLAUDE.md, settings.json, rules/, memory/ (USER.md + 105
      feedback rules + reference notes), skills/ (figjam-board, video-inspo-extracter,
      reel-insights, transcript, youtube, design/qa/ship/gsd/ECC + more), commands/,
      agents/, scripts/ (Groq transcribe.sh + youtube_transcript.py), get-shit-done/
    - MCP servers registered (code-review-graph, figma-console)
    - Plugin marketplaces auto-install on first launch (everything-claude-code + official)
  Run from Windows PowerShell (5.1+):  irm <raw-url> | iex
  Idempotent. NO credentials included; set API keys yourself (printed at the end).
  ============================================================================
#>

$ErrorActionPreference = 'Continue'
$script:Failed = @()
$RepoUrl = 'https://github.com/vishalmotionwork-lang/claude-code-windows-setup.git'

function Step($m){ Write-Host "`n=== $m ===" -ForegroundColor Cyan }
function Ok($m){ Write-Host "  [ok]  $m" -ForegroundColor Green }
function Warn($m){ Write-Host "  [warn] $m" -ForegroundColor Yellow }
function Have($cmd){ return [bool](Get-Command $cmd -ErrorAction SilentlyContinue) }
function Refresh-Path {
  $m=[Environment]::GetEnvironmentVariable('Path','Machine')
  $u=[Environment]::GetEnvironmentVariable('Path','User')
  $env:Path=(($m,$u) -join ';')
}

Write-Host @"

  +--------------------------------------------------------------+
  |   Claude Code  -  COMPLETE Windows mirror                    |
  |   toolchain + packages + Claude Code + skills + memory       |
  +--------------------------------------------------------------+

"@ -ForegroundColor Magenta

if ($PSVersionTable.PSVersion.Major -lt 5) { Write-Host "Needs Windows PowerShell 5.1+." -ForegroundColor Red; return }

# ---------------------------------------------------------------------------
# Package manager
# ---------------------------------------------------------------------------
Step "Package manager"
$UseWinget = Have winget
$UseScoop  = $false
if ($UseWinget) { Ok "winget found" } else {
  Warn "winget missing - bootstrapping scoop (Homebrew-style, no admin)"
  try {
    if (-not (Have scoop)) {
      Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
      Invoke-RestMethod get.scoop.sh | Invoke-Expression; Refresh-Path
    }
    scoop bucket add main 2>$null | Out-Null; scoop bucket add extras 2>$null | Out-Null
    $UseScoop = Have scoop
    if ($UseScoop) { Ok "scoop ready" } else { Warn "scoop bootstrap failed" }
  } catch { Warn "scoop error: $($_.Exception.Message)" }
}

function Install-Tool { param([string]$Probe,[string]$WingetId,[string]$ScoopPkg,[string]$Label)
  if (Have $Probe) { Ok "$Label already installed"; return }
  Write-Host "  installing $Label ..." -ForegroundColor Gray
  try {
    if ($UseWinget -and $WingetId) {
      winget install --id $WingetId -e --source winget --accept-source-agreements --accept-package-agreements --silent 2>$null | Out-Null
    } elseif ($UseScoop -and $ScoopPkg) { scoop install $ScoopPkg 2>$null | Out-Null }
    else { Warn "no package manager for $Label"; $script:Failed += $Label; return }
    Refresh-Path
    if (Have $Probe) { Ok "$Label installed" } else { Warn "$Label installed - restart terminal for PATH" }
  } catch { Warn "$Label failed: $($_.Exception.Message)"; $script:Failed += $Label }
}

# ---------------------------------------------------------------------------
# Toolchain
# ---------------------------------------------------------------------------
Step "Toolchain"
Install-Tool pwsh   'Microsoft.PowerShell'    'pwsh'       'PowerShell 7'
Install-Tool git    'Git.Git'                 'git'        'Git'
Install-Tool node   'OpenJS.NodeJS.LTS'       'nodejs-lts' 'Node.js LTS'
Install-Tool python 'Python.Python.3.12'      'python'     'Python 3.12'
Install-Tool ffmpeg 'Gyan.FFmpeg'             'ffmpeg'     'ffmpeg'
Install-Tool yt-dlp 'yt-dlp.yt-dlp'           'yt-dlp'     'yt-dlp'
Install-Tool jq     'jqlang.jq'               'jq'         'jq'
Install-Tool gh     'GitHub.cli'              'gh'         'GitHub CLI'
Install-Tool rg     'BurntSushi.ripgrep.MSVC' 'ripgrep'    'ripgrep'

Step "uv (Python tool runner)"
if (Have uv) { Ok "uv already installed" } else {
  try { Invoke-RestMethod https://astral.sh/uv/install.ps1 | Invoke-Expression; Refresh-Path
        if (Have uv) { Ok "uv installed" } else { Warn "uv installed - restart terminal" } }
  catch { Warn "uv failed: $($_.Exception.Message)"; $script:Failed += 'uv' }
}

# ---------------------------------------------------------------------------
# Claude Code
# ---------------------------------------------------------------------------
Step "Claude Code"
if (Have claude) { Ok "claude already installed" } else {
  $done=$false
  try { Invoke-RestMethod https://claude.ai/install.ps1 | Invoke-Expression; Refresh-Path; $done=Have claude
        if ($done){ Ok "Claude Code installed (native)" } } catch { Warn "native installer failed: $($_.Exception.Message)" }
  if (-not $done) {
    Warn "falling back to npm"
    try { npm install -g '@anthropic-ai/claude-code' 2>$null | Out-Null; Refresh-Path
          if (Have claude){ Ok "Claude Code installed (npm)" } else { Warn "claude not on PATH - restart terminal" } }
    catch { Warn "npm install failed"; $script:Failed += 'Claude Code' }
  }
}

# ---------------------------------------------------------------------------
# Global packages (npm + pip)  - "all my packages"
# ---------------------------------------------------------------------------
Step "Global npm packages"
if (Have npm) {
  $npmPkgs = @('@anthropic-ai/sdk','@google/gemini-cli','@openai/codex','firecrawl-cli','vercel','pnpm','yarn')
  foreach ($p in $npmPkgs) {
    Write-Host "  npm -g $p" -ForegroundColor Gray
    try { npm install -g $p 2>$null | Out-Null } catch { Warn "npm $p failed" }
  }
  Refresh-Path; Ok "npm globals attempted (@anthropic-ai/sdk, codex, gemini-cli, firecrawl-cli, vercel, pnpm, yarn)"
} else { Warn "npm not on PATH yet - re-run after restarting terminal"; $script:Failed += 'npm globals' }

Step "Python packages (pip)"
if (Have python) {
  $pyPkgs = @('anthropic','openai-whisper','pillow','requests','requests-toolbelt')
  try { python -m pip install --quiet --upgrade $pyPkgs 2>$null | Out-Null; Ok "pip packages installed ($($pyPkgs -join ', '))" }
  catch { Warn "some pip packages failed (openai-whisper is large; retry later)" }
} else { Warn "python not on PATH yet - re-run after restarting terminal" }

# ---------------------------------------------------------------------------
# Clone the ~/.claude mirror (rules, memory, skills, commands, agents, scripts, GSD)
# ---------------------------------------------------------------------------
Step "~/.claude mirror (skills + commands + agents + scripts + rules + memory)"
if (-not (Have git)) { Warn "git not on PATH yet - restart terminal and re-run to get the mirror"; $script:Failed += 'mirror (git missing)' }
else {
  try {
    $claudeDir = Join-Path $env:USERPROFILE '.claude'
    New-Item -ItemType Directory -Force -Path $claudeDir | Out-Null
    $settings = Join-Path $claudeDir 'settings.json'
    if (Test-Path $settings) {
      $stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
      Copy-Item $settings "$settings.bak-$stamp" -Force
      Warn "backed up existing settings.json -> settings.json.bak-$stamp"
    }
    $tmp = Join-Path $env:TEMP ('claude-mirror-' + (Get-Random))
    git clone --depth 1 $RepoUrl $tmp 2>$null | Out-Null
    Copy-Item (Join-Path $tmp '.claude\*') $claudeDir -Recurse -Force
    Remove-Item $tmp -Recurse -Force -ErrorAction SilentlyContinue
    $sk = (Get-ChildItem (Join-Path $claudeDir 'skills') -Directory -ErrorAction SilentlyContinue | Measure-Object).Count
    $cm = (Get-ChildItem (Join-Path $claudeDir 'commands') -Filter '*.md' -ErrorAction SilentlyContinue | Measure-Object).Count
    $ag = (Get-ChildItem (Join-Path $claudeDir 'agents') -Filter '*.md' -ErrorAction SilentlyContinue | Measure-Object).Count
    $fb = (Get-ChildItem (Join-Path $claudeDir 'memory') -Filter 'feedback_*.md' -ErrorAction SilentlyContinue | Measure-Object).Count
    Ok "mirror placed: $sk skills, $cm commands, $ag agents, $fb feedback rules"
  } catch { Warn "mirror clone failed: $($_.Exception.Message)"; $script:Failed += 'mirror' }
}

# ---------------------------------------------------------------------------
# MCP servers (the scriptable, secret-free ones; HTTP/auth ones listed at end)
# ---------------------------------------------------------------------------
Step "MCP servers"
if (Have claude) {
  try { claude mcp add code-review-graph -- uvx code-review-graph serve 2>$null | Out-Null; Ok "code-review-graph registered" } catch { Warn "code-review-graph add skipped" }
  try { claude mcp add figma-console -- npx -y figma-console-mcp@latest 2>$null | Out-Null; Ok "figma-console registered" } catch { Warn "figma-console add skipped" }
} else { Warn "claude not ready - register MCP servers after restart" }

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------
Step "Done"
Refresh-Path
if ($script:Failed.Count -eq 0) { Write-Host "  Everything installed cleanly." -ForegroundColor Green }
else {
  Write-Host ("  Completed with warnings on: " + ($script:Failed -join ', ')) -ForegroundColor Yellow
  Write-Host "  Restart your terminal and run this command again to retry those." -ForegroundColor Yellow
}

Write-Host @"

  -------------------------------------------------------------------
  NEXT STEPS
  -------------------------------------------------------------------
  1) CLOSE and REOPEN your terminal (PATH refresh), then run:  claude
     - First launch auto-installs plugin marketplaces
       (everything-claude-code + official frontend-design/telegram).
     - Loads CLAUDE.md, USER.md, all 105 feedback rules, your skills/commands.
     - Sign in to Claude when prompted.

  2) SET YOUR API KEYS (none are bundled). In PowerShell, per key:
       setx GROQ_API_KEY      "gsk_..."     # transcribe.sh / Groq Whisper
       setx OPENAI_API_KEY    "sk-..."      # /codex skill
       setx GEMINI_API_KEY    "..."         # gemini-cli
       setx FIRECRAWL_API_KEY "fc-..."      # firecrawl skills
       setx CORE_TEAM_DB_URL  "postgresql://..."   # /bod /eod dashboard
     (reopen the terminal after setx so they take effect)

  3) FRAMEWORKS that need their own installer (not file-copyable):
     - gstack browser skills (browse/benchmark/canary/qa/ship live-test):
       the 396MB compiled browser daemon is macOS-built; on Windows install
       gstack per its own docs. All PROMPT skills already work from the mirror.
     - GSD (get-shit-done) is bundled; commands/skills load automatically.

  4) MCP servers needing sign-in (add when you want them):
       claude mcp add --transport http figma https://mcp.figma.com/mcp
       claude mcp add --transport http neon  https://mcp.neon.tech/mcp
       claude mcp add --transport http miro  https://mcp.miro.com
     (Gmail / Google Drive / Meta Ads are claude.ai-managed - sign in there.)

  Your setup lives in:  %USERPROFILE%\.claude
  No credentials were installed anywhere. Add per-project secrets locally.
  -------------------------------------------------------------------

"@ -ForegroundColor Cyan
