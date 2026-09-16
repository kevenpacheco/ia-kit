#Requires -Version 5.1
<#
.SYNOPSIS
Instala ou atualiza o nucleo do ia-kit em .ia-kit/.

.DESCRIPTION
Este script so troca arquivo. Ele nao entrevista, nao gera shim e nao commita.
Depois de rodar, rode o k-init: e ele quem reconcilia o contrato e os shims.

Rodando via `irm ... | iex` os parametros nao podem ser passados - os padroes valem.
Para passar parametro, baixe o script antes:
  irm https://raw.githubusercontent.com/kevenpacheco/ia-kit/main/instalador/instalar.ps1 -OutFile instalar.ps1
  .\instalar.ps1 -Versao 2.0.0

.EXAMPLE
.\instalar.ps1
.EXAMPLE
.\instalar.ps1 -Versao 2.0.0
.EXAMPLE
.\instalar.ps1 -Origem https://github.com/minha-org/ia-kit -Destino sub/.ia-kit
#>
param(
  [string]$Versao  = 'latest',
  [string]$Origem  = 'https://github.com/kevenpacheco/ia-kit',
  [string]$Destino = '.ia-kit',
  [switch]$Forcar
)

$ErrorActionPreference = 'Stop'
# Sem isto, a barra de progresso do Invoke-WebRequest no PowerShell 5.1 faz um
# download de segundos levar minutos.
$ProgressPreference = 'SilentlyContinue'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Caminhos dentro de .ia-kit/ que pertencem ao projeto, nao ao kit.
$Preservar = @('contrato.yml', 'taticas', 'metricas')

function Erro($msg) { throw $msg }

$tmp = $null
try {
  $Origem = $Origem.TrimEnd('/')
  if ([string]::IsNullOrWhiteSpace($Destino) -or $Destino -in @('.', '..', '/', '\')) {
    Erro "Destino invalido: '$Destino'"
  }

  # Recusar antes de baixar: destino que existe e nao parece um nucleo do kit.
  if (Test-Path $Destino) {
    if (-not (Test-Path $Destino -PathType Container)) {
      Erro "$Destino existe e nao e diretorio"
    }
    $pareceKit = (Test-Path (Join-Path $Destino 'VERSAO')) -or
                 (Test-Path (Join-Path $Destino 'contrato.yml'))
    if (-not $pareceKit -and -not $Forcar) {
      Erro "$Destino existe mas nao parece um nucleo do ia-kit. Use -Forcar se for mesmo para substituir."
    }
  }

  # --- resolver a referencia a baixar -------------------------------------
  if ($Versao -eq 'latest') {
    $caminho = $Origem -replace '^https?://[^/]+/', ''
    try {
      $rel = Invoke-RestMethod -Uri "https://api.github.com/repos/$caminho/releases/latest" `
                               -Headers @{ 'User-Agent' = 'ia-kit-instalador' }
      $Versao = ($rel.tag_name -replace '^v', '')
    } catch {
      $Versao = ''
    }
    if ([string]::IsNullOrWhiteSpace($Versao)) {
      Erro "Nenhum release publicado em $Origem. Passe -Versao <tag|branch|sha>."
    }
  }

  if ($Versao -match '^\d+\.\d+\.\d+') { $ref = "v$Versao" } else { $ref = $Versao }

  # --- baixar e extrair ----------------------------------------------------
  $tmp = Join-Path ([IO.Path]::GetTempPath()) ("iakit-" + [Guid]::NewGuid().ToString('N'))
  New-Item -ItemType Directory -Path $tmp | Out-Null

  $url = "$Origem/archive/$ref.zip"
  Write-Host "baixando $url"
  $zip = Join-Path $tmp 'kit.zip'
  try {
    Invoke-WebRequest -Uri $url -OutFile $zip -UseBasicParsing
  } catch {
    Erro "Download falhou. Versao '$Versao' existe em $Origem?"
  }

  Expand-Archive -Path $zip -DestinationPath (Join-Path $tmp 'extraido') -Force
  $pacote = Get-ChildItem -Path (Join-Path $tmp 'extraido') -Directory | Select-Object -First 1
  if ($null -eq $pacote) { Erro "Pacote vazio" }

  $versaoArquivo = Join-Path $pacote.FullName 'nucleo\VERSAO'
  if (-not (Test-Path $versaoArquivo)) { Erro "Pacote nao contem nucleo/VERSAO - origem errada?" }
  $nova = (Get-Content $versaoArquivo -Raw).Trim()

  $anterior = 'ausente'
  $destinoVersao = Join-Path $Destino 'VERSAO'
  if (Test-Path $destinoVersao) { $anterior = (Get-Content $destinoVersao -Raw).Trim() }

  # --- guardar o que e do projeto -----------------------------------------
  $guardados = Join-Path $tmp 'preservado'
  if (Test-Path $Destino) {
    New-Item -ItemType Directory -Path $guardados | Out-Null
    foreach ($item in $Preservar) {
      $origemItem = Join-Path $Destino $item
      if (Test-Path $origemItem) {
        Copy-Item -Path $origemItem -Destination $guardados -Recurse -Force
        Write-Host "preservando $origemItem"
      }
    }
    Remove-Item -Path $Destino -Recurse -Force -Confirm:$false
  }

  # --- instalar ------------------------------------------------------------
  $pai = Split-Path -Parent $Destino
  if ($pai -and -not (Test-Path $pai)) { New-Item -ItemType Directory -Path $pai -Force | Out-Null }
  Copy-Item -Path (Join-Path $pacote.FullName 'nucleo') -Destination $Destino -Recurse -Force

  if (Test-Path $guardados) {
    foreach ($item in $Preservar) {
      $guardado = Join-Path $guardados $item
      if (Test-Path $guardado) { Copy-Item -Path $guardado -Destination $Destino -Recurse -Force }
    }
  }

  Write-Host ""
  Write-Host "nucleo: $anterior -> $nova  em $Destino"
  if (Test-Path (Join-Path $Destino 'contrato.yml')) {
    Write-Host "contrato.yml preservado."
  } else {
    Write-Host "sem contrato.yml - instalacao nova."
  }
  Write-Host "proximo passo: rode k-init. O instalador nao gera shim nem reconcilia contrato."
}
catch {
  Write-Host "erro: $($_.Exception.Message)"
  exit 1
}
finally {
  if ($tmp -and (Test-Path $tmp)) {
    Remove-Item -Path $tmp -Recurse -Force -Confirm:$false -ErrorAction SilentlyContinue
  }
}
