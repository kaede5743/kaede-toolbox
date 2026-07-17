# かえで配信ツールボックスを GitHub Pages (gh-pages ブランチ) に公開するスクリプト。
# 使い方: PowerShell で  .\deploy.ps1
$ErrorActionPreference = "Stop"

flutter test
if ($LASTEXITCODE -ne 0) { throw "テストが失敗したので中止します" }

flutter build web --release --base-href /kaede-toolbox/
if ($LASTEXITCODE -ne 0) { throw "ビルドが失敗したので中止します" }

# Pages はデフォルトで Jekyll 処理するため、アンダースコア始まりのファイル対策で無効化
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

Write-Host "公開完了: https://kaede5743.github.io/kaede-toolbox/"
