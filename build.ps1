$ErrorActionPreference = 'Stop'

$project = $PSScriptRoot
$toolRoot = 'C:\Users\Admin\Documents\ChatGPT\p125 watch\research\tools\android-build'
$jdk = Get-ChildItem -LiteralPath "$toolRoot\jdk" -Directory | Select-Object -First 1 -ExpandProperty FullName
$env:JAVA_HOME = $jdk
$env:Path = "$jdk\bin;$env:Path"
$sdk = "$toolRoot\sdk"
$buildTools = "$sdk\build-tools\35.0.0"
$androidJar = "$sdk\platforms\android-35\android.jar"
$out = "$project\build"
$classes = "$out\classes"
$dex = "$out\dex"
$classesJar = "$out\classes.jar"
$unsigned = "$out\bridge-unsigned.apk"
$aligned = "$out\bridge-aligned.apk"
$final = "$out\chatgpt-watch-bridge-debug.apk"
$keystore = "$project\debug.keystore"

foreach ($path in @($androidJar, "$buildTools\aapt2.exe", "$buildTools\d8.bat", "$buildTools\apksigner.bat", "$buildTools\zipalign.exe", "$jdk\bin\javac.exe")) {
    if (-not (Test-Path -LiteralPath $path)) { throw "Missing build dependency: $path" }
}

Remove-Item -LiteralPath $out -Recurse -Force -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Force -Path $out, $classes, $dex | Out-Null

& "$buildTools\aapt2.exe" compile --dir "$project\app\src\main\res" -o "$out\resources.zip"
if ($LASTEXITCODE -ne 0) { throw 'Resource compilation failed.' }
& "$buildTools\aapt2.exe" link --manifest "$project\app\src\main\AndroidManifest.xml" -I $androidJar --auto-add-overlay -o $unsigned "$out\resources.zip"
if ($LASTEXITCODE -ne 0) { throw 'APK resource linking failed.' }

$javaSources = Get-ChildItem -LiteralPath "$project\app\src\main\java" -Recurse -Filter '*.java' | Select-Object -ExpandProperty FullName
& "$jdk\bin\javac.exe" -source 17 -target 17 -classpath $androidJar -d $classes $javaSources
if ($LASTEXITCODE -ne 0) { throw 'Java compilation failed.' }
& "$jdk\bin\jar.exe" cf $classesJar -C $classes .
if ($LASTEXITCODE -ne 0) { throw 'Class archive creation failed.' }
& "$buildTools\d8.bat" --min-api 32 --lib $androidJar --output $dex $classesJar
if ($LASTEXITCODE -ne 0) { throw 'DEX conversion failed.' }
& "$jdk\bin\jar.exe" uf $unsigned -C $dex classes.dex
if ($LASTEXITCODE -ne 0) { throw 'DEX packaging failed.' }

if (-not (Test-Path -LiteralPath $keystore)) {
    & "$jdk\bin\keytool.exe" -genkeypair -keystore $keystore -storepass android -keypass android -alias androiddebugkey -keyalg RSA -keysize 2048 -validity 10000 -dname 'CN=Android Debug,O=Android,C=US'
}

& "$buildTools\zipalign.exe" -f 4 $unsigned $aligned
if ($LASTEXITCODE -ne 0) { throw 'APK alignment failed.' }
& "$buildTools\apksigner.bat" sign --ks $keystore --ks-key-alias androiddebugkey --ks-pass pass:android --key-pass pass:android --out $final $aligned
if ($LASTEXITCODE -ne 0) { throw 'APK signing failed.' }
& "$buildTools\apksigner.bat" verify --verbose $final
if ($LASTEXITCODE -ne 0) { throw 'APK signature verification failed.' }
Get-FileHash -Algorithm SHA256 $final
Get-Item -LiteralPath $final | Select-Object FullName, Length, LastWriteTime
