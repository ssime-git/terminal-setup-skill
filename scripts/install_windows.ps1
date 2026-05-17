param(
  [switch]$SkipAudit,
  [switch]$DryRun,
  [switch]$NonInteractive,
  [switch]$Yes,
  [switch]$WithPowerShellBootstrap,
  [switch]$WithFonts,
  [string]$PlanMd = ""
)

$ErrorActionPreference = 'Stop'

function Ask-YesNo {
  param([string]$Prompt, [bool]$Default = $false)
  if ($Yes) { return $true }
  if ($NonInteractive) { return $Default }
  while ($true) {
    $reply = Read-Host "$Prompt [y/n]"
    switch ($reply.ToLower()) {
      'y' { return $true }
      'yes' { return $true }
      'n' { return $false }
      'no' { return $false }
      default { Write-Host 'Please answer y or n.' }
    }
  }
}

function Has-Cmd {
  param([string]$Name)
  return [bool](Get-Command $Name -ErrorAction SilentlyContinue)
}

function Invoke-OrPrint {
  param([string]$Command)
  Write-Host "→ $Command"
  if (-not $DryRun) {
    Invoke-Expression $Command
  }
}

function Detect-Installer {
  if (Has-Cmd 'winget') { return 'winget' }
  if (Has-Cmd 'choco') { return 'choco' }
  if (Has-Cmd 'scoop') { return 'scoop' }
  return 'manual'
}

function Install-WithWinget {
  param([string[]]$Ids)
  foreach ($id in $Ids) {
    Invoke-OrPrint "winget install --id $id --accept-package-agreements --accept-source-agreements"
  }
}

function Install-WithChoco {
  param([string[]]$Packages)
  foreach ($pkg in $Packages) {
    Invoke-OrPrint "choco install -y $pkg"
  }
}

function Install-WithScoop {
  param([string[]]$Packages)
  foreach ($pkg in $Packages) {
    Invoke-OrPrint "scoop install $pkg"
  }
}

function Install-NpmGlobal {
  param([string]$Package)
  Invoke-OrPrint "npm install -g $Package"
}

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RootDir = Split-Path -Parent $ScriptDir
$AuditScript = Join-Path $ScriptDir 'audit_env.py'
$BootstrapPwsh = Join-Path $ScriptDir 'bootstrap_powershell.ps1'
if (-not $PlanMd) {
  $PlanMd = Join-Path $RootDir 'output/install-plan-windows.md'
}

Write-Host '== Terminal Setup Installer (Windows) =='
$installer = Detect-Installer
Write-Host "Detected installer: $installer"
Write-Host 'Recommendation: prefer WSL for Zsh-first Unix workflows; use PowerShell 7 + Windows Terminal for native Windows workflows.'

if (-not $SkipAudit -and (Has-Cmd 'python')) {
  Write-Host ''
  Write-Host 'Current audit:'
  python $AuditScript
  if (-not $DryRun) {
    python $AuditScript --plan-md $PlanMd | Out-Null
    Write-Host "Markdown plan written to: $PlanMd"
  }
}

if ($WithFonts) {
  Write-Host ''
  Write-Host 'Nerd Font recommendation: JetBrainsMono Nerd Font in Windows Terminal.'
}

if ($installer -eq 'manual') {
  Write-Host 'No supported Windows package manager found (winget/choco/scoop).'
  exit 1
}

if (Ask-YesNo 'Install common prerequisites (Git, GitHub CLI, Node.js, Starship, uv, Ollama where available)?') {
  switch ($installer) {
    'winget' {
      Install-WithWinget @(
        'Git.Git',
        'GitHub.cli',
        'OpenJS.NodeJS.LTS',
        'Starship.Starship',
        'astral-sh.uv',
        'Ollama.Ollama'
      )
    }
    'choco' {
      Install-WithChoco @('git', 'gh', 'nodejs-lts', 'starship', 'uv', 'ollama')
    }
    'scoop' {
      Install-WithScoop @('git', 'gh', 'nodejs-lts', 'starship', 'uv', 'ollama')
    }
  }
}

if (Has-Cmd 'npm') {
  if (-not (Has-Cmd 'opencode')) {
    if (Ask-YesNo 'Install OpenCode CLI via npm?') {
      Install-NpmGlobal 'opencode-ai@latest'
    }
  }

  if (-not (Has-Cmd 'claude')) {
    if (Ask-YesNo 'Install Claude Code CLI via npm?') {
      Install-NpmGlobal '@anthropic-ai/claude-code'
    }
  }

  if (-not (Has-Cmd 'codex')) {
    if (Ask-YesNo 'Install OpenAI Codex CLI via npm?') {
      Install-NpmGlobal '@openai/codex'
    }
  }

  if (-not (Has-Cmd 'gemini')) {
    if (Ask-YesNo 'Install Gemini CLI via npm?') {
      Install-NpmGlobal '@google/gemini-cli'
    }
  }
}
else {
  Write-Host 'npm not found; skipping npm-based agent CLI installs.'
}

if (-not (Has-Cmd 'aider')) {
  if (Ask-YesNo 'Install Aider with uv tool install?') {
    if (Has-Cmd 'uv') {
      Invoke-OrPrint 'uv tool install aider-chat'
    }
    else {
      Write-Host 'uv not found; skipping aider.'
    }
  }
}

if (Ask-YesNo 'Hermes Agent is best installed inside WSL rather than directly on Windows. Skip native install?' $true) {
  Write-Host 'Skipping native Windows Hermes install.'
}

if ($WithPowerShellBootstrap) {
  if (Ask-YesNo 'Apply the PowerShell bootstrap scaffold?') {
    Invoke-OrPrint "powershell -ExecutionPolicy Bypass -File `"$BootstrapPwsh`""
  }
}

Write-Host ''
Write-Host 'Post-install notes:'
Write-Host '- Use Windows Terminal + Nerd Font for the best icon rendering.'
Write-Host '- Prefer WSL if you want Zsh + Unix-first shell workflows.'
Write-Host '- Run agent-specific login commands after install.'

if (Has-Cmd 'python') {
  Write-Host ''
  Write-Host '== Post-install verification =='
  python $AuditScript
  if (-not $DryRun) {
    python $AuditScript --plan-md $PlanMd | Out-Null
  }
}
