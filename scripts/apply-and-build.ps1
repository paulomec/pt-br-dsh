# apply-and-build.ps1 — Aplica o patch pt-BR e faz build do DSH
# Uso: .\scripts\apply-and-build.ps1 -DshPath "C:\Users\seuusuario\deepseek-harness"
# Ou sem argumentos (procura o DSH no diretório irmão): .\scripts\apply-and-build.ps1

param(
  [string]$DshPath = ''
)

$ErrorActionPreference = 'Stop'
try { [Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($true) } catch { }
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$projDir  = Split-Path -Parent $scriptDir
$patchFile = Join-Path $projDir 'pt-br.patch'

if (-not (Test-Path $patchFile)) {
  Write-Host "ERRO: pt-br.patch não encontrado em $patchFile" -ForegroundColor Red
  exit 1
}

# Resolve DSH path
if ($DshPath -eq '') {
  # Procura no diretório irmão: ../deepseek-harness
  $sibling = Join-Path (Split-Path $projDir -Parent) 'deepseek-harness'
  if (Test-Path $sibling) { $DshPath = $sibling }
  else {
    Write-Host "ERRO: especifique o caminho do DSH com -DshPath" -ForegroundColor Red
    exit 1
  }
}

if (-not (Test-Path $DshPath)) {
  Write-Host "ERRO: diretório DSH não encontrado em $DshPath" -ForegroundColor Red
  exit 1
}

Write-Host "╔════════════════════════════════════════════╗"
Write-Host "║  pt-br-dsh: aplicando e buildando           ║"
Write-Host "╚════════════════════════════════════════════╝"
Write-Host ""

# Step 1: Apply patch
Write-Host "[1/3] Aplicando patch pt-BR..." -ForegroundColor Cyan
Push-Location $DshPath
try {
  $result = git apply $patchFile 2>&1
  if ($LASTEXITCODE -ne 0) {
    Write-Host "Falha ao aplicar patch:" -ForegroundColor Red
    Write-Host $result
    Pop-Location
    exit 1
  }
  Write-Host "  Patch aplicado com sucesso." -ForegroundColor Green
} finally {
  Pop-Location
}

# Step 2: Install deps
Write-Host ""
Write-Host "[2/3] Instalando dependências..." -ForegroundColor Cyan
Push-Location $DshPath
try {
  pnpm install
  Write-Host "  Dependências instaladas." -ForegroundColor Green
} finally {
  Pop-Location
}

# Step 3: Build
Write-Host ""
Write-Host "[3/3] Fazendo build..." -ForegroundColor Cyan
Push-Location $DshPath
try {
  pnpm run build
  Write-Host ""
  Write-Host "╔════════════════════════════════════════════╗"
  Write-Host "║  Build concluído com sucesso!                ║"
  Write-Host "║                                              ║"
  Write-Host "║  Para rodar: cd $DshPath                    ║"
  Write-Host "║  pnpm dsh web                                 ║"
  Write-Host "║                                              ║"
  Write-Host "║  Depois selecione Português (BR) em          ║"
  Write-Host "║  Configurações > Geral > Idioma              ║"
  Write-Host "╚════════════════════════════════════════════╝"
  Write-Host ""
} finally {
  Pop-Location
}
