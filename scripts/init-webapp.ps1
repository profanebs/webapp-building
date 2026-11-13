#!/usr/bin/env pwsh
# init-webapp.ps1 - local Windows edition
# Usage:
#   init-webapp.ps1 --list
#   init-webapp.ps1 <project-dir> <project-title> [template-name] [--no-install]

$ErrorActionPreference = 'Stop'

$ScriptsDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot = Split-Path -Parent $ScriptsDir
$TemplatesDir = Join-Path $RepoRoot 'templates'
$OriginTemplateName = '0-origin'

function Show-Usage {
  Write-Host @"
Usage:
  init-webapp.ps1 --list
  init-webapp.ps1 <project-dir> <project-title> [template-name] [--no-install]

Examples:
  init-webapp.ps1 --list
  init-webapp.ps1 ./app "Market Dashboard"
  init-webapp.ps1 ./app "Gallery" airlens-style --no-install
"@
}

function Get-TemplateNames {
  Get-ChildItem -LiteralPath $TemplatesDir -Directory | Sort-Object Name | Select-Object -ExpandProperty Name
}

if (-not $args -or $args.Count -eq 0) { Show-Usage; exit 2 }
if ($args[0] -in @('--help', '-h')) { Show-Usage; exit 0 }
if ($args[0] -eq '--list') { Get-TemplateNames; exit 0 }
if ($args.Count -lt 2 -or $args.Count -gt 4) { Show-Usage; exit 2 }

$ProjectDir = $args[0]
$ProjectTitle = $args[1]
$InstallDeps = $true
if ($args -contains '--no-install') { $InstallDeps = $false }

$positional = @($args | Where-Object { $_ -ne '--no-install' })
if ($positional.Count -ge 3) { $TemplateName = $positional[2] } else { $TemplateName = $OriginTemplateName }

if (-not (Get-Command npm -ErrorAction SilentlyContinue)) {
  Write-Error 'npm not found (install Node.js 20+ first)'
  exit 1
}

$TemplatePath = Join-Path $TemplatesDir $TemplateName
$TemplateZip = Join-Path $TemplatePath "$TemplateName.zip"
$InfoMd = Join-Path $TemplatePath 'info.md'

if (-not (Test-Path -LiteralPath $TemplatePath -PathType Container) -or -not (Test-Path -LiteralPath $TemplateZip -PathType Leaf)) {
  Write-Error "Template '$TemplateName' not found at: $TemplateZip"
  Write-Host 'Available templates:'
  Get-TemplateNames | ForEach-Object { Write-Host "  $_" }
  exit 1
}

if (Test-Path -LiteralPath $ProjectDir) {
  $existing = Get-ChildItem -LiteralPath $ProjectDir -Force
  if ($existing) {
    Write-Error "Project directory already exists and is not empty: $ProjectDir"
    exit 1
  }
}

Write-Host "Creating project: $ProjectDir (template: $TemplateName)"
New-Item -ItemType Directory -Force -Path $ProjectDir | Out-Null
$ProjectDir = (Resolve-Path -LiteralPath $ProjectDir).Path

$TempPath = Join-Path ([IO.Path]::GetTempPath()) ('webapp-init-' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Force -Path $TempPath | Out-Null
try {
  Expand-Archive -LiteralPath $TemplateZip -DestinationPath $TempPath -Force

  $Candidate = Join-Path $TempPath $TemplateName
  if (Test-Path -LiteralPath $Candidate -PathType Container) {
    $SourceDir = $Candidate
  } else {
    $children = @(Get-ChildItem -LiteralPath $TempPath -Force)
    $dirs = @($children | Where-Object { $_.PSIsContainer })
    if ($dirs.Count -eq 1 -and $children.Count -eq 1) { $SourceDir = $dirs[0].FullName } else { $SourceDir = $TempPath }
  }

  Get-ChildItem -LiteralPath $SourceDir -Force | ForEach-Object {
    Copy-Item -LiteralPath $_.FullName -Destination $ProjectDir -Recurse -Force
  }

  if (Test-Path -LiteralPath $InfoMd) {
    Copy-Item -LiteralPath $InfoMd -Destination (Join-Path $ProjectDir 'template-info.md') -Force
  }

  $IndexHtml = Join-Path $ProjectDir 'index.html'
  if (Test-Path -LiteralPath $IndexHtml) {
    $text = [IO.File]::ReadAllText($IndexHtml)
    $escaped = [System.Net.WebUtility]::HtmlEncode($ProjectTitle)
    $text = [regex]::Replace($text, '<title>.*?</title>', "<title>$escaped</title>", [System.Text.RegularExpressions.RegexOptions]::Singleline)
    [IO.File]::WriteAllText($IndexHtml, $text, (New-Object System.Text.UTF8Encoding($false)))
  }

  $Gitignore = Join-Path $ProjectDir '.gitignore'
  if (-not (Test-Path -LiteralPath $Gitignore)) { New-Item -ItemType File -Path $Gitignore | Out-Null }
  $lines = @(Get-Content -LiteralPath $Gitignore -ErrorAction SilentlyContinue)
  if ($lines -notcontains 'node_modules') { Add-Content -LiteralPath $Gitignore -Value 'node_modules' }
  if ($lines -notcontains 'dist') { Add-Content -LiteralPath $Gitignore -Value 'dist' }

  if ($InstallDeps -and (Test-Path -LiteralPath (Join-Path $ProjectDir 'package.json'))) {
    Push-Location $ProjectDir
    try {
      Write-Host "Installing dependencies in: $ProjectDir"
      npm install --no-audit --no-fund
      if ($LASTEXITCODE -ne 0) { throw "npm install failed with exit code $LASTEXITCODE" }
    } finally { Pop-Location }
  }

  Write-Host ''
  Write-Host "Template '$TemplateName' initialized at: $ProjectDir"
  Write-Host ''
  Write-Host 'TEMPLATE INFO'
  if (Test-Path -LiteralPath $InfoMd) { Get-Content -LiteralPath $InfoMd } else { Write-Host 'No info.md found for this template.' }
} finally {
  Remove-Item -LiteralPath $TempPath -Recurse -Force -ErrorAction SilentlyContinue
}
