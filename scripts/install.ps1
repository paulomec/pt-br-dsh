# install.ps1 - Instala pt-BR no DSH clonando do GitHub
# Uso: .\install.ps1 -DshPath "C:\Users\seuusuario\deepseek-harness"
# Ou sem argumentos: .\install.ps1

param(
  [string]$DshPath = '',
  [string]$Branch = 'main'
)

# Continue em vez de Stop: comandos nativos (git/pnpm) escrevem em stderr e com Stop viram erro fatal
$ErrorActionPreference = 'Continue'
try { [Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($true) } catch { }

$githubRepo = 'https://github.com/paulomec/pt-br-dsh.git'
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$workDir = Join-Path $env:TEMP 'pt-br-dsh-install'
$patchPath = Join-Path $workDir 'pt-br.patch'

Write-Host "+----------------------------------------------+"
Write-Host "|  pt-br-dsh: instalacao pelo GitHub           |"
Write-Host "+----------------------------------------------+"
Write-Host ""

# Step 0: Clone from GitHub
Write-Host "[1/4] Baixando do GitHub..." -ForegroundColor Cyan
if (Test-Path $workDir) { Remove-Item $workDir -Recurse -Force }
& git clone --depth 1 --branch $Branch $githubRepo $workDir 2>$null
if ($LASTEXITCODE -ne 0 -or -not (Test-Path $patchPath)) {
  Write-Host "ERRO: falha ao clonar ou patch nao encontrado em $patchPath" -ForegroundColor Red
  exit 1
}
Write-Host "  Patch baixado." -ForegroundColor Green

# Step 1: Resolve DSH path
if ($DshPath -eq '') {
  $sibling = Join-Path (Split-Path $PWD -Parent) 'deepseek-harness'
  if (Test-Path $sibling) { $DshPath = $sibling }
  else {
    Write-Host "ERRO: especifique o caminho do DSH com -DshPath" -ForegroundColor Red
    exit 1
  }
}

if (-not (Test-Path $DshPath)) {
  Write-Host "ERRO: diretorio DSH nao encontrado em $DshPath" -ForegroundColor Red
  exit 1
}

# Step 2: Apply patch
Write-Host ""
Write-Host "[2/4] Aplicando patch..." -ForegroundColor Cyan
Push-Location $DshPath
try {
  & git apply $patchPath 2>$null
  if ($LASTEXITCODE -ne 0) {
    Write-Host "Falha ao aplicar patch. Talvez ja esteja aplicado." -ForegroundColor Red
    Pop-Location
    exit 1
  }
  Write-Host "  Patch aplicado." -ForegroundColor Green
} finally {
  if ((Get-Location).Path -ne $DshPath) { Pop-Location -ErrorAction SilentlyContinue }
  else { Pop-Location }
}

# Step 3: Install deps
Write-Host ""
Write-Host "[3/4] Instalando dependencias..." -ForegroundColor Cyan
Push-Location $DshPath
try {
  & pnpm install
  if ($LASTEXITCODE -ne 0) { Write-Host "Falha no pnpm install" -ForegroundColor Red; exit 1 }
  Write-Host "  Dependencias instaladas." -ForegroundColor Green
} finally {
  Pop-Location
}

# Step 4: Build
Write-Host ""
Write-Host "[4/4] Fazendo build..." -ForegroundColor Cyan
Push-Location $DshPath
try {
  & pnpm run build
  if ($LASTEXITCODE -ne 0) { Write-Host "Falha no build" -ForegroundColor Red; exit 1 }
  Write-Host ""
  Write-Host "+----------------------------------------------+"
  Write-Host "|  Instalacao concluida!                       |"
  Write-Host "|                                              |"
  Write-Host "|  Para rodar: cd $DshPath                    |"
  Write-Host "|  pnpm dsh web                                 |"
  Write-Host "|                                              |"
  Write-Host "|  Selecione Portugues (BR) em:                |"
  Write-Host "|  Configuracoes > Geral > Idioma              |"
  Write-Host "+----------------------------------------------+"
} finally {
  Pop-Location
}
