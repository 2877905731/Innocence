[CmdletBinding()]
param(
    [string]$SigningDirectory = (Join-Path $env:LOCALAPPDATA 'Innocence/release-signing'),
    [switch]$SkipVerification
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

function Invoke-Checked {
    param([string]$Command, [string[]]$Arguments)
    & $Command @Arguments
    if ($LASTEXITCODE -ne 0) { throw "$Command failed with exit code $LASTEXITCODE." }
}

$appDirectory = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$pubspec = Get-Content -LiteralPath (Join-Path $appDirectory 'pubspec.yaml') -Raw
$version = [regex]::Match($pubspec, '(?m)^version:\s*(?<name>\d+\.\d+\.\d+)\+(?<build>\d+)\s*$')
if (-not $version.Success) { throw 'pubspec.yaml requires a semantic version and build number.' }
$versionName = $version.Groups['name'].Value
$buildNumber = $version.Groups['build'].Value
$releasesRoot = [System.IO.Path]::GetFullPath((Join-Path $appDirectory 'build/releases'))
$outputDirectory = [System.IO.Path]::GetFullPath((Join-Path $releasesRoot "v$versionName"))
if (-not $outputDirectory.StartsWith($releasesRoot + [System.IO.Path]::DirectorySeparatorChar,
        [System.StringComparison]::OrdinalIgnoreCase)) { throw 'Invalid release output directory.' }

$signingVariables = @('INNOCENCE_ANDROID_KEYSTORE', 'INNOCENCE_ANDROID_STORE_PASSWORD',
    'INNOCENCE_ANDROID_KEY_ALIAS', 'INNOCENCE_ANDROID_KEY_PASSWORD', 'GRADLE_OPTS')
$previousEnvironment = @{}
foreach ($name in $signingVariables) {
    $previousEnvironment[$name] = [Environment]::GetEnvironmentVariable($name, 'Process')
}

try {
    if ([string]::IsNullOrWhiteSpace($env:INNOCENCE_ANDROID_KEYSTORE)) {
        $credentialPath = Join-Path $SigningDirectory 'signing-credentials.clixml'
        $keystorePath = Join-Path $SigningDirectory 'innocence-android-release.p12'
        if (-not (Test-Path -LiteralPath $credentialPath) -or
            -not (Test-Path -LiteralPath $keystorePath)) {
            throw 'Release signing material is missing. Supply signing environment variables or the protected local signing directory.'
        }
        $credential = Import-Clixml -LiteralPath $credentialPath
        $env:INNOCENCE_ANDROID_KEYSTORE = $keystorePath
        $env:INNOCENCE_ANDROID_KEY_ALIAS = $credential.UserName
        $env:INNOCENCE_ANDROID_STORE_PASSWORD = $credential.GetNetworkCredential().Password
        $env:INNOCENCE_ANDROID_KEY_PASSWORD = $env:INNOCENCE_ANDROID_STORE_PASSWORD
    }
    foreach ($name in $signingVariables | Where-Object { $_ -ne 'GRADLE_OPTS' }) {
        if ([string]::IsNullOrWhiteSpace([Environment]::GetEnvironmentVariable($name, 'Process'))) {
            throw "Missing signing environment variable: $name"
        }
    }
    if (-not (Test-Path -LiteralPath $env:INNOCENCE_ANDROID_KEYSTORE -PathType Leaf)) {
        throw 'Release keystore file does not exist.'
    }
    $env:GRADLE_OPTS = "$($previousEnvironment['GRADLE_OPTS']) -Dorg.gradle.project.kotlin.incremental=false"
    $dependencyUri = [Uri]'https://dl.google.com'
    $systemProxy = [System.Net.Http.HttpClient]::DefaultProxy
    if (-not $systemProxy.IsBypassed($dependencyUri)) {
        $proxyUri = $systemProxy.GetProxy($dependencyUri)
        if ($proxyUri.Scheme -in @('http', 'https')) {
            $env:GRADLE_OPTS += " -Dhttp.proxyHost=$($proxyUri.Host) -Dhttp.proxyPort=$($proxyUri.Port) -Dhttps.proxyHost=$($proxyUri.Host) -Dhttps.proxyPort=$($proxyUri.Port)"
        }
    }
    Push-Location $appDirectory
    try {
        if (-not $SkipVerification) {
            Invoke-Checked 'flutter' @('analyze', '--no-pub')
            Invoke-Checked 'flutter' @('test', '--no-pub')
            Invoke-Checked 'flutter' @('test', '--no-pub',
                '--dart-define=INNOCENCE_OFFLINE_ONLY=true', 'test/app/offline_release_test.dart')
        }
        Invoke-Checked 'flutter' @('build', 'apk', '--release', '--no-pub',
            '--build-name', $versionName, '--build-number', $buildNumber,
            '--dart-define=INNOCENCE_OFFLINE_ONLY=true')
    } finally { Pop-Location }

    $apkPath = Join-Path $appDirectory 'build/app/outputs/flutter-apk/app-release.apk'
    if (-not (Test-Path -LiteralPath $apkPath)) { throw 'Android release output is missing.' }
    $sdkDirectory = if ($env:ANDROID_HOME) { $env:ANDROID_HOME } else {
        Join-Path $env:LOCALAPPDATA 'Android/sdk'
    }
    $buildTools = Get-ChildItem -LiteralPath (Join-Path $sdkDirectory 'build-tools') -Directory |
        Where-Object { Test-Path -LiteralPath (Join-Path $_.FullName 'apksigner.bat') } |
        Sort-Object Name -Descending | Select-Object -First 1
    if (-not $buildTools) { throw 'Android SDK build-tools are missing.' }
    Invoke-Checked (Join-Path $buildTools.FullName 'apksigner.bat') @('verify', '--verbose', '--print-certs', $apkPath)
    $badging = & (Join-Path $buildTools.FullName 'aapt.exe') dump badging $apkPath
    if ($LASTEXITCODE -ne 0) { throw 'APK metadata verification failed.' }
    if (-not ($badging -match "versionCode='$buildNumber' versionName='$versionName'")) {
        throw 'APK version does not match pubspec.yaml.'
    }
    if ($badging -match '^application-debuggable') { throw 'Refusing to package a debuggable APK.' }
    $permissions = & (Join-Path $buildTools.FullName 'aapt.exe') dump permissions $apkPath
    if ($LASTEXITCODE -ne 0) { throw 'APK permission verification failed.' }
    if ($permissions -match 'android.permission.INTERNET') {
        throw 'Offline Android release must not request INTERNET permission.'
    }
    New-Item -ItemType Directory -Path $outputDirectory -Force | Out-Null
    $artifact = Join-Path $outputDirectory "Innocence-v$versionName-android-offline.apk"
    Copy-Item -LiteralPath $apkPath -Destination $artifact -Force
    $checksumLines = Get-ChildItem -LiteralPath $outputDirectory -File |
        Where-Object { $_.Extension -in @('.exe', '.zip', '.apk', '.aab') } |
        Sort-Object Name | ForEach-Object {
            "$( (Get-FileHash -LiteralPath $_.FullName -Algorithm SHA256).Hash.ToLowerInvariant())  $($_.Name)"
        }
    Set-Content -LiteralPath (Join-Path $outputDirectory 'SHA256SUMS.txt') -Value $checksumLines -Encoding utf8NoBOM
    Write-Output "VERSION=$versionName+$buildNumber"
    Write-Output "ANDROID_ARTIFACT=$artifact"
} finally {
    foreach ($name in $signingVariables) {
        [Environment]::SetEnvironmentVariable($name, $previousEnvironment[$name], 'Process')
    }
}
