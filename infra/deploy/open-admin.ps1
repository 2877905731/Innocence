[CmdletBinding()]
param([switch]$Watch, [switch]$NoOpen, [string]$Identity = '', [int]$Port = 18080)
$ErrorActionPreference = 'Stop'
if ($Port -lt 1024 -or $Port -gt 65535) { throw 'Invalid local port.' }
$repository = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '../..'))
if (!$Identity) { $Identity = Join-Path $repository 'build/deployment/ssh-control/id_ed25519_innocence' }
$Identity = [IO.Path]::GetFullPath($Identity)
if (!(Test-Path -LiteralPath $Identity -PathType Leaf)) { throw 'Dedicated SSH identity is unavailable.' }
$runtime = Join-Path $repository 'build/deployment/ssh-control'
New-Item -ItemType Directory -Path $runtime -Force | Out-Null
$pidFile = Join-Path $runtime "admin-tunnel-$Port.pid"
$baseUrl = "http://127.0.0.1:$Port/"
Add-Type -AssemblyName System.Net.Http
$handler = [System.Net.Http.HttpClientHandler]::new()
$handler.UseProxy = $false
$http = [System.Net.Http.HttpClient]::new($handler)
$http.Timeout = [TimeSpan]::FromSeconds(4)
function Test-AdminTunnel {
    try {
        $page = $http.GetAsync($baseUrl).GetAwaiter().GetResult()
        $auth = $http.GetAsync($baseUrl + 'api/admin/v1/auth/me').GetAwaiter().GetResult()
        try { return ([int]$page.StatusCode -eq 200 -and [int]$auth.StatusCode -eq 401) }
        finally { $page.Dispose(); $auth.Dispose() }
    } catch { return $false }
}
if (!$Watch) {
    $watcherRunning = $false
    if (Test-Path -LiteralPath $pidFile) {
        $watcherId = 0
        if ([int]::TryParse([IO.File]::ReadAllText($pidFile).Trim(), [ref]$watcherId)) {
            $processInfo = Get-CimInstance Win32_Process -Filter "ProcessId=$watcherId" -ErrorAction SilentlyContinue
            $watcherRunning = $processInfo -and $processInfo.CommandLine -and $processInfo.CommandLine.Contains($PSCommandPath) -and $processInfo.CommandLine.Contains('-Watch')
        }
    }
    if (!$watcherRunning) {
        $powerShell = (Get-Process -Id $PID).Path
        Start-Process -FilePath $powerShell -ArgumentList @('-NoProfile', '-File', ('"' + $PSCommandPath + '"'), '-Watch', '-Identity', ('"' + $Identity + '"'), '-Port', "$Port") -WindowStyle Hidden | Out-Null
    }
    $ready = $false
    for ($attempt=0; $attempt -lt 8; $attempt++) {
        if (Test-AdminTunnel) { $ready=$true; break }
        Start-Sleep -Seconds 2
    }
    $http.Dispose()
    if (!$ready) { throw 'The admin tunnel is reconnecting. Please run this launcher again shortly.' }
    if (!$NoOpen) { Start-Process $baseUrl | Out-Null }
    Write-Output "Admin ready: $baseUrl (automatic reconnect enabled; loopback only)."
    return
}
$mutex = [Threading.Mutex]::new($false, "Local\InnocenceAdminTunnel$Port")
if (!$mutex.WaitOne(0)) { $http.Dispose(); $mutex.Dispose(); return }
$ownedSsh = $null
try {
    [IO.File]::WriteAllText($pidFile, "$PID", [Text.UTF8Encoding]::new($false))
    $ssh = (Get-Command ssh.exe -ErrorAction Stop).Source
    while ($true) {
        if (!(Test-AdminTunnel)) {
            if ($ownedSsh -and !$ownedSsh.HasExited) { $ownedSsh.Kill(); $ownedSsh.WaitForExit() }
            $ownedSsh = Start-Process -FilePath $ssh -ArgumentList @('-N', '-o', 'BatchMode=yes', '-o', 'IdentitiesOnly=yes', '-o', 'StrictHostKeyChecking=yes', '-o', 'ExitOnForwardFailure=yes', '-o', 'ServerAliveInterval=15', '-o', 'ServerAliveCountMax=3', '-o', 'ConnectTimeout=10', '-i', ('"' + $Identity + '"'), '-p', '22', '-L', "127.0.0.1:${Port}:127.0.0.1:18081", 'root@85.189.40.87') -WindowStyle Hidden -PassThru -RedirectStandardError (Join-Path $runtime "admin-tunnel-$Port.stderr.log")
        }
        Start-Sleep -Seconds 15
    }
} finally {
    if ($ownedSsh -and !$ownedSsh.HasExited) { $ownedSsh.Kill() }
    $http.Dispose(); $mutex.ReleaseMutex(); $mutex.Dispose()
}
