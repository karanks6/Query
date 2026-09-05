$replacements = @{
    'Ã¢â€ â‚¬' = '─'
    'Ã¢â€\x80â€™' = '→'
    'Ã¢â‚¬â€ ' = '—'
    'ÃƒÂ¢Ã¢â€šÂ¬Ã¢â‚¬Â ' = '—'
    'Ã¢Ëœâ€¦' = '★'
    'ÃƒÂ¢Ã¢â€šÂ¬Ã¢â‚¬Å“' = '–'
    'Ãƒâ€”' = '×'
}

Get-ChildItem -Path "lib" -Filter "*.dart" -Recurse | ForEach-Object {
    $content = [System.IO.File]::ReadAllText($_.FullName, [System.Text.Encoding]::UTF8)
    $original = $content
    
    foreach ($key in $replacements.Keys) {
        $content = $content.Replace($key, $replacements[$key])
    }
    
    if ($content -cne $original) {
        [System.IO.File]::WriteAllText($_.FullName, $content, [System.Text.Encoding]::UTF8)
        Write-Host "Fixed $($_.FullName)"
    }
}
