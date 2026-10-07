[CmdletBinding()]
param(
    [string]$SigningDirectory = 'D:\VoidConnect\Signing',
    [string]$Keytool = 'D:\Development\Java\jdk-21.0.12.1+1\bin\keytool.exe'
)
$ErrorActionPreference = 'Stop'
if ($env:OS -ne 'Windows_NT') { throw 'This script uses Windows DPAPI.' }
if (!(Test-Path -LiteralPath $Keytool)) { throw 'Official JDK keytool was not found.' }
$signingPath = [IO.Path]::GetFullPath($SigningDirectory)
if ($signingPath.TrimEnd('\') -eq [IO.Path]::GetPathRoot($signingPath).TrimEnd('\')) {
    throw 'Signing directory must not be a drive root.'
}
$storePath = Join-Path $signingPath 'void-connect-release.p12'
$passwordPath = Join-Path $signingPath 'release-password.clixml'
$certificatePath = Join-Path $signingPath 'release-certificate.pem'
foreach ($path in @($storePath, $passwordPath, $certificatePath)) {
    if (Test-Path -LiteralPath $path) { throw 'Signing files already exist; refusing to replace the key.' }
}
if ((Test-Path -LiteralPath $signingPath) -and (Get-ChildItem -LiteralPath $signingPath -Force | Select-Object -First 1)) {
    throw 'Use a dedicated empty signing directory; existing folders will not be restricted.'
}
New-Item -ItemType Directory -Path $signingPath -Force | Out-Null
# Restrict this dedicated project directory before writing any secrets.
$identity = [Security.Principal.WindowsIdentity]::GetCurrent().User
$acl = Get-Acl -LiteralPath $signingPath
$acl.SetAccessRuleProtection($true, $false)
foreach ($sid in @($identity, [Security.Principal.SecurityIdentifier]'S-1-5-18', [Security.Principal.SecurityIdentifier]'S-1-5-32-544')) {
    $rule = [Security.AccessControl.FileSystemAccessRule]::new(
        $sid, 'FullControl', 'ContainerInherit,ObjectInherit', 'None', 'Allow'
    )
    $acl.AddAccessRule($rule)
}
Set-Acl -LiteralPath $signingPath -AclObject $acl
$randomBytes = New-Object byte[] 32
$rng = [Security.Cryptography.RandomNumberGenerator]::Create()
$rng.GetBytes($randomBytes)
$rng.Dispose()
$password = [Convert]::ToBase64String($randomBytes)
$securePassword = ConvertTo-SecureString $password -AsPlainText -Force
$securePassword | Export-Clixml -LiteralPath $passwordPath
$previousPassword = $env:VOID_CONNECT_KEYTOOL_PASSWORD
try {
    $env:VOID_CONNECT_KEYTOOL_PASSWORD = $password
    & $Keytool -genkeypair -storetype PKCS12 -keystore $storePath -alias 'void-connect-release' `
        -keyalg RSA -keysize 3072 -validity 10000 -dname 'CN=Void Connect, OU=Direct APK distribution' `
        -storepass:env VOID_CONNECT_KEYTOOL_PASSWORD -keypass:env VOID_CONNECT_KEYTOOL_PASSWORD
    if ($LASTEXITCODE -ne 0) { throw 'Key generation failed. Inspect the private directory before retrying.' }
    & $Keytool -exportcert -rfc -keystore $storePath -alias 'void-connect-release' `
        -storepass:env VOID_CONNECT_KEYTOOL_PASSWORD -file $certificatePath
    if ($LASTEXITCODE -ne 0) { throw 'Certificate export failed.' }
    Write-Output "Signing key and DPAPI-protected password created in $signingPath."
    Write-Output 'Back up the key and recoverable password privately before public distribution.'
} finally {
    $env:VOID_CONNECT_KEYTOOL_PASSWORD = $previousPassword
    $password = $null
    [Array]::Clear($randomBytes, 0, $randomBytes.Length)
}
