# Deploy kaede-toolbox to GitHub Pages (gh-pages branch).
# Usage (PowerShell): .\deploy.ps1
$ErrorActionPreference = "Stop"

flutter test
if ($LASTEXITCODE -ne 0) { throw "flutter test failed - deploy aborted" }

flutter build web --release --base-href /kaede-toolbox/
if ($LASTEXITCODE -ne 0) { throw "flutter build failed - deploy aborted" }

# Disable Jekyll processing on Pages (files starting with underscore)
New-Item -ItemType File -Force build\web\.nojekyll | Out-Null

Push-Location build\web
try {
    git init -b gh-pages 2>$null
    git add -A
    git commit -m "deploy $(Get-Date -Format 'yyyy-MM-dd HH:mm')" --quiet
    git push --force https://github.com/kaede5743/kaede-toolbox.git gh-pages
} finally {
    Remove-Item -Recurse -Force .git
    Pop-Location
}

Write-Host "Deployed: https://kaede5743.github.io/kaede-toolbox/"
