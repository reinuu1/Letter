<#
  Pune o imagine pe timbrul din plic.

  Folosire:
      .\pune-timbru.ps1 -Imagine "D:\poze\poza-mea.jpg"

  Ca sa revii la desenul original cu luna si steaua:
      .\pune-timbru.ps1 -Sterge

  Scriptul modifica pentru-sara.html din acelasi folder si face o copie
  de siguranta pentru-sara.backup.html inainte de orice schimbare.
#>

param(
    [string]$Imagine,
    [switch]$Sterge,
    [string]$Html = "$PSScriptRoot\pentru-sara.html"
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path $Html)) {
    Write-Host "Nu gasesc $Html" -ForegroundColor Red
    exit 1
}

if (-not $Sterge) {
    if (-not $Imagine) {
        Write-Host "Dai -Imagine <cale> sau -Sterge. Exemplu:" -ForegroundColor Yellow
        Write-Host '  .\pune-timbru.ps1 -Imagine "D:\poze\noi.jpg"'
        exit 1
    }
    if (-not (Test-Path $Imagine)) {
        Write-Host "Nu gasesc imaginea: $Imagine" -ForegroundColor Red
        exit 1
    }
}

# backup
$backup = Join-Path (Split-Path $Html) "pentru-sara.backup.html"
Copy-Item $Html $backup -Force
Write-Host "Copie de siguranta: $backup" -ForegroundColor DarkGray

if ($Sterge) {
    $dataUri = ""
    Write-Host "Revin la desenul original." -ForegroundColor Cyan
} else {
    $ext = [System.IO.Path]::GetExtension($Imagine).ToLower()
    $mime = switch ($ext) {
        ".jpg"  { "image/jpeg" }
        ".jpeg" { "image/jpeg" }
        ".png"  { "image/png"  }
        ".webp" { "image/webp" }
        ".gif"  { "image/gif"  }
        default { "" }
    }
    if (-not $mime) {
        Write-Host "Format nesuportat: $ext (foloseste jpg, png, webp sau gif)" -ForegroundColor Red
        exit 1
    }

    $bytes = [System.IO.File]::ReadAllBytes($Imagine)
    $kb = [math]::Round($bytes.Length / 1KB)
    if ($bytes.Length -gt 3MB) {
        Write-Host "Atentie: imaginea are $kb KB. Peste ~3 MB pagina se incarca greu." -ForegroundColor Yellow
        Write-Host "Micsoreaza-o si incearca din nou (timbrul are nevoie de maxim ~400x500 px)." -ForegroundColor Yellow
    }

    $dataUri = "data:$mime;base64," + [System.Convert]::ToBase64String($bytes)
    Write-Host "Imagine incarcata: $kb KB ($mime)" -ForegroundColor Cyan
}

$continut = [System.IO.File]::ReadAllText($Html, [System.Text.Encoding]::UTF8)
$tipar = 'timbruImagine:\s*"[^"]*"'

if ($continut -notmatch $tipar) {
    Write-Host "Nu gasesc campul timbruImagine in HTML." -ForegroundColor Red
    exit 1
}

$nou = [System.Text.RegularExpressions.Regex]::Replace(
    $continut, $tipar, 'timbruImagine: "' + $dataUri + '"', 1)

[System.IO.File]::WriteAllText($Html, $nou, (New-Object System.Text.UTF8Encoding $false))

Write-Host ""
Write-Host "Gata. Deschide pentru-sara.html in browser ca sa vezi timbrul." -ForegroundColor Green
Write-Host "Daca vrei imaginea si in link-ul online, trimite-mi fisierul si il public eu." -ForegroundColor DarkGray
