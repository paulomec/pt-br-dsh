param(
  [string]$DshPath = '',
  [string]$Branch  = 'main',
  [string]$PatchPath = '',
  [switch]$WhatIf,
  [switch]$Force,
  [switch]$NoRebuild,
  [switch]$Purge
)

# Continua em vez de Stop: este script depende quase que inteiramente de
# comandos nativos (git/pnpm) cujo codigo de saida e verificado via $LASTEXITCODE.
$ErrorActionPreference = 'Continue'
try { [Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($true) } catch { }

$githubRepo = 'https://raw.githubusercontent.com/paulomec/pt-br-dsh'
$scriptDir  = Split-Path -Parent $MyInvocation.MyCommand.Path
$projDir    = Split-Path -Parent $scriptDir

# 1) Resolve o patch: local primeiro, senao baixa do GitHub
if ([string]::IsNullOrWhiteSpace($PatchPath)) {
  $localPatch = Join-Path $projDir 'pt-br.patch'
  if (Test-Path $localPatch) {
    $PatchPath = $localPatch
  } else {
    $PatchPath = Join-Path $env:TEMP 'pt-br-dsh-uninstall.patch'
    Write-Host "[*] Baixando patch do GitHub (branch=$Branch)..." -ForegroundColor Cyan
    Invoke-WebRequest "$githubRepo/$Branch/pt-br.patch" -OutFile $PatchPath
  }
}
if (-not (Test-Path $PatchPath)) {
  Write-Host "ERRO: patch nao encontrado em $PatchPath" -ForegroundColor Red
  exit 1
}

# 2) Resolve diretorio DSH e valida git
if ([string]::IsNullOrWhiteSpace($DshPath)) {
  $sibling = Join-Path (Split-Path $projDir -Parent) 'deepseek-harness'
  if (Test-Path $sibling) { $DshPath = $sibling }
  else {
    Write-Host "ERRO: especifique o caminho do DSH com -DshPath" -ForegroundColor Red
    exit 1
  }
}
if (-not (Test-Path (Join-Path $DshPath '.git'))) {
  Write-Host "ERRO: $DshPath nao parece ser um repo git do DSH" -ForegroundColor Red
  exit 1
}

# 3) Extrai caminhos do patch (lado a/) e conta
$patchPaths = Select-String -Path $PatchPath -Pattern '^diff --git a/' |
  ForEach-Object { [regex]::Match($_.Line, '^diff --git a/(.+?) b/').Groups[1].Value }
if (-not $patchPaths) {
  Write-Host "ERRO: nao foi possivel extrair caminhos do patch" -ForegroundColor Red
  exit 1
}
$fileCount = $patchPaths.Count

Write-Host "+--------------------------------------------+"
Write-Host "|  pt-br-dsh: desinstalando / revertendo      |"
Write-Host "+--------------------------------------------+"
Write-Host ""
Write-Host "DSH target : $DshPath"
Write-Host "Patch      : $PatchPath"
Write-Host "Arquivos   : $fileCount (cirurgico - nao toca em outros)"

# 4) Detecta se o patch esta aplicado e se ha orfao pt.ts
$ptRel   = 'packages/client/locale/src/locales/pt.ts'
$ptFull  = Join-Path $DshPath $ptRel
$orphanPt = $false
if (Test-Path $ptFull) {
  $trackedOut = & git -C $DshPath ls-files -- $ptRel 2>$null
  if ([string]::IsNullOrWhiteSpace($trackedOut)) { $orphanPt = $true }
}

$applied = $false
$null = (& git -C $DshPath apply --reverse --check $PatchPath 2>$null)
if ($LASTEXITCODE -eq 0) { $applied = $true }

# 5) WhatIf: apenas lista
if ($WhatIf) {
  Write-Host ""
  Write-Host "[WhatIf] O que seria feito:" -ForegroundColor Yellow
  if ($applied)  { Write-Host "  - git apply --reverse  (reverte $fileCount arquivos rastreados)" }
  else           { Write-Host "  - (patch ja revertido - nada a reverter)" }
  if ($orphanPt) {
    if ($Purge)  { Write-Host "  - Remove-Item $ptRel  (-Purge: orfao nao rastreado)" }
    else         { Write-Host "  - pt.ts orfao permanece (use -Purge para remover)" }
  }
  if (-not $NoRebuild) { Write-Host "  - pnpm run build   (regenera lib/)" } else { Write-Host "  - build pulado (-NoRebuild)" }
  exit 0
}

# 6) Nada a fazer?
if (-not $applied -and -not $orphanPt) {
  Write-Host ""
  Write-Host "Nada a desinstalar: patch ja revertido e nao ha orfao pt.ts." -ForegroundColor Green
  exit 0
}

# 7) Confirmacao (a menos -Force)
if (-not $Force) {
  Write-Host ""
  Write-Host "Isso reverte as traducoes pt-BR do DSH em '$DshPath'." -ForegroundColor Yellow
  Write-Host "Arquivos externos ao patch (ex.: node_modules, pnpm-lock.yaml, cordis.yml) NAO sao tocados."
  $confirm = Read-Host "Confirmar desinstalacao? (s/n)"
  if ($confirm -notin @('s','S','sim','y','Y','yes')) {
    Write-Host "Cancelado." -ForegroundColor Yellow
    exit 0
  }
}

# 8) Passo 1 - reverter o patch
Write-Host ""
Write-Host "[1/3] Revertendo patch..." -ForegroundColor Cyan
if ($applied) {
  & git -C $DshPath apply --reverse $PatchPath 2>$null
  if ($LASTEXITCODE -ne 0) {
    Write-Host "  git apply --reverse falhou (arvore modificada apos aplicacao). Usando fallback..." -ForegroundColor DarkYellow
    & git -C $DshPath checkout HEAD -- @patchPaths 2>$null
    if ($LASTEXITCODE -ne 0) { Write-Host "FALHA: nao foi possivel reverter os arquivos do patch" -ForegroundColor Red; exit 1 }
  }
  Write-Host "  $fileCount arquivos revertidos para o estado original do DSH." -ForegroundColor Green
} else {
  Write-Host "  Patch ja revertido - nada a reverter." -ForegroundColor Green
}

# 8b) Verifica que a reversao foi concluida (arquivos de volta ao ingles/HEAD).
#     Evita estado parcial (ex.: worktree revertido mas indice falhou). Em
#     ambiente normal git apply --reverse e checkout sao atomicos; este e
#     um fail-safe que falha antes de seguir para o build.
& git -C $DshPath apply --check $PatchPath 2>$null
if ($LASTEXITCODE -ne 0) {
  Write-Host "ERRO: a reversao nao foi concluida com sucesso (arquivos inconsistentes)." -ForegroundColor Red
  Write-Host "  Corrija manualmente:" -ForegroundColor Yellow
  Write-Host "  git -C "$DshPath" checkout HEAD -- packages/client" -ForegroundColor DarkYellow
  Write-Host "  git -C "$DshPath" apply "$PatchPath"" -ForegroundColor DarkYellow
  exit 1
}
Write-Host "  Verificado: patch reaplicavel ao ingles (reversao concluida)." -ForegroundColor Green

# 9) Passo 2 - orfao pt.ts (so remove se -Purge e nao for rastreado)
Write-Host ""
Write-Host "[2/3] Verificando orfao pt.ts..." -ForegroundColor Cyan
if ($orphanPt) {
  if ($Purge) {
    Remove-Item $ptFull -Force
    Write-Host "  Removido orfao nao rastreado: $ptRel (-Purge)" -ForegroundColor Green
  } else {
    Write-Host "  pt.ts orfao permanece (nao e gerenciado pelo patch). Use -Purge para remover." -ForegroundColor DarkYellow
  }
} else {
  Write-Host "  Sem orfao pt.ts para remover (nao existe ou e rastreado - mantido)." -ForegroundColor Green
}

# 10) Passo 3 - rebuild opcional
Write-Host ""
Write-Host "[3/3] Build..." -ForegroundColor Cyan
if ($NoRebuild) {
  Write-Host "  Pulado (-NoRebuild). Para gerar lib/: cd $DshPath; pnpm run build" -ForegroundColor DarkYellow
} else {
  Write-Host "  Executando pnpm run build (pode levar alguns minutos)..."
  Push-Location $DshPath
  try {
    & pnpm run build 2>&1
    if ($LASTEXITCODE -ne 0) { Write-Host "  AVISO: build retornou nao-zero, mas a fonte ja foi revertida." -ForegroundColor DarkYellow }
    else { Write-Host "  Build concluido - lib/ regenerada sem pt-BR." -ForegroundColor Green }
  } finally { Pop-Location }
}

Write-Host ""
Write-Host "+--------------------------------------------+"
Write-Host "|  Desinstalacao concluida!                  |"
Write-Host "|                                              |"
Write-Host "|  Em Configuracoes > Geral > Idioma,         |"
Write-Host "|  volte para English.                        |"
Write-Host "+--------------------------------------------+"
