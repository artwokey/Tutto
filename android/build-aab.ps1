# Baut das Android App Bundle (.aab) für Google Play ohne Gradle/Android Studio:
#   www spiegeln -> aapt2 compile/link (Proto-Format) -> javac -> d8 -> Modul-Zip -> bundletool -> jarsigner
# Toolchain aus C:\WMBuild; Upload-Schlüssel in C:\WMBuild\keys (NICHT im Repo).
$ErrorActionPreference = 'Stop'

$root = $PSScriptRoot                      # ...\Apps\Tutto\android
$proj = Split-Path -Parent $root           # ...\Apps\Tutto
$web  = "$proj\www"
$app  = "$root\app"

$wm   = 'C:\WMBuild'
$bt   = "$wm\sdk\build-tools\34.0.0"
$androidJar = "$wm\sdk\platforms\android-34\android.jar"
$jdk  = (Get-Content "$wm\javahome.txt").Trim()
$bundletool = "$wm\bundletool.jar"
$ks   = "$wm\keys\tutto-upload.jks"
$ksInfo = "$wm\keys\tutto-upload.txt"

foreach ($p in @($bt, $androidJar, $jdk, $ks, $ksInfo)) { if (-not (Test-Path $p)) { throw "Nicht gefunden: $p" } }
$pw = ((Get-Content $ksInfo | Where-Object { $_ -like 'Passwort:*' }) -replace '^Passwort:\s*(\S+).*$', '$1')

$aapt2 = "$bt\aapt2.exe"
$d8    = "$bt\d8.bat"
$javac = "$jdk\bin\javac.exe"
$java  = "$jdk\bin\java.exe"
$jarsigner = "$jdk\bin\jarsigner.exe"
$env:JAVA_HOME = $jdk

Write-Host '== 1/7 www nach assets\app spiegeln =='
$assetsApp = "$app\assets\app"
Remove-Item $assetsApp -Recurse -Force -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Force $assetsApp | Out-Null
Copy-Item "$web\*" $assetsApp -Recurse -Force

$build = "$app\build-aab"
Remove-Item $build -Recurse -Force -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Force "$build\gen", "$build\classes", "$build\module" | Out-Null

Write-Host '== 2/7 aapt2: Ressourcen kompilieren + im Proto-Format linken =='
& $aapt2 compile --dir "$app\res" -o "$build\res.zip"
if ($LASTEXITCODE -ne 0) { throw "aapt2 compile failed ($LASTEXITCODE)" }
& $aapt2 link --proto-format -o "$build\base.apk" -I $androidJar --manifest "$app\AndroidManifest.xml" `
  -A "$app\assets" --java "$build\gen" --auto-add-overlay "$build\res.zip"
if ($LASTEXITCODE -ne 0) { throw "aapt2 link failed ($LASTEXITCODE)" }

Write-Host '== 3/7 javac =='
$rJava = (Get-ChildItem "$build\gen" -Recurse -Filter R.java).FullName
& $javac -source 8 -target 8 -encoding UTF-8 -classpath $androidJar -d "$build\classes" $rJava "$app\src\com\rene\tutto\MainActivity.java"
if ($LASTEXITCODE -ne 0) { throw "javac failed ($LASTEXITCODE)" }

Write-Host '== 4/7 d8 =='
$classes = (Get-ChildItem "$build\classes" -Recurse -Filter *.class).FullName
& $d8 --release --lib $androidJar --output $build @classes
if ($LASTEXITCODE -ne 0) { throw "d8 failed ($LASTEXITCODE)" }

Write-Host '== 5/7 Basis-Modul zusammenstellen =='
# Layout laut bundletool: manifest/, dex/, res/, assets/, resources.pb
$mod = "$build\module"
Expand-Archive "$build\base.apk" "$build\unzipped" -Force
New-Item -ItemType Directory -Force "$mod\manifest", "$mod\dex" | Out-Null
Move-Item "$build\unzipped\AndroidManifest.xml" "$mod\manifest\"
Move-Item "$build\unzipped\resources.pb" "$mod\"
Move-Item "$build\unzipped\res" "$mod\"
Move-Item "$build\unzipped\assets" "$mod\"
Copy-Item "$build\classes.dex" "$mod\dex\"
Compress-Archive "$mod\*" "$build\base.zip" -Force

Write-Host '== 6/7 bundletool: AAB bauen =='
if (-not (Test-Path $bundletool)) { throw "bundletool fehlt: $bundletool (https://github.com/google/bundletool/releases)" }
$aab = "$proj\PunktezaehlerTutto.aab"
Remove-Item $aab -Force -ErrorAction SilentlyContinue
& $java -jar $bundletool build-bundle "--modules=$build\base.zip" "--output=$aab"
if ($LASTEXITCODE -ne 0) { throw "bundletool failed ($LASTEXITCODE)" }

Write-Host '== 7/7 jarsigner: mit Upload-Schlüssel signieren =='
& $jarsigner -keystore $ks -storepass $pw -keypass $pw -sigalg SHA256withRSA -digestalg SHA-256 $aab upload
if ($LASTEXITCODE -ne 0) { throw "jarsigner failed ($LASTEXITCODE)" }
& $jarsigner -verify $aab | Select-Object -Last 1

$sizeKB = [math]::Round((Get-Item $aab).Length / 1KB, 1)
Write-Host "== FERTIG == $aab ($sizeKB KB)"
