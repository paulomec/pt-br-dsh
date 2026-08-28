# install.ps1 - Instala pt-BR no DSH clonando do GitHub
# Uso: .\install.ps1 -DshPath "C:\Users\seuusuario\deepseek-harness"
# Ou sem argumentos: .\install.ps1

param(
  [string]$DshPath = '',
  [string]$Branch = 'main'
)

$ErrorActionPreference = 'Stop'
try { [Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($true) } catch { }

$githubRepo = 'https://github.com/paulomec/pt-br-dsh.git'
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$workDir = Join-Path $env:TEMP 'pt-br-dsh-install'
$patchPath = Join-Path $workDir 'pt-br.patch'

Write-Host "+----------------------------------------------+"
Write-Host "|  pt-br-dsh: instalação pelo GitHub          |"
Write-Host "+----------------------------------------------+"
Write-Host ""

# Step 0: Clone from GitHub
Write-Host "[1/4] Baixando do GitHub..." -ForegroundColor Cyan
if (Test-Path $workDir) { Remove-Item $workDir -Recurse -Force }
git clone --depth 1 --branch $Branch $githubRepo $workDir 2>&1
if (-not (Test-Path $patchPath)) {
  Write-Host "ERRO: patch não encontrado em $patchPath" -ForegroundColor Red
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
  Write-Host "ERRO: diretório DSH não encontrado em $DshPath" -ForegroundColor Red
  exit 1
}

# Step 2: Apply patch
Write-Host ""
Write-Host "[2/4] Aplicando patch..." -ForegroundColor Cyan
Push-Location $DshPath
try {
  git apply $patchPath 2>&1
  if ($LASTEXITCODE -ne 0) {
    Write-Host "Falha ao aplicar patch. Talvez já esteja aplicado." -ForegroundColor Red
    Pop-Location
    exit 1
  }
  Write-Host "  Patch aplicado." -ForegroundColor Green
} finally {
  Pop-Location
}

# Step 3: Install deps
Write-Host ""
Write-Host "[3/4] Instalando dependências..." -ForegroundColor Cyan
Push-Location $DshPath
try {
  pnpm install
  Write-Host "  Dependências instaladas." -ForegroundColor Green
} finally {
  Pop-Location
}

# Step 4: Build
Write-Host ""
Write-Host "[4/4] Fazendo build..." -ForegroundColor Cyan
Push-Location $DshPath
try {
  pnpm run build
  Write-Host ""
  Write-Host "+----------------------------------------------+"
  Write-Host "|  Instalação concluída!                       |"
  Write-Host "|                                              |"
  Write-Host "|  Para rodar: cd $DshPath                    |"
  Write-Host "|  pnpm dsh web                                 |"
  Write-Host "|                                              |"
  Write-Host "|  Selecione Português (BR) em:                |"
  Write-Host "|  Configurações > Geral > Idioma              |"
  Write-Host "+----------------------------------------------+"
} finally {
  Pop-Location
}