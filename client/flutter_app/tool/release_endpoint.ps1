function Resolve-InnocenceReleaseApiBaseUrl {
    param([Parameter(Mandatory = $true)][string]$AppDirectory, [string]$RequestedUrl)
    $candidate = $RequestedUrl
    if ([string]::IsNullOrWhiteSpace($candidate)) {
        $configuration = Get-Content -LiteralPath (Join-Path $AppDirectory 'config/production.json') -Raw | ConvertFrom-Json
        $candidate = [string]$configuration.INNOCENCE_API_BASE_URL
    }
    $parsed = $null
    if (-not [Uri]::TryCreate($candidate.Trim(), [UriKind]::Absolute, [ref]$parsed) -or
        $parsed.Scheme -ne 'https' -or $parsed.IsLoopback -or
        $parsed.UserInfo -or $parsed.Query -or $parsed.Fragment) {
        throw 'An online release requires a non-loopback HTTPS API URL without credentials, query or fragment.'
    }
    if ($parsed.AbsolutePath -notin @('/', '/api/app/v1', '/api/app/v1/')) {
        throw 'The release API URL must use the /api/app/v1/ contract path.'
    }
    return $parsed.GetLeftPart([UriPartial]::Authority) + '/api/app/v1/'
}
