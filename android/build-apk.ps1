# Baut die Tutto-APK ohne Gradle/Android Studio (wie die WM- und IP-App):
#   PWA spiegeln -> aapt -> javac -> d8 -> aapt add -> zipalign -> apksigner
# Toolchain (JDK 17, build-tools 34, platform android-34, debug.keystore) aus C:\WMBuild.
$ErrorActionPreference = 'Stop'

$root = $PSScriptRoot                      # ...\Apps\Tutto\android
$proj = Split-Path -Parent $root           # ...\Apps\Tutto
$web  = "$proj\www"                        # Web-App
$app  = "$root\app"

# --- Toolchain aus dem WM-Build wiederverwenden (nicht neu herunterladen) ---
$wm   = 'C:\WMBuild'
$bt   = "$wm\sdk\build-tools\34.0.0"
$androidJar = "$wm\sdk\platforms\android-34\android.jar"
$jdk  = (Get-Content "$wm\javahome.txt").Trim()
$ks   = "$wm\debug.keystore"

if (-not (Test-Path $bt))         { throw "build-tools nicht gefunden: $bt  (ist C:\WMBuild eingerichtet?)" }
if (-not (Test-Path $androidJar)) { throw "android.jar nicht gefunden: $androidJar" }
if (-not (Test-Path $jdk))        { throw "JDK nicht gefunden: $jdk" }

$env:JAVA_HOME = $jdk
$env:PATH = "$jdk\bin;$bt;$env:PATH"

$aapt      = "$bt\aapt.exe"
$d8        = "$bt\d8.bat"
$zipalign  = "$bt\zipalign.exe"
$apksigner = "$bt\apksigner.bat"
$javac     = "$jdk\bin\javac.exe"
$keytool   = "$jdk\bin\keytool.exe"

# --- 0/8: Web-App aus www nach app\assets\app spiegeln ---
Write-Host '== 0/8 www nach assets\app spiegeln =='
$assetsApp = "$app\assets\app"
Remove-Item $assetsApp -Recurse -Force -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Force $assetsApp | Out-Null
Get-ChildItem -Path $web -Force | ForEach-Object { Copy-Item $_.FullName -Destination $assetsApp -Recurse -Force }

$build = "$app\build"
Remove-Item $build -Recurse -Force -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Force "$build\gen", "$build\classes" | Out-Null
Set-Location $app

Write-Host '== 1/8 aapt: Ressourcen + Manifest + Assets packen =='
& $aapt package -f -M AndroidManifest.xml -S res -A assets -I $androidJar -F "$build\app-unsigned.apk" -J "$build\gen"
if ($LASTEXITCODE -ne 0) { throw "aapt package failed ($LASTEXITCODE)" }

Write-Host '== 2/8 javac: R.java + Activity kompilieren =='
# aapt legt R.java manchmal flach in gen\ statt im Paket-Unterordner ab
$rJava = if (Test-Path "$build\gen\com\rene\tutto\R.java") { "$build\gen\com\rene\tutto\R.java" } else { "$build\gen\R.java" }
$srcs = @($rJava, "$app\src\com\rene\tutto\MainActivity.java")
& $javac -source 8 -target 8 -encoding UTF-8 -classpath $androidJar -d "$build\classes" $srcs
if ($LASTEXITCODE -ne 0) { throw "javac failed ($LASTEXITCODE)" }

Write-Host '== 3/8 d8: classes.dex erzeugen =='
$classes = (Get-ChildItem "$build\classes" -Recurse -Filter *.class).FullName
& $d8 --release --lib $androidJar --output $build @classes
if ($LASTEXITCODE -ne 0) { throw "d8 failed ($LASTEXITCODE)" }

Write-Host '== 4/8 classes.dex in APK einfuegen =='
Copy-Item "$build\app-unsigned.apk" "$build\app-withdex.apk" -Force
Set-Location $build
& $aapt add app-withdex.apk classes.dex
if ($LASTEXITCODE -ne 0) { throw "aapt add failed ($LASTEXITCODE)" }

Write-Host '== 5/8 zipalign =='
& $zipalign -f -p 4 "$build\app-withdex.apk" "$build\app-aligned.apk"
if ($LASTEXITCODE -ne 0) { throw "zipalign failed ($LASTEXITCODE)" }

Write-Host '== 6/8 Debug-Keystore pruefen =='
if (-not (Test-Path $ks)) {
  & $keytool -genkeypair -v -keystore $ks -storepass android -keypass android -alias androiddebugkey `
    -keyalg RSA -keysize 2048 -validity 10000 -dname "CN=Tutto Debug,O=Tutto,C=DE"
  if ($LASTEXITCODE -ne 0) { throw "keytool failed ($LASTEXITCODE)" }
}

Write-Host '== 7/8 apksigner: signieren =='
$out = "$proj\Tutto.apk"
& $apksigner sign --ks $ks --ks-pass pass:android --key-pass pass:android --out $out "$build\app-aligned.apk"
if ($LASTEXITCODE -ne 0) { throw "apksigner sign failed ($LASTEXITCODE)" }

Write-Host '== 8/8 apksigner: verifizieren =='
& $apksigner verify --verbose $out
if ($LASTEXITCODE -ne 0) { throw "apksigner verify failed ($LASTEXITCODE)" }

$sizeKB = [math]::Round((Get-Item $out).Length / 1KB, 1)
Write-Host "== FERTIG == $out ($sizeKB KB)"
