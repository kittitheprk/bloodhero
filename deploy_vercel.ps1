# ======================================================
# Blood Hero - Vercel Web Deployment Script
# ======================================================

Write-Host "======================================================" -ForegroundColor Cyan
Write-Host "  Blood Hero - Deploy Web Version to Vercel" -ForegroundColor Yellow
Write-Host "======================================================" -ForegroundColor Cyan

$rootDir = $PSScriptRoot

Write-Host "Deploying web folder to Vercel Production..." -ForegroundColor Green
Write-Host ""

# Run Vercel CLI (Production deploy)
cmd.exe /c "npx -y vercel --prod"

Write-Host ""
Write-Host "======================================================" -ForegroundColor Cyan
Write-Host "  Deployment completed!" -ForegroundColor Green
Write-Host "======================================================" -ForegroundColor Cyan
