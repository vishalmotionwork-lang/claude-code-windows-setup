# paste-video-win.ps1 — put a media file on the Windows clipboard and paste it into
# Figma Desktop, triggering Figma's NATIVE importer -> a real playable MEDIA node.
#
# WHY: identical to paste-video-mac.sh, for Windows. The Figma plugin API cannot create
# a playable video MEDIA node from bytes; a real OS paste hits Figma's own importer.
# See reference/PASTE-AUTOMATION.md.
#
# REQUIREMENTS:
#   - Windows, Figma Desktop running with the target file open and FOCUSED.
#   - PowerShell 5+ (Set-Clipboard -Path supported).
#
# USAGE:  powershell -ExecutionPolicy Bypass -File scripts\paste-video-win.ps1 -File <path> [-Delay 600]
#   Orchestrator (Claude via the figma-console bridge) does the same 3 steps as macOS:
#     1) snapshot existing MEDIA node ids, 2) call this, 3) poll new MEDIA -> place it.
param(
  [Parameter(Mandatory=$true)][string]$File,
  [int]$Delay = 600
)

if (-not (Test-Path -LiteralPath $File)) { Write-Error "no file: $File"; exit 1 }
$abs = (Resolve-Path -LiteralPath $File).Path

# put the FILE (as a file drop, not its bytes) on the clipboard
Set-Clipboard -LiteralPath $abs

# bring Figma to the foreground, then send Ctrl+V
Add-Type -AssemblyName System.Windows.Forms
$wshell = New-Object -ComObject WScript.Shell
# Figma desktop main window title contains "Figma"; AppActivate matches on substring.
$activated = $wshell.AppActivate("Figma")
if (-not $activated) { Write-Warning "Could not focus a 'Figma' window - is Figma Desktop open?" }
Start-Sleep -Milliseconds $Delay
[System.Windows.Forms.SendKeys]::SendWait("^v")

Write-Output "pasted: $abs"
