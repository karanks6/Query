$files = git status --porcelain | ForEach-Object { $_.Substring(3) }
foreach ($file in $files) {
    if (-not [string]::IsNullOrWhiteSpace($file)) {
        Write-Host "Committing $file"
        git add $file
        $basename = Split-Path $file -Leaf
        git commit -m "feat(gameplay): Add/update $basename for Phase 5 Flame redesign"
        git push origin main
    }
}
