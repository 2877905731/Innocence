[CmdletBinding()]
param([string]$BaseUrl = 'http://127.0.0.1:18080')

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$endpoint = $null
if (-not [Uri]::TryCreate($BaseUrl, [UriKind]::Absolute, [ref]$endpoint) -or
    -not $endpoint.IsLoopback -or $endpoint.Scheme -ne 'http' -or
    $endpoint.UserInfo -or $endpoint.Query -or $endpoint.Fragment -or
    $endpoint.AbsolutePath -ne '/') {
    throw 'Use the local SSH tunnel URL, such as http://127.0.0.1:18080.'
}
$origin = $endpoint.GetLeftPart([UriPartial]::Authority)

function Read-PrivateText([string]$Prompt) {
    $secure = Read-Host -Prompt $Prompt -AsSecureString
    $pointer = [IntPtr]::Zero
    try {
        $pointer = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($secure)
        return [Runtime.InteropServices.Marshal]::PtrToStringBSTR($pointer)
    } finally {
        if ($pointer -ne [IntPtr]::Zero) {
            [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($pointer)
        }
        $secure.Dispose()
    }
}

function Invoke-AuthPost([string]$Path, [hashtable]$Body, [hashtable]$Headers = @{}) {
    $request = @{
        Uri = "$origin/api/app/v1/auth/$Path"
        Method = 'Post'
        ContentType = 'application/json; charset=utf-8'
        Body = [Text.Encoding]::UTF8.GetBytes(($Body | ConvertTo-Json -Compress))
        Headers = $Headers
        TimeoutSec = 30
        MaximumRedirection = 0
        ErrorAction = 'Stop'
    }
    try {
        $response = Invoke-RestMethod @request
    } catch {
        $status = 'unavailable'
        if ($_.Exception.PSObject.Properties['Response'] -and $_.Exception.Response) {
            $status = [string][int]$_.Exception.Response.StatusCode
        }
        throw "Request failed at $Path (HTTP $status). Check the tunnel, SMTP settings or verification code; no response body was printed."
    } finally {
        $request.Body = $null
    }
    if (-not $response -or -not $response.PSObject.Properties['code'] -or
        -not $response.PSObject.Properties['data'] -or $response.code -ne 0) {
        throw "Unexpected API response at $Path; no response body was printed."
    }
    return $response.data
}

$password = $confirmation = $code = $payload = $session = $null
try {
    $email = (Read-Host -Prompt 'Email (must match INNOCENCE_ADMIN_EMAILS on the server)').Trim()
    if ($email -notmatch '^[^@\s]+@[^@\s]+\.[^@\s]+$') {
        throw 'Enter a valid registration email.'
    }
    $null = Invoke-AuthPost -Path 'email/send-register-code' -Body @{email = $email}
    Write-Host 'The server accepted the email request. Check your inbox and spam folder.'
    $code = Read-PrivateText 'Six-digit email verification code (hidden)'
    if ($code -notmatch '^[0-9]{6}$') {
        throw 'The verification code must contain exactly six digits.'
    }
    $password = Read-PrivateText 'New Innocence password, 6-32 characters (hidden)'
    $confirmation = Read-PrivateText 'Repeat the new password (hidden)'
    if ($password.Length -lt 6 -or $password.Length -gt 32 -or
        -not [string]::Equals($password, $confirmation, [StringComparison]::Ordinal)) {
        throw 'Passwords must match and contain 6-32 characters.'
    }
    $deviceId = 'first-registration-' + [Guid]::NewGuid().ToString('N')
    $payload = @{email = $email; emailCode = $code; password = $password; deviceType = 'windows'; deviceId = $deviceId}
    $session = Invoke-AuthPost -Path 'email/register' -Body $payload
    if (-not $session -or -not $session.PSObject.Properties['accessToken'] -or
        [string]::IsNullOrWhiteSpace($session.accessToken)) {
        throw 'The registration response did not contain the expected session. Verify account state before retrying.'
    }
    try {
        $null = Invoke-AuthPost -Path 'logout' -Body @{} -Headers @{
            Authorization = 'Bearer ' + $session.accessToken
            'X-Device-Type' = 'windows'
            'X-Device-Id' = $deviceId
        }
    } catch {
        Write-Warning 'Account created, but the temporary desktop session could not be closed. Admin login uses its own session slot.'
    }
    Write-Host 'Account created. Open the admin website and sign in. Admin access still requires the server email whitelist.'
} finally {
    if ($payload) { $payload.Clear() }
    $password = $confirmation = $code = $payload = $session = $null
}
