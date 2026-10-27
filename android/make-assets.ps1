# make-assets.ps1 — erzeugt die Launcher-Icons via System.Drawing.
# Motiv: cremefarbener Würfel (Fünf, rotes Mittelauge) auf Filzgrün. Neu ausführen, um Icons zu ersetzen.
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

$resDir = Join-Path $PSScriptRoot 'app\res'

function Ensure-Dir([string]$p) { if (-not (Test-Path $p)) { New-Item -ItemType Directory -Force $p | Out-Null } }

function New-RoundRect([single]$x, [single]$y, [single]$w, [single]$h, [single]$r) {
  $p = New-Object System.Drawing.Drawing2D.GraphicsPath
  $d = $r * 2
  $p.AddArc($x, $y, $d, $d, 180, 90)
  $p.AddArc($x + $w - $d, $y, $d, $d, 270, 90)
  $p.AddArc($x + $w - $d, $y + $h - $d, $d, $d, 0, 90)
  $p.AddArc($x, $y + $h - $d, $d, $d, 90, 90)
  $p.CloseFigure()
  return $p
}

function New-Icon([int]$size, [bool]$withBg = $true) {
  $bmp = New-Object System.Drawing.Bitmap($size, $size)
  $g = [System.Drawing.Graphics]::FromImage($bmp)
  $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias

  # Filzgrüner Hintergrund (#1b6a52 -> #0f3d2e)
  $rect = New-Object System.Drawing.Rectangle(0, 0, $size, $size)
  $bgBrush = New-Object System.Drawing.Drawing2D.LinearGradientBrush($rect,
    [System.Drawing.Color]::FromArgb(255, 27, 106, 82), [System.Drawing.Color]::FromArgb(255, 15, 61, 46), 90)
  if ($withBg) { $g.FillRectangle($bgBrush, $rect) }

  # Würfel leicht gedreht
  $g.TranslateTransform([single]($size / 2), [single]($size / 2))
  $g.RotateTransform(-10)
  $ds = [single]($size * 0.56); $h = [single]($ds / 2)

  $shadow = New-RoundRect (-$h + $size * 0.02) (-$h + $size * 0.04) $ds $ds ($ds * 0.2)
  $g.FillPath((New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(90, 0, 0, 0))), $shadow)
  $die = New-RoundRect (-$h) (-$h) $ds $ds ($ds * 0.2)
  $g.FillPath((New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 251, 246, 234))), $die)

  # Fünf Augen, Mitte rot
  $pr = [single]($ds * 0.085); $o = [single]($ds * 0.26)
  $felt = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 15, 61, 46))
  $red  = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 217, 83, 79))
  foreach ($pt in @(@(-$o, -$o), @($o, -$o), @(-$o, $o), @($o, $o))) {
    $g.FillEllipse($felt, [single]($pt[0] - $pr), [single]($pt[1] - $pr), [single]($pr * 2), [single]($pr * 2))
  }
  $g.FillEllipse($red, [single](-$pr), [single](-$pr), [single]($pr * 2), [single]($pr * 2))

  $g.Dispose()
  return $bmp
}

function Save-Png([System.Drawing.Bitmap]$bmp, [string]$path) {
  Ensure-Dir (Split-Path -Parent $path)
  $bmp.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)
  $bmp.Dispose()
}

$dens = @{ 'mipmap-mdpi' = 48; 'mipmap-hdpi' = 72; 'mipmap-xhdpi' = 96; 'mipmap-xxhdpi' = 144; 'mipmap-xxxhdpi' = 192 }
foreach ($d in $dens.Keys) {
  Save-Png (New-Icon $dens[$d]) (Join-Path $resDir "$d\ic_launcher.png")
}
$storeDir = Join-Path (Split-Path -Parent $PSScriptRoot) 'store'
Save-Png (New-Icon 512) (Join-Path $storeDir 'icon-512.png')

# --- Play-Store-Feature-Grafik 1024x500: Würfel links, Name rechts ---
$fw = 1024; $fh = 500
$fg = New-Object System.Drawing.Bitmap($fw, $fh)
$g = [System.Drawing.Graphics]::FromImage($fg)
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit
$frect = New-Object System.Drawing.Rectangle(0, 0, $fw, $fh)
$g.FillRectangle((New-Object System.Drawing.Drawing2D.LinearGradientBrush($frect,
  [System.Drawing.Color]::FromArgb(255, 27, 106, 82), [System.Drawing.Color]::FromArgb(255, 15, 61, 46), 90)), $frect)
$die = New-Icon 360 $false
$g.DrawImage($die, 60, 70, 360, 360)
$die.Dispose()
$cream = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 251, 246, 234))
$gold  = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 246, 210, 122))
$g.DrawString('Punktezähler', (New-Object System.Drawing.Font('Segoe UI', 54, [System.Drawing.FontStyle]::Bold)), $cream, 440, 140)
$g.DrawString('für Tutto', (New-Object System.Drawing.Font('Segoe UI', 54, [System.Drawing.FontStyle]::Bold)), $gold, 440, 225)
$g.DrawString('Punkte · Tabelle · Sieger bei 6.000', (New-Object System.Drawing.Font('Segoe UI', 22)), $cream, 446, 330)
$g.Dispose()
Save-Png $fg (Join-Path $storeDir 'feature-graphic.png')

Write-Host "Icons erzeugt: $resDir\mipmap-*\ic_launcher.png, $storeDir\icon-512.png, $storeDir\feature-graphic.png"
