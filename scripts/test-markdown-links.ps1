[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"
$repoRoot = Split-Path -Parent $PSScriptRoot
$markdownFiles = Get-ChildItem -Path $repoRoot -Filter "*.md" -File -Recurse |
    Where-Object { $_.FullName -notmatch '[\\/]\.terraform[\\/]' }
$brokenLinks = [System.Collections.Generic.List[string]]::new()
$linkPattern = '!?' + '\[[^\]]*\]\((?<target><[^>]+>|[^\s\)]+)(?:\s+["''][^"'']*["''])?\)'

foreach ($markdownFile in $markdownFiles) {
    $content = Get-Content -LiteralPath $markdownFile.FullName -Raw
    foreach ($match in [regex]::Matches($content, $linkPattern)) {
        $target = $match.Groups['target'].Value.Trim('<', '>')
        if ($target -match '^(?:https?://|mailto:|tel:|#)' -or $target -eq '') {
            continue
        }

        $pathOnly = [System.Uri]::UnescapeDataString(($target -split '[?#]', 2)[0])
        if ($pathOnly -eq '') {
            continue
        }

        $resolvedPath = if ($pathOnly.StartsWith('/')) {
            Join-Path $repoRoot $pathOnly.TrimStart('/')
        }
        else {
            Join-Path $markdownFile.DirectoryName $pathOnly
        }

        if (-not (Test-Path -LiteralPath $resolvedPath)) {
            $relativeFile = [System.IO.Path]::GetRelativePath($repoRoot, $markdownFile.FullName).Replace('\', '/')
            $brokenLinks.Add("${relativeFile}: $target")
        }
    }
}

if ($brokenLinks.Count -gt 0) {
    $brokenLinks | Sort-Object -Unique | ForEach-Object { Write-Error "Broken Markdown link: $_" }
    throw "$($brokenLinks.Count) broken Markdown link(s) found."
}

Write-Host "Validated local links in $($markdownFiles.Count) Markdown files."
