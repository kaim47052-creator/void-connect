[CmdletBinding()]
param(
    [ValidatePattern('^v[0-9]+\.[0-9]+\.[0-9]+(?:-[A-Za-z0-9.-]+)?$')]
    [string]$ReleaseTag = 'v0.1.0-preview.4',
    [string]$AndroidApk,
    [string]$OutputDirectory = 'D:\VoidConnect\Releases',
    [string]$AndroidBuildTools = 'D:\Android\Sdk\build-tools\36.0.0',
    [string]$RuntimeDirectory = 'D:\Development\VisualStudio\Community\VC\Redist\MSVC\14.51.36231\x64\Microsoft.VC145.CRT'
)
$ErrorActionPreference = 'Stop'
$projectPath = Split-Path -Parent $PSScriptRoot
if (!$AndroidApk) { $AndroidApk = Join-Path $projectPath 'build\app\outputs\flutter-apk\app-release.apk' }
$AndroidApk = [IO.Path]::GetFullPath($AndroidApk)
$versionMatch = [regex]::Match((Get-Content (Join-Path $projectPath 'pubspec.yaml') -Raw), '(?m)^version:\s*(\d+\.\d+\.\d+)\+(\d+)\s*$')
if (!$versionMatch.Success) { throw 'Expected a semantic version with build number in pubspec.yaml.' }
$version = $versionMatch.Groups[1].Value
$build = $versionMatch.Groups[2].Value
$badging = & (Join-Path $AndroidBuildTools 'aapt2.exe') dump badging $AndroidApk
if ($LASTEXITCODE -ne 0) { throw 'APK metadata could not be inspected.' }
$expectedPackage = "package: name='dev.voidconnect.void_connect' versionCode='$build' versionName='$version'"
if (!($badging | Where-Object { $_.StartsWith($expectedPackage) })) { throw 'Wrong package ID or version. Verification APKs cannot be packaged.' }
if ($badging -contains 'application-debuggable') { throw 'Debug APKs cannot be packaged for release.' }
$certificateOutput = & (Join-Path $AndroidBuildTools 'apksigner.bat') verify --print-certs $AndroidApk
if ($LASTEXITCODE -ne 0) { throw 'APK signature validation failed.' }
$certificateMatch = [regex]::Match(($certificateOutput -join "`n"), 'Signer #1 certificate SHA-256 digest: ([0-9a-f]{64})')
$expectedCertificate = (Get-Content (Join-Path $projectPath 'docs\releases\android-signing-certificate.sha256') -Raw).Trim()
if (!$certificateMatch.Success -or $certificateMatch.Groups[1].Value -ne $expectedCertificate) { throw 'APK is not signed by the approved project certificate.' }
$bundlePath = Join-Path $projectPath 'build\windows\x64\runner\Release'
foreach ($file in @('VoidConnect.exe', 'flutter_windows.dll', 'data\app.so', 'data\icudtl.dat')) {
    if (!(Test-Path -LiteralPath (Join-Path $bundlePath $file))) { throw "Windows bundle missing $file" }
}
$exeVersion = (Get-Item (Join-Path $bundlePath 'VoidConnect.exe')).VersionInfo.ProductVersion
if ($exeVersion -ne "$version+$build") { throw 'Windows EXE version does not match pubspec.yaml.' }
$releasePath = Join-Path ([IO.Path]::GetFullPath($OutputDirectory)) $ReleaseTag
New-Item -ItemType Directory -Force -Path $releasePath | Out-Null
$stagePath = Join-Path $releasePath 'windows-payload'
# Staging is immutable per run so stale EXEs or DLLs cannot enter a new package.
if (Test-Path -LiteralPath $stagePath) { throw 'Windows staging already exists. Choose a new output directory.' }
New-Item -ItemType Directory -Path $stagePath | Out-Null
Copy-Item -LiteralPath (Join-Path $bundlePath 'VoidConnect.exe') -Destination $stagePath
Get-ChildItem -LiteralPath $bundlePath -Filter '*.dll' -File | Copy-Item -Destination $stagePath
Copy-Item -LiteralPath (Join-Path $bundlePath 'data') -Destination $stagePath -Recurse
foreach ($file in @('msvcp140.dll', 'vcruntime140.dll', 'vcruntime140_1.dll')) {
    $runtimePath = Join-Path $RuntimeDirectory $file
    if (!(Test-Path -LiteralPath $runtimePath)) { throw "Microsoft runtime missing $file" }
    Copy-Item -LiteralPath $runtimePath -Destination $stagePath
}
foreach ($file in @('LICENSE', 'THIRD_PARTY_NOTICES.md', 'CHANGELOG.md')) {
    Copy-Item -LiteralPath (Join-Path $projectPath $file) -Destination $stagePath
    Copy-Item -LiteralPath (Join-Path $projectPath $file) -Destination $releasePath
}
Copy-Item -LiteralPath (Join-Path $projectPath 'docs\INSTALL.md') -Destination (Join-Path $stagePath 'INSTALL.md')
Copy-Item -LiteralPath (Join-Path $projectPath 'docs\INSTALL.md') -Destination (Join-Path $releasePath 'INSTALL.md')
$apkName = "void-connect-$($ReleaseTag.TrimStart('v'))-android.apk"
$zipName = "void-connect-$($ReleaseTag.TrimStart('v'))-windows-x64.zip"
$apkDestination = Join-Path $releasePath $apkName
if ($AndroidApk -ne $apkDestination) { Copy-Item -LiteralPath $AndroidApk -Destination $apkDestination -Force }
Compress-Archive -Path (Join-Path $stagePath '*') -DestinationPath (Join-Path $releasePath $zipName) -Force
[ordered]@{
    release = $ReleaseTag
    applicationVersion = "$version+$build"
    androidPackage = 'dev.voidconnect.void_connect'
    androidCertificateSha256 = $expectedCertificate
    flutterVersion = '3.47.5'
    androidApk = $apkName
    windowsZip = $zipName
    windowsExe = 'VoidConnect.exe'
    license = 'MIT'
} | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $releasePath 'release-manifest.json') -Encoding utf8
$hashes = Get-ChildItem -LiteralPath $releasePath -File | Where-Object Name -ne 'SHA256SUMS.txt' | Sort-Object Name | ForEach-Object {
    "$( (Get-FileHash -LiteralPath $_.FullName -Algorithm SHA256).Hash.ToLowerInvariant())  $($_.Name)"
}
$hashes | Set-Content -LiteralPath (Join-Path $releasePath 'SHA256SUMS.txt') -Encoding ascii
Write-Output "Verified release packages: $releasePath"
