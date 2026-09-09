[CmdletBinding()]
param(
    [string]$InnoSetupCompiler,
    [switch]$SkipVerification
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

function Invoke-CheckedCommand {
    param(
        [Parameter(Mandatory = $true)][string]$FilePath,
        [Parameter(Mandatory = $true)][string[]]$Arguments
    )

    & $FilePath @Arguments
    if ($LASTEXITCODE -ne 0) {
        throw "$FilePath exited with code $LASTEXITCODE."
    }
}

$windowsDirectory = [System.IO.Path]::GetFullPath($PSScriptRoot)
$appDirectory = [System.IO.Path]::GetFullPath((Join-Path $windowsDirectory '..'))
$pubspecPath = Join-Path $appDirectory 'pubspec.yaml'
$pubspec = Get-Content -LiteralPath $pubspecPath -Raw
$versionMatch = [regex]::Match(
    $pubspec,
    '(?m)^version:\s*(?<name>\d+\.\d+\.\d+)\+(?<build>\d+)\s*$'
)
if (-not $versionMatch.Success) {
    throw 'Unable to read a semantic version and build number from pubspec.yaml.'
}

$versionName = $versionMatch.Groups['name'].Value
$buildNumber = $versionMatch.Groups['build'].Value
$releaseDirectory = Join-Path $appDirectory 'build\windows\x64\runner\Release'
$releasesRoot = [System.IO.Path]::GetFullPath((Join-Path $appDirectory 'build\releases'))
$outputDirectory = [System.IO.Path]::GetFullPath((Join-Path $releasesRoot "v$versionName"))

if (-not $outputDirectory.StartsWith(
    $releasesRoot + [System.IO.Path]::DirectorySeparatorChar,
    [System.StringComparison]::OrdinalIgnoreCase
)) {
    throw 'Refusing to prepare artifacts outside build/releases.'
}

Push-Location $appDirectory
try {
    if (-not $SkipVerification) {
        Invoke-CheckedCommand -FilePath 'flutter' -Arguments @('pub', 'get')
        Invoke-CheckedCommand -FilePath 'flutter' -Arguments @('analyze')
        Invoke-CheckedCommand -FilePath 'flutter' -Arguments @('test')
    }

    Invoke-CheckedCommand -FilePath 'flutter' -Arguments @(
        'build',
        'windows',
        '--release',
        '--build-name', $versionName,
        '--build-number', $buildNumber
    )
} finally {
    Pop-Location
}

if (-not (Test-Path -LiteralPath (Join-Path $releaseDirectory 'innocence_flutter.exe'))) {
    throw 'Flutter Windows Release output is incomplete.'
}

if (Test-Path -LiteralPath $outputDirectory) {
    Remove-Item -LiteralPath $outputDirectory -Recurse -Force
}
New-Item -ItemType Directory -Path $outputDirectory -Force | Out-Null

$portablePath = Join-Path $outputDirectory "Innocence-v$versionName-windows-x64-portable.zip"
Compress-Archive -Path (Join-Path $releaseDirectory '*') -DestinationPath $portablePath -CompressionLevel Optimal

if ([string]::IsNullOrWhiteSpace($InnoSetupCompiler)) {
    $compilerCandidates = @(
        (Join-Path $env:LOCALAPPDATA 'Programs\Inno Setup 6\ISCC.exe'),
        'C:\Program Files (x86)\Inno Setup 6\ISCC.exe',
        'C:\Program Files\Inno Setup 6\ISCC.exe'
    )
    $InnoSetupCompiler = $compilerCandidates |
        Where-Object { Test-Path -LiteralPath $_ -PathType Leaf } |
        Select-Object -First 1
}

if ([string]::IsNullOrWhiteSpace($InnoSetupCompiler) -or
    -not (Test-Path -LiteralPath $InnoSetupCompiler -PathType Leaf)) {
    throw 'Inno Setup 6 compiler was not found. Install JRSoftware.InnoSetup or pass -InnoSetupCompiler.'
}

$installerScript = Join-Path $windowsDirectory 'installer.iss'
Invoke-CheckedCommand -FilePath $InnoSetupCompiler -Arguments @(
    "/DMyAppVersion=$versionName",
    "/DMySourceDir=$releaseDirectory",
    "/DMyOutputDir=$outputDirectory",
    $installerScript
)

$installerPath = Join-Path $outputDirectory "Innocence-v$versionName-windows-x64-setup.exe"
if (-not (Test-Path -LiteralPath $installerPath -PathType Leaf)) {
    throw 'Inno Setup did not produce the expected installer.'
}

$artifacts = @($installerPath, $portablePath)
$checksumLines = foreach ($artifact in $artifacts) {
    $hash = (Get-FileHash -LiteralPath $artifact -Algorithm SHA256).Hash.ToLowerInvariant()
    "$hash  $([System.IO.Path]::GetFileName($artifact))"
}
$checksumPath = Join-Path $outputDirectory 'SHA256SUMS.txt'
Set-Content -LiteralPath $checksumPath -Value $checksumLines -Encoding utf8NoBOM

Write-Output "VERSION=$versionName+$buildNumber"
Write-Output "OUTPUT_DIRECTORY=$outputDirectory"
foreach ($artifact in @($installerPath, $portablePath, $checksumPath)) {
    $item = Get-Item -LiteralPath $artifact
    Write-Output "ARTIFACT=$($item.FullName)|SIZE=$($item.Length)"
}
