$ErrorActionPreference = 'Stop'
$path = 'lib/l10n/app_it.arb'
$arb = Get-Content $path -Raw -Encoding UTF8 | ConvertFrom-Json

function Translate-EsToIt([string]$text) {
  if ([string]::IsNullOrWhiteSpace($text)) { return $text }

  $placeholders = [regex]::Matches($text, '\{[^{}]+\}') | ForEach-Object { $_.Value } | Select-Object -Unique
  $tmp = $text
  $i = 0
  $tokenMap = @{}
  foreach ($ph in $placeholders) {
    $token = "__PH_${i}__"
    $tokenMap[$token] = $ph
    $tmp = $tmp.Replace($ph, $token)
    $i++
  }

  $url = 'https://translate.googleapis.com/translate_a/single?client=gtx&sl=es&tl=it&dt=t&q=' + [uri]::EscapeDataString($tmp)
  try {
    $resp = Invoke-RestMethod -Uri $url -Method Get -TimeoutSec 30
    $translated = (($resp[0] | ForEach-Object { $_[0] }) -join '')
  } catch {
    return $text
  }

  foreach ($key in $tokenMap.Keys) {
    $translated = $translated.Replace($key, $tokenMap[$key])
  }

  return $translated
}

$cache = @{}
$changed = 0
$metaChanged = 0

foreach ($prop in $arb.PSObject.Properties) {
  $name = $prop.Name
  $value = $prop.Value

  if ($name -eq '@@locale') {
    $prop.Value = 'it'
    continue
  }

  if ($name -like '@*') {
    if ($value -is [pscustomobject]) {
      $descProp = $value.PSObject.Properties['description']
      if ($null -ne $descProp -and ($descProp.Value -is [string])) {
        $src = [string]$descProp.Value
        if (-not $cache.ContainsKey($src)) {
          $cache[$src] = Translate-EsToIt $src
        }
        $dst = [string]$cache[$src]
        if ($dst -ne $src) { $metaChanged++ }
        $descProp.Value = $dst
      }
    }
    continue
  }

  if ($value -is [string]) {
    $src = [string]$value
    if (-not $cache.ContainsKey($src)) {
      $cache[$src] = Translate-EsToIt $src
    }
    $dst = [string]$cache[$src]
    if ($dst -ne $src) { $changed++ }
    $prop.Value = $dst
  }
}

# Ajustes manuales de estilo para evitar traducciones literales raras.
$fix = @{
  'aboutOpenReleases' = 'Vedi release'
  'integrationOpenaiApiKeyHint' = 'Ottenuta su platform.openai.com/api-keys'
  'integrationClaudeApiKeyHint' = 'Ottenuta su console.anthropic.com/settings/keys'
  'integrationEmailApiKeyHint' = 'Ottenuta su resend.com/api-keys'
  'integrationTelegramBotTokenHint' = 'Da @BotFather'
  'integrationTelegramChatIdHint' = 'Usa @userinfobot per ottenere il tuo ID'
  'updateLabelUpper' = 'AGGIORNA'
  'cancelUpper' = 'ANNULLA'
  'deleteUpper' = 'ELIMINA'
  'goToProfileUpper' = 'VAI AL PROFILO'
  'unlinkIntegrationUpper' = 'SCOLLEGA INTEGRAZIONE'
  'publishOnGithubUpper' = 'PUBBLICA SU GITHUB'
  'installInMyInventoryUpper' = 'INSTALLA NEL MIO INVENTARIO'
  'dataStructureFieldsUpper' = 'STRUTTURA DATI ({count} CAMPI)'
  'copiedToClipboard' = 'Copiato negli appunti'
  'veniChatPoweredBy' = 'Powered by '
  'pluginTabMine' = 'I miei'
  'templateByAuthor' = 'di @{name}'
}
foreach ($k in $fix.Keys) {
  $p = $arb.PSObject.Properties[$k]
  if ($null -ne $p -and ($p.Value -is [string])) {
    $p.Value = $fix[$k]
  }
}

$arb | ConvertTo-Json -Depth 30 | Set-Content $path -Encoding UTF8

Write-Output "translated_strings=$changed"
Write-Output "translated_meta_descriptions=$metaChanged"
Write-Output "unique_source_strings=$($cache.Keys.Count)"
