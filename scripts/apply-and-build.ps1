# apply-and-build.ps1 â€” Aplica o patch pt-BR e faz build do DSH
# Uso: .\scripts\apply-and-build.ps1 -DshPath "C:\Users\seuusuario\deepseek-harness"
# Ou sem argumentos (procura o DSH no diretÃ³rio irmÃ£o): .\scripts\apply-and-build.ps1

param(
  [string]$DshPath = ''
)

$ErrorActionPreference = 'Stop'
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$projDir  = Split-Path -Parent $scriptDir
$patchFile = Join-Path $projDir 'pt-br.patch'

if (-not (Test-Path $patchFile)) {
  Write-Host "ERRO: pt-br.patch nÃ£o encontrado em $patchFile" -ForegroundColor Red
  exit 1
}

# Resolve DSH path
if ($DshPath -eq '') {
  # Procura no diretÃ³rio irmÃ£o: ../deepseek-harness
  $sibling = Join-Path (Split-Path $projDir -Parent) 'deepseek-harness'
  if (Test-Path $sibling) { $DshPath = $sibling }
  else {
    Write-Host "ERRO: especifique o caminho do DSH com -DshPath" -ForegroundColor Red
    exit 1
  }
}

if (-not (Test-Path $DshPath)) {
  Write-Host "ERRO: diretÃ³rio DSH nÃ£o encontrado em $DshPath" -ForegroundColor Red
  exit 1
}

Write-Host "â•”â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•—"
Write-Host "â•‘  pt-br-dsh: aplicando e buildando           â•‘"
Write-Host "â•šâ•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•"
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
Write-Host "[2/3] Instalando dependÃªncias..." -ForegroundColor Cyan
Push-Location $DshPath
try {
  pnpm install
  Write-Host "  DependÃªncias instaladas." -ForegroundColor Green
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
  Write-Host "â•”â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•—"
  Write-Host "â•‘  Build concluÃ­do com sucesso!                â•‘"
Write-Host "â•‘                                              â•‘"
  Write-Host "â•‘  Para rodar: cd $DshPath                    â•‘"
  Write-Host "â•‘  pnpm dsh web                                 â•‘"
  Write-Host "â•‘                                              â•‘"
  Write-Host "â•‘  Depois selecione PortuguÃªs (BR) em          â•‘"
  Write-Host "â•‘  ConfiguraÃ§Ãµes > Geral > Idioma              â•‘"
  Write-Host "â•šâ•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•"
  Write-Host ""
} finally {
  Pop-Location
}
