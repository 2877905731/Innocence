[CmdletBinding()]
param(
    [ValidateSet('doctor', 'create', 'prepare', 'analyze', 'kernel', 'build', 'ide')]
    [string]$Action = 'doctor',
    [string]$FlutterSdk = '',
    [string]$DevEcoHome = '',
    [ValidateSet('arm64', 'x64')]
    [string]$Architecture = 'arm64',
    [ValidateSet('debug', 'release')]
    [string]$BuildMode = 'debug',
    [switch]$Unsigned,
    [switch]$DirectGit,
    [string]$GitHelperPath = ''
)
$ErrorActionPreference = 'Stop'
$appRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$workRoot = [IO.Path]::GetFullPath((Join-Path $appRoot 'build/harmonyos-h0'))
$stageFolder = if ($Architecture -eq 'arm64') { 'app' } else { 'app-x64' }
if ($BuildMode -eq 'release') { $stageFolder += '-release' }
$stageRoot = Join-Path $workRoot $stageFolder
if (!$FlutterSdk) { $FlutterSdk = Join-Path $workRoot 'flutter-oh' }
if (!$DevEcoHome -and (Test-Path -LiteralPath (Join-Path $workRoot 'tools/DevEcoStudio26/sdk'))) {
    $DevEcoHome = Join-Path $workRoot 'tools/DevEcoStudio26'
}
$FlutterSdk = [IO.Path]::GetFullPath($FlutterSdk)
if ($DevEcoHome) { $DevEcoHome = [IO.Path]::GetFullPath($DevEcoHome) }
$flutterExe = Join-Path $FlutterSdk 'bin/flutter.bat'
foreach ($taskPath in @($workRoot, $FlutterSdk, $DevEcoHome)) {
    if ($taskPath -and [IO.Path]::GetPathRoot([IO.Path]::GetFullPath($taskPath)) -ne 'F:\') {
        throw '用户要求鸿蒙工具与构建文件全部存放在 F 盘；请提供 F 盘中的工具路径。'
    }
}
if (!(Test-Path -LiteralPath $flutterExe)) {
    throw '请提供 Flutter OH SDK 路径；锁定版本为 3.41.10-ohos-1.0.1。'
}

# Environment changes are limited to this process and restored on exit.
$savedEnvironment = @{}
function Set-TaskEnvironment([string]$Name, [string]$Value) {
    if ($Name -ieq 'PATH') { $Name = 'Path' }
    $existingEntry = Get-Item -LiteralPath "Env:$Name" -ErrorAction SilentlyContinue
    if ($existingEntry -and $Name -ine 'PATH') { $Name = $existingEntry.Name }
    if (!$savedEnvironment.ContainsKey($Name)) {
        $savedEnvironment[$Name] = [Environment]::GetEnvironmentVariable($Name, 'Process')
    }
    if ($Name -ieq 'PATH') {
        Get-ChildItem Env: | Where-Object { $_.Name -ieq 'PATH' } |
            ForEach-Object { Remove-Item -LiteralPath "Env:$($_.Name)" }
    }
    Set-Item -LiteralPath "Env:$Name" -Value $Value
}
function Invoke-TaskFlutter([string[]]$FlutterArguments) {
    & $flutterExe @FlutterArguments
    if ($LASTEXITCODE -ne 0) { throw "Flutter OH 命令失败，退出码 $LASTEXITCODE。" }
}

try {
    foreach ($folder in @('downloads', 'tools', 'temp', 'npm-cache', 'hvigor-home',
                          'ohpm-cache', 'task-home', 'task-home/AppData/Local',
                          'task-home/AppData/Roaming')) {
        New-Item -ItemType Directory -Path (Join-Path $workRoot $folder) -Force | Out-Null
    }
    Set-TaskEnvironment 'TEMP' (Join-Path $workRoot 'temp')
    Set-TaskEnvironment 'TMP' (Join-Path $workRoot 'temp')
    Set-TaskEnvironment 'npm_config_cache' (Join-Path $workRoot 'npm-cache')
    Set-TaskEnvironment 'HVIGOR_USER_HOME' (Join-Path $workRoot 'hvigor-home')
    # Node's Windows homedir and native tools use this task profile for logs/settings.
    Set-TaskEnvironment 'USERPROFILE' (Join-Path $workRoot 'task-home')
    Set-TaskEnvironment 'LOCALAPPDATA' ([IO.Path]::GetFullPath((Join-Path $workRoot 'task-home/AppData/Local')))
    Set-TaskEnvironment 'APPDATA' ([IO.Path]::GetFullPath((Join-Path $workRoot 'task-home/AppData/Roaming')))
    Set-TaskEnvironment 'PUB_CACHE' (Join-Path $workRoot 'pub-cache')
    Set-TaskEnvironment 'PUB_HOSTED_URL' 'https://pub.flutter-io.cn'
    Set-TaskEnvironment 'FLUTTER_STORAGE_BASE_URL' 'https://storage.flutter-io.cn'
    Set-TaskEnvironment 'FLUTTER_GIT_URL' 'https://atomgit.com/CPF-Flutter/flutter_flutter.git'
    if ($GitHelperPath) { Set-TaskEnvironment 'PATH' "$GitHelperPath;$env:PATH" }
    if ($DirectGit) {
        Set-TaskEnvironment 'GIT_CONFIG_COUNT' '5'
        Set-TaskEnvironment 'GIT_CONFIG_KEY_0' 'http.proxy'
        Set-TaskEnvironment 'GIT_CONFIG_VALUE_0' ''
        Set-TaskEnvironment 'GIT_CONFIG_KEY_1' 'https.proxy'
        Set-TaskEnvironment 'GIT_CONFIG_VALUE_1' ''
        Set-TaskEnvironment 'GIT_CONFIG_KEY_2' 'url.https://atomgit.com/CPF-Flutter/.insteadOf'
        Set-TaskEnvironment 'GIT_CONFIG_VALUE_2' 'https://gitcode.com/openharmony-sig/'
        Set-TaskEnvironment 'GIT_CONFIG_KEY_3' 'url.https://atomgit.com/CPF-Flutter/.insteadOf'
        Set-TaskEnvironment 'GIT_CONFIG_VALUE_3' 'https://gitcode.com/openharmony-tpc/'
        Set-TaskEnvironment 'GIT_CONFIG_KEY_4' 'core.longpaths'
        Set-TaskEnvironment 'GIT_CONFIG_VALUE_4' 'true'
    }
    if ($DevEcoHome) {
        Set-TaskEnvironment 'NODE_HOME' ([IO.Path]::GetFullPath((Join-Path $DevEcoHome 'tools/node')))
        Set-TaskEnvironment 'DEVECO_SDK_HOME' (Join-Path $DevEcoHome 'sdk')
        $toolPaths = @('tools/ohpm/bin', 'tools/hvigor/bin', 'tools/node',
                      'tools/node/bin', 'bin', 'sdk/default/openharmony/toolchains') |
            ForEach-Object { [IO.Path]::GetFullPath((Join-Path $DevEcoHome $_)) }
        Set-TaskEnvironment 'PATH' (($toolPaths -join ';') + ";$env:PATH")
        if (Test-Path -LiteralPath (Join-Path $DevEcoHome 'jbr')) {
            Set-TaskEnvironment 'JAVA_HOME' (Join-Path $DevEcoHome 'jbr')
        }
    }
    Set-TaskEnvironment 'PATH' ((Join-Path $FlutterSdk 'bin') + ";$env:PATH")
    if ($Action -eq 'ide') {
        if (!$DevEcoHome -or !(Test-Path -LiteralPath (Join-Path $DevEcoHome 'bin/devecostudio64.exe'))) {
            throw '请先在 F 盘准备 DevEco Studio。'
        }
        if (!(Test-Path -LiteralPath (Join-Path $stageRoot 'ohos/build-profile.json5'))) {
            throw '先运行 prepare 或 build 生成暂存工程。'
        }
        # The visible IDE lets the user complete account authorization and signing.
        Start-Process -FilePath (Join-Path $DevEcoHome 'bin/devecostudio64.exe') `
            -ArgumentList ([IO.Path]::GetFullPath((Join-Path $stageRoot 'ohos'))) `
            -WindowStyle Normal | Out-Null
        return
    }
    if ($Action -eq 'doctor') { Invoke-TaskFlutter @('doctor', '-v'); return }
    if ($Action -eq 'create') {
        if (Test-Path -LiteralPath (Join-Path $stageRoot 'ohos')) {
            throw '鸿蒙暂存工程已存在；使用 prepare 同步共享代码。'
        }
        Invoke-TaskFlutter @('create', '--platforms', 'ohos', '--no-pub',
                            '--org', 'com.innocence.tablet',
                            '--project-name', 'innocence_flutter', $stageRoot)
        return
    }
    if (!(Test-Path -LiteralPath (Join-Path $appRoot 'ohos'))) {
        throw '仓库中没有 ohos 工程；先 create 并完成原生工程配置。'
    }
    New-Item -ItemType Directory -Path $stageRoot -Force | Out-Null
    foreach ($folder in @('lib', 'assets', 'shaders', 'ohos')) {
        $sourceFolder = Join-Path $appRoot $folder
        if (Test-Path -LiteralPath $sourceFolder) {
            if ($folder -eq 'ohos') {
                $stageOhos = Join-Path $stageRoot 'ohos'
                New-Item -ItemType Directory -Path $stageOhos -Force | Out-Null
                $stageProfile = Join-Path $stageOhos 'build-profile.json5'
                $keepSigningProfile = (Test-Path -LiteralPath $stageProfile) -and
                    ([IO.File]::ReadAllText($stageProfile) -match 'signingConfigs[^:]*:\s*\[\s*\{')
                foreach ($item in Get-ChildItem -LiteralPath $sourceFolder -Force) {
                    if ($item.Name -eq 'build-profile.json5' -and $keepSigningProfile) {
                        Write-Host '保留暂存工程内由 DevEco 生成的签名配置；不写回仓库。'
                        continue
                    }
                    Copy-Item -LiteralPath $item.FullName -Destination $stageOhos -Recurse -Force
                }
            } else {
                Copy-Item -LiteralPath $sourceFolder -Destination $stageRoot -Recurse -Force
            }
        }
    }
    Copy-Item -LiteralPath (Join-Path $appRoot 'pubspec.yaml') -Destination $stageRoot -Force
    Copy-Item -LiteralPath (Join-Path $appRoot 'harmonyos/pubspec_overrides.yaml') -Destination $stageRoot -Force
    if ($BuildMode -eq 'release') {
        # This accepted edition is local-only. Do not ship the Debug template's network permission.
        $stageModulePath = Join-Path $stageRoot 'ohos/entry/src/main/module.json5'
        $stageModule = [IO.File]::ReadAllText($stageModulePath)
        $internetPermission = '\{"name"\s*:\s*"ohos\.permission\.INTERNET"\},?'
        if ([regex]::Matches($stageModule, $internetPermission).Count -gt 1) {
            throw '原生网络权限声明重复，请核对离线发行配置。'
        }
        $stageModule = [regex]::Replace($stageModule, $internetPermission, '')
        [IO.File]::WriteAllText($stageModulePath, $stageModule, [Text.UTF8Encoding]::new($false))
    }
    $ohpmCachePath = (Join-Path $workRoot 'ohpm-cache').Replace('\', '/')
    [IO.File]::WriteAllText((Join-Path $stageRoot 'ohos/.ohpmrc'),
        "registry=https://ohpm.openharmony.cn/ohpm/`ncache=$ohpmCachePath`nstrict_ssl=true`n",
        [Text.UTF8Encoding]::new($false))
    Push-Location $stageRoot
    try {
        if ($Action -eq 'kernel') {
            if (!(Test-Path -LiteralPath '.dart_tool/package_config.json')) {
                throw '先运行 prepare 解析依赖；kernel 不生成原生插件或 HAP。'
            }
            $kernelFolder = if ($Architecture -eq 'arm64') { 'kernel-check' } else { 'kernel-check-x64' }
            Invoke-TaskFlutter @('assemble', "--output=../$kernelFolder",
                "--define=TargetPlatform=ohos-$Architecture", '--define=BuildMode=debug',
                'kernel_snapshot_program')
            return
        }
        Invoke-TaskFlutter @('pub', 'get')
        if ($Action -eq 'analyze') { Invoke-TaskFlutter @('analyze', '--no-pub'); return }
        if ($Action -eq 'build') {
            # Native online/device-slot contracts and key vault are a later gate.
            $hapArguments = @('build', 'hap', "--$BuildMode",
                "--target-platform=ohos-$Architecture",
                '--dart-define=INNOCENCE_TARGET_PLATFORM=harmonyos',
                '--dart-define=INNOCENCE_OFFLINE_ONLY=true')
            if ($Unsigned) { $hapArguments += '--no-codesign' }
            Invoke-TaskFlutter $hapArguments
        }
    } finally { Pop-Location }
} finally {
    foreach ($name in $savedEnvironment.Keys) {
        if ($null -eq $savedEnvironment[$name]) {
            Remove-Item -LiteralPath "Env:$name" -ErrorAction SilentlyContinue
        } else {
            Set-Item -LiteralPath "Env:$name" -Value $savedEnvironment[$name]
        }
    }
}
