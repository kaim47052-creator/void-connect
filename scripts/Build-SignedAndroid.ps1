[CmdletBinding()]
param(
    [string]$SigningDirectory = 'D:\VoidConnect\Signing',
    [string]$Flutter = 'D:\Development\Flutter\bin\flutter.bat',
    [switch]$Verification
)
$ErrorActionPreference = 'Stop'
$projectPath = Split-Path -Parent $PSScriptRoot
$storePath = Join-Path ([IO.Path]::GetFullPath($SigningDirectory)) 'void-connect-release.p12'
$passwordPath = Join-Path ([IO.Path]::GetFullPath($SigningDirectory)) 'release-password.clixml'
if (!(Test-Path -LiteralPath $storePath) -or !(Test-Path -LiteralPath $passwordPath)) {
    throw 'Signing files are missing. See docs/RELEASING.md.'
}
$securePassword = Import-Clixml -LiteralPath $passwordPath
if ($securePassword -isnot [Security.SecureString]) { throw 'Invalid signing password file.' }
$credential = [Management.Automation.PSCredential]::new('void-connect-release', $securePassword)
$names = @('VOID_CONNECT_RELEASE_STORE_FILE', 'VOID_CONNECT_RELEASE_STORE_PASSWORD', 'VOID_CONNECT_RELEASE_KEY_ALIAS', 'VOID_CONNECT_RELEASE_KEY_PASSWORD', 'VOID_CONNECT_VERIFY_RELEASE')
$previous = @{}
foreach ($name in $names) { $previous[$name] = [Environment]::GetEnvironmentVariable($name, 'Process') }
Push-Location $projectPath
try {
    $env:VOID_CONNECT_RELEASE_STORE_FILE = $storePath
    $env:VOID_CONNECT_RELEASE_STORE_PASSWORD = $credential.GetNetworkCredential().Password
    $env:VOID_CONNECT_RELEASE_KEY_ALIAS = 'void-connect-release'
    $env:VOID_CONNECT_RELEASE_KEY_PASSWORD = $env:VOID_CONNECT_RELEASE_STORE_PASSWORD
    $env:VOID_CONNECT_VERIFY_RELEASE = if ($Verification) { '1' } else { $null }
    & $Flutter build apk --release --target lib/main.dart
    if ($LASTEXITCODE -ne 0) { throw 'Signed Android build failed.' }
} finally {
    foreach ($name in $names) { [Environment]::SetEnvironmentVariable($name, $previous[$name], 'Process') }
    Pop-Location
    $credential = $null
    $securePassword = $null
}
