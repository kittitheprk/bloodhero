# ======================================================
# Blood Hero - Local Web Server & Browser Launcher
# ======================================================

$port = 8080
$url = "http://localhost:$port/"
$folder = $PSScriptRoot

Write-Host "======================================================" -ForegroundColor Cyan
Write-Host "  Blood Hero - Web Browser Version Server" -ForegroundColor Yellow
Write-Host "======================================================" -ForegroundColor Cyan
Write-Host "Web Root: $folder" -ForegroundColor Gray
Write-Host "URL     : $url" -ForegroundColor Green
Write-Host "Starting Web Server on port $port..." -ForegroundColor Yellow
Write-Host "Press Ctrl+C to stop the server." -ForegroundColor DarkGray
Write-Host "======================================================" -ForegroundColor Cyan

# Open default browser
Start-Process $url

# Built-in PowerShell HTTP Server
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:$port/")
try {
    $listener.Start()
} catch {
    Write-Host "Port $port is busy or unavailable, opening index.html directly in browser..." -ForegroundColor Yellow
    Start-Process (Join-Path $folder "index.html")
    exit
}

while ($listener.IsListening) {
    $context = $listener.GetContext()
    $request = $context.Request
    $response = $context.Response

    $localPath = $request.Url.LocalPath.TrimStart('/')
    if ([string]::IsNullOrEmpty($localPath) -or $localPath -eq '/') {
        $localPath = "index.html"
    }

    $filePath = Join-Path $folder $localPath

    if (Test-Path $filePath -PathType Leaf) {
        $ext = [System.IO.Path]::GetExtension($filePath).ToLower()
        $contentType = switch ($ext) {
            ".html" { "text/html; charset=utf-8" }
            ".htm"  { "text/html; charset=utf-8" }
            ".js"   { "application/javascript; charset=utf-8" }
            ".json" { "application/json; charset=utf-8" }
            ".css"  { "text/css; charset=utf-8" }
            ".png"  { "image/png" }
            ".jpg"  { "image/jpeg" }
            ".webp" { "image/webp" }
            ".svg"  { "image/svg+xml" }
            Default { "application/octet-stream" }
        }

        $response.ContentType = $contentType
        $bytes = [System.IO.File]::ReadAllBytes($filePath)
        $response.ContentLength64 = $bytes.Length
        $response.OutputStream.Write($bytes, 0, $bytes.Length)
    } else {
        $response.StatusCode = 404
        $msg = [System.Text.Encoding]::UTF8.GetBytes("404 Not Found")
        $response.OutputStream.Write($msg, 0, $msg.Length)
    }

    $response.OutputStream.Close()
}
