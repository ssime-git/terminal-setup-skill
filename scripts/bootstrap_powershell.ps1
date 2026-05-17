param(
  [switch]$Force
)

$ErrorActionPreference = 'Stop'

$ConfigHome = if ($env:XDG_CONFIG_HOME) { $env:XDG_CONFIG_HOME } else { Join-Path $HOME '.config' }
$PwshDir = Join-Path $ConfigHome 'powershell'
$ProfilePath = $PROFILE.CurrentUserCurrentHost
$ProfileDir = Split-Path -Parent $ProfilePath
$StarshipConfig = Join-Path $PwshDir 'starship.toml'

function Write-IfMissing {
  param(
    [string]$Path,
    [string]$Content
  )

  if ((Test-Path $Path) -and (-not $Force)) {
    Write-Host "skip: $Path already exists"
    return
  }

  $parent = Split-Path -Parent $Path
  if ($parent) {
    New-Item -ItemType Directory -Force -Path $parent | Out-Null
  }
  Set-Content -Path $Path -Value $Content -Encoding utf8
  Write-Host "written: $Path"
}

New-Item -ItemType Directory -Force -Path $PwshDir | Out-Null
New-Item -ItemType Directory -Force -Path $ProfileDir | Out-Null

$profileContent = @"
`$env:XDG_CONFIG_HOME = if (`$env:XDG_CONFIG_HOME) { `$env:XDG_CONFIG_HOME } else { Join-Path `$HOME '.config' }
`$env:STARSHIP_CONFIG = Join-Path `$env:XDG_CONFIG_HOME 'powershell/starship.toml'

if (Get-Command starship -ErrorAction SilentlyContinue) {
  Invoke-Expression (& starship init powershell)
}

if (Get-Command zoxide -ErrorAction SilentlyContinue) {
  Invoke-Expression (&zoxide init powershell | Out-String)
}

function ll { eza --icons -lh }
function la { eza --icons -lha }
function tree { eza --icons --tree }

Set-Alias grep rg -ErrorAction SilentlyContinue
Set-Alias cat bat -ErrorAction SilentlyContinue
"@

$starshipContent = @"
add_newline = false
format = "`$directory`$git_branch`$git_status`$python`$nodejs`$character"

[directory]
style = "blue bold"

[git_branch]
symbol = " "
style = "purple bold"

[git_status]
style = "red bold"

[python]
symbol = " "
style = "yellow"

[nodejs]
symbol = " "
style = "green"

[character]
success_symbol = "[❯](bold green)"
error_symbol = "[❯](bold red)"
"@

Write-IfMissing -Path $ProfilePath -Content $profileContent
Write-IfMissing -Path $StarshipConfig -Content $starshipContent

Write-Host ''
Write-Host "PowerShell bootstrap ready."
Write-Host "Reload with: . `$PROFILE"
Write-Host "For icons, use a Nerd Font in Windows Terminal or your PowerShell host."
