[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$Title,

    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$BodyPath,

    [string]$Slug,

    [string]$Excerpt,

    [string[]]$Categories = @("notes"),

    [DateTimeOffset]$PublishAt = [DateTimeOffset]::Now,

    [switch]$Push,

    [string]$Remote = "origin",

    [string]$Branch,

    [string]$CommitMessage,

    [switch]$SkipDeploymentCheck,

    [ValidateRange(1, 30)]
    [int]$DeploymentTimeoutMinutes = 5
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function ConvertTo-YamlDoubleQuoted {
    param([Parameter(Mandatory = $true)][string]$Value)

    $singleLine = $Value.Replace("`r", " ").Replace("`n", " ")
    $escaped = $singleLine.Replace("\", "\\").Replace('"', '\"')
    return '"' + $escaped + '"'
}

function ConvertTo-Slug {
    param([Parameter(Mandatory = $true)][string]$Value)

    $normalized = $Value.Normalize([Text.NormalizationForm]::FormD)
    $builder = [Text.StringBuilder]::new()

    foreach ($character in $normalized.ToCharArray()) {
        $category = [Globalization.CharUnicodeInfo]::GetUnicodeCategory($character)
        if ($category -ne [Globalization.UnicodeCategory]::NonSpacingMark) {
            [void]$builder.Append($character)
        }
    }

    $plain = $builder.ToString().Normalize([Text.NormalizationForm]::FormC)
    $plain = $plain.ToLowerInvariant()
    $plain = [regex]::Replace($plain, "[^\p{L}\p{Nd}]+", "-")
    return $plain.Trim("-")
}

function Get-SeoulTime {
    param([Parameter(Mandatory = $true)][DateTimeOffset]$Value)

    try {
        $timeZone = [TimeZoneInfo]::FindSystemTimeZoneById("Asia/Seoul")
    }
    catch {
        $timeZone = [TimeZoneInfo]::FindSystemTimeZoneById("Korea Standard Time")
    }

    return [TimeZoneInfo]::ConvertTime($Value, $timeZone)
}

function Assert-LastExitCode {
    param([Parameter(Mandatory = $true)][string]$Operation)

    if ($LASTEXITCODE -ne 0) {
        throw "$Operation failed with exit code $LASTEXITCODE."
    }
}

function Get-GitHubRepository {
    param(
        [Parameter(Mandatory = $true)][string]$RepositoryRoot,
        [Parameter(Mandatory = $true)][string]$RemoteName
    )

    $remoteUrl = (& git -C $RepositoryRoot remote get-url $RemoteName).Trim()
    Assert-LastExitCode "Reading Git remote"

    $match = [regex]::Match(
        $remoteUrl,
        "github\.com[/:](?<owner>[^/]+)/(?<repo>[^/]+?)(?:\.git)?$"
    )

    if (-not $match.Success) {
        throw "Cannot derive a GitHub repository from remote URL: $remoteUrl"
    }

    return "$($match.Groups['owner'].Value)/$($match.Groups['repo'].Value)"
}

function Wait-GitHubPagesDeployment {
    param(
        [Parameter(Mandatory = $true)][string]$Repository,
        [Parameter(Mandatory = $true)][string]$CommitSha,
        [Parameter(Mandatory = $true)][int]$TimeoutMinutes
    )

    $headers = @{
        "User-Agent" = "zendoclab-publish-post"
        "Accept" = "application/vnd.github+json"
    }
    $deadline = [DateTimeOffset]::UtcNow.AddMinutes($TimeoutMinutes)
    $run = $null

    Write-Host "Waiting for GitHub Pages deployment..."

    do {
        $runs = Invoke-RestMethod `
            -Uri "https://api.github.com/repos/$Repository/actions/runs?per_page=10" `
            -Headers $headers

        $run = $runs.workflow_runs |
            Where-Object { $_.head_sha -eq $CommitSha } |
            Select-Object -First 1

        if ($null -ne $run) {
            Write-Host "  $($run.status)" -ForegroundColor DarkGray
            if ($run.status -eq "completed") {
                if ($run.conclusion -ne "success") {
                    throw "GitHub Pages deployment failed: $($run.html_url)"
                }
                Write-Host "Deployment succeeded: $($run.html_url)" -ForegroundColor Green
                return
            }
        }

        Start-Sleep -Seconds 3
    } while ([DateTimeOffset]::UtcNow -lt $deadline)

    throw "Timed out waiting for the GitHub Pages deployment."
}

function Wait-PostUrl {
    param(
        [Parameter(Mandatory = $true)][string]$Url,
        [Parameter(Mandatory = $true)][string]$CommitSha,
        [Parameter(Mandatory = $true)][int]$TimeoutMinutes
    )

    $deadline = [DateTimeOffset]::UtcNow.AddMinutes($TimeoutMinutes)
    $client = [Net.Http.HttpClient]::new()
    $client.DefaultRequestHeaders.UserAgent.ParseAdd("zendoclab-publish-post")

    try {
        do {
            $checkUrl = "${Url}?v=$CommitSha"
            $response = $null
            try {
                $response = $client.GetAsync($checkUrl).GetAwaiter().GetResult()
                if ([int]$response.StatusCode -eq 200) {
                    Write-Host "Post is live: $Url" -ForegroundColor Green
                    return
                }
            }
            catch {
                Write-Host "  Site is not ready yet." -ForegroundColor DarkGray
            }
            finally {
                if ($null -ne $response) {
                    $response.Dispose()
                    $response = $null
                }
            }

            Start-Sleep -Seconds 3
        } while ([DateTimeOffset]::UtcNow -lt $deadline)
    }
    finally {
        $client.Dispose()
    }

    throw "Deployment completed, but the post did not return HTTP 200: $Url"
}

$scriptDirectory = Split-Path -Parent $MyInvocation.MyCommand.Path
$repositoryCandidate = Split-Path -Parent $scriptDirectory
$repositoryRoot = (& git -C $repositoryCandidate rev-parse --show-toplevel).Trim()
Assert-LastExitCode "Finding repository root"

$resolvedBodyPath = (Resolve-Path -LiteralPath $BodyPath).Path
$body = [IO.File]::ReadAllText($resolvedBodyPath)
$normalizedBody = $body.Replace("`r`n", "`n").Replace("`r", "`n").Trim()

if ($normalizedBody.StartsWith("---")) {
    throw "BodyPath must contain Markdown body only, without Jekyll front matter."
}

$seoulTime = Get-SeoulTime $PublishAt
$effectiveSlug = if ([string]::IsNullOrWhiteSpace($Slug)) {
    ConvertTo-Slug $Title
}
else {
    ConvertTo-Slug $Slug
}

if ([string]::IsNullOrWhiteSpace($effectiveSlug)) {
    throw "Could not generate a slug. Supply an explicit -Slug value."
}

$categoryList = @(
    $Categories |
        ForEach-Object { $_.Trim().ToLowerInvariant() } |
        Where-Object { -not [string]::IsNullOrWhiteSpace($_) }
)

if ($categoryList.Count -eq 0) {
    throw "At least one category is required."
}

foreach ($category in $categoryList) {
    if ($category -notmatch "^[a-z0-9]+(?:-[a-z0-9]+)*$") {
        throw "Invalid category '$category'. Use lowercase letters, numbers, and hyphens."
    }
}

$dateOffset = $seoulTime.ToString("zzz").Replace(":", "")
$dateValue = "$($seoulTime.ToString('yyyy-MM-dd HH:mm:ss')) $dateOffset"
$fileName = "$($seoulTime.ToString('yyyy-MM-dd'))-$effectiveSlug.md"
$postDirectory = Join-Path $repositoryRoot "_posts"
$postPath = Join-Path $postDirectory $fileName

if (Test-Path -LiteralPath $postPath) {
    throw "Post already exists: $postPath"
}

$frontMatter = [Collections.Generic.List[string]]::new()
$frontMatter.Add("---")
$frontMatter.Add("layout: post")
$frontMatter.Add("title: $(ConvertTo-YamlDoubleQuoted $Title)")
$frontMatter.Add("date: $dateValue")
if (-not [string]::IsNullOrWhiteSpace($Excerpt)) {
    $frontMatter.Add("excerpt: $(ConvertTo-YamlDoubleQuoted $Excerpt)")
}
$frontMatter.Add("categories: [$($categoryList -join ', ')]")
$frontMatter.Add("---")
$frontMatter.Add("")
$frontMatter.Add($normalizedBody)
$frontMatter.Add("")

$content = $frontMatter -join "`n"
$utf8WithoutBom = [Text.UTF8Encoding]::new($false)
[IO.File]::WriteAllText($postPath, $content, $utf8WithoutBom)

$relativePostPath = $postPath.Substring($repositoryRoot.Length)
$relativePostPath = $relativePostPath.TrimStart([char[]]"\/").Replace("\", "/")

Write-Host "Created: $relativePostPath" -ForegroundColor Green
Write-Host "Publish time: $dateValue"

if (-not $Push) {
    Write-Host "Review the file, then rerun with a new slug and -Push or commit it manually."
    return
}

& git -C $repositoryRoot diff --check
Assert-LastExitCode "Git diff validation"

& git -C $repositoryRoot add -- $relativePostPath
Assert-LastExitCode "Staging post"

if ([string]::IsNullOrWhiteSpace($CommitMessage)) {
    $CommitMessage = "Publish post: $Title"
}

& git -C $repositoryRoot commit --only -m $CommitMessage -- $relativePostPath
Assert-LastExitCode "Committing post"

if ([string]::IsNullOrWhiteSpace($Branch)) {
    $Branch = (& git -C $repositoryRoot branch --show-current).Trim()
    Assert-LastExitCode "Reading current branch"
}

if ([string]::IsNullOrWhiteSpace($Branch)) {
    throw "Cannot determine the current branch. Supply -Branch explicitly."
}

& git -C $repositoryRoot push $Remote $Branch
Assert-LastExitCode "Pushing post"

$commitSha = (& git -C $repositoryRoot rev-parse HEAD).Trim()
Assert-LastExitCode "Reading commit SHA"

if ($SkipDeploymentCheck) {
    Write-Host "Push completed at $commitSha." -ForegroundColor Green
    return
}

$githubRepository = Get-GitHubRepository $repositoryRoot $Remote
Wait-GitHubPagesDeployment $githubRepository $commitSha $DeploymentTimeoutMinutes

$configPath = Join-Path $repositoryRoot "_config.yml"
$config = [IO.File]::ReadAllText($configPath)
$urlMatch = [regex]::Match($config, '(?m)^url:\s*["'']?([^"''\r\n]+)')
if (-not $urlMatch.Success) {
    throw "Cannot read the site URL from _config.yml."
}

$siteUrl = $urlMatch.Groups[1].Value.Trim().TrimEnd("/")
$categoryPath = ($categoryList -join "/")
$postUrl = "${siteUrl}/${categoryPath}/$($seoulTime.ToString('yyyy/MM/dd'))/$effectiveSlug.html"

Wait-PostUrl $postUrl $commitSha $DeploymentTimeoutMinutes
