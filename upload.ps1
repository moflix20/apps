Write-Host "===== AUTO GITHUB UPLOADER =====" -ForegroundColor Cyan

# ===== Git check =====
git --version | Out-Null
if ($LASTEXITCODE -ne 0) {
    Write-Host "Git is not installed" -ForegroundColor Red
    pause
    exit
}

# ===== Git identity (AUTO) =====
git config --global user.name "moflix20"
git config --global user.email "moflix20@gmail.com"

# ===== Init repo if needed =====
if (!(Test-Path ".git")) {
    Write-Host "Initializing git repo..." -ForegroundColor Yellow
    git init
}

# ===== LFS setup =====
git lfs install

# ===== Show files =====
$files = Get-ChildItem -File

if ($files.Count -eq 0) {
    Write-Host "No files found!" -ForegroundColor Red
    pause
    exit
}

Write-Host "`nAvailable files:" -ForegroundColor Green
for ($i=0; $i -lt $files.Count; $i++) {
    Write-Host "[$i] $($files[$i].Name)"
}

# ===== Select files =====
Write-Host "`nSelect files (example: 0,1,2 or * for all):"
$input = Read-Host

if ($input -eq "*") {
    $indexes = 0..($files.Count-1)
} else {
    $indexes = $input -split "," | ForEach-Object { $_.Trim() }
}

# ===== Ask repo =====
Write-Host "`nGitHub repo URL:"
$repo = Read-Host

git remote remove origin 2>$null
git remote add origin $repo

# ===== Track LFS =====
foreach ($i in $indexes) {
    if ($i -match '^\d+$' -and $i -lt $files.Count) {
        git lfs track $files[$i].Name
    }
}

git add .gitattributes 2>$null

# ===== Add files =====
foreach ($i in $indexes) {
    if ($i -match '^\d+$' -and $i -lt $files.Count) {
        git add $files[$i].Name
    }
}

# ===== Commit =====
Write-Host "`nCommit message (optional):"
$msg = Read-Host
if ([string]::IsNullOrWhiteSpace($msg)) {
    $msg = "Auto upload files"
}

git add .
git commit -m $msg 2>$null

# ===== Fix branch =====
git checkout -B main

# ===== Push =====
Write-Host "`nPushing to GitHub..." -ForegroundColor Cyan

git push -u origin main

if ($LASTEXITCODE -ne 0) {
    Write-Host "`nTrying force push..." -ForegroundColor Yellow
    git push -f origin main
}

Write-Host "`n===== DONE SUCCESSFULLY =====" -ForegroundColor Green
pause