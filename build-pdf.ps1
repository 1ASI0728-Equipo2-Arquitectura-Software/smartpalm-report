# build-pdf.ps1 — genera TB1.pdf a partir de los .md del informe.
# Requisitos: Pandoc + Google Chrome (o Microsoft Edge).
#   winget install --id JohnMacFarlane.Pandoc
# Uso:  .\build-pdf.ps1

$repo = $PSScriptRoot
Set-Location $repo

$pandoc = @(
  "$env:LOCALAPPDATA\Microsoft\WinGet\Links\pandoc.exe",
  "$env:LOCALAPPDATA\Pandoc\pandoc.exe",
  "C:\Program Files\Pandoc\pandoc.exe"
) | Where-Object { Test-Path $_ } | Select-Object -First 1
if (-not $pandoc) { $pandoc = (Get-Command pandoc -ErrorAction SilentlyContinue).Source }
if (-not $pandoc) { throw "No se encontro pandoc. Instalalo con: winget install --id JohnMacFarlane.Pandoc" }

$browser = @(
  "C:\Program Files\Google\Chrome\Application\chrome.exe",
  "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe",
  "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe",
  "C:\Program Files\Microsoft\Edge\Application\msedge.exe"
) | Where-Object { Test-Path $_ } | Select-Object -First 1
if (-not $browser) { throw "No se encontro Chrome ni Edge." }

$css = Join-Path $repo "report.css"
if (-not (Test-Path $css)) { throw "Falta report.css junto al script." }

$tmp = Join-Path $env:TEMP ("tb1build_" + [guid]::NewGuid().ToString("N"))
New-Item -ItemType Directory -Path $tmp -Force | Out-Null

# 1. Unir todos los .md en orden (el orden alfabetico respeta los prefijos numericos)
$files = Get-ChildItem -Recurse -Filter *.md |
  Where-Object { $_.FullName -notmatch '\\\.git\\' -and $_.Name -ne 'README.md' -and $_.Name -notmatch '^_build' } |
  Sort-Object { ($_.FullName.Substring($repo.Length)) -replace '\\','/' } |
  Select-Object -ExpandProperty FullName

$sb = New-Object System.Text.StringBuilder
foreach ($f in $files) {
  $raw = Get-Content $f -Raw -Encoding utf8
  $raw = $raw -replace '\((?:\.\./)+assets/', '(assets/'
  $raw = $raw -replace 'src="(?:\.\./)+assets/', 'src="assets/'
  [void]$sb.AppendLine($raw)
  [void]$sb.AppendLine("")
}
$build = Join-Path $repo "_build-tb1.md"
[System.IO.File]::WriteAllText($build, $sb.ToString(), (New-Object System.Text.UTF8Encoding($false)))

$html = Join-Path $tmp "report.html"
$pdf  = Join-Path $repo "TB1.pdf"

try {
  # 2. Markdown -> HTML autocontenido
  & $pandoc $build -o $html --standalone --embed-resources --css $css --metadata "title=SmartPalm - Informe TB1" --resource-path=$repo
  if (-not (Test-Path $html)) { throw "Pandoc no genero el HTML." }

  # 3. HTML -> PDF con navegador headless (se fuerza la espera con el pipe)
  $url = "file:///" + ($html -replace '\\','/')
  & $browser --headless --disable-gpu --no-pdf-header-footer --user-data-dir="$tmp\cdata" --print-to-pdf="$pdf" $url 2>&1 | Out-Null

  # El navegador puede desacoplarse: esperar a que el PDF exista y su tamano se estabilice
  $deadline = (Get-Date).AddMinutes(3); $prev = -1
  while ((Get-Date) -lt $deadline) {
    $sz = if (Test-Path $pdf) { (Get-Item $pdf).Length } else { 0 }
    if ($sz -gt 0 -and $sz -eq $prev) { break }
    $prev = $sz
    Start-Sleep -Milliseconds 700
  }
  if (-not (Test-Path $pdf) -or (Get-Item $pdf).Length -lt 100000) { throw "El navegador no genero el PDF." }

  Write-Host ("OK -> {0} ({1:N1} MB)" -f $pdf, ((Get-Item $pdf).Length / 1MB))
}
finally {
  Remove-Item $build -Force -ErrorAction SilentlyContinue
  Remove-Item $tmp -Recurse -Force -ErrorAction SilentlyContinue
}
