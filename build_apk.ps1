Write-Host "======================================================" -ForegroundColor Cyan
Write-Host "  Blood Hero - Android APK Build Pipeline" -ForegroundColor Cyan
Write-Host "======================================================" -ForegroundColor Cyan

$rootDir = "c:\Users\WIN11\Downloads\bloodhero"
$buildDir = "$rootDir\android-build"
$sdkDir = "C:\Android\Sdk"
$buildToolsDir = "$sdkDir\build-tools\35.0.0"
if (-not (Test-Path $buildToolsDir)) {
    $buildToolsDir = "$sdkDir\build-tools\34.0.0"
}
$androidJar = "$sdkDir\platforms\android-35\android.jar"
$jdkBin = "C:\Program Files\Microsoft\jdk-17.0.19.10-hotspot\bin"

$aapt2 = "$buildToolsDir\aapt2.exe"
$d8 = "$buildToolsDir\d8.bat"
$zipalign = "$buildToolsDir\zipalign.exe"
$apksigner = "$buildToolsDir\apksigner.bat"
$javac = "$jdkBin\javac.exe"
$keytool = "$jdkBin\keytool.exe"
$jar = "$jdkBin\jar.exe"
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)

Write-Host "[1/8] Verifying build tools..." -ForegroundColor Yellow
$tools = @($aapt2, $d8, $zipalign, $apksigner, $androidJar, $javac, $keytool)
foreach ($t in $tools) {
    if (-not (Test-Path $t)) {
        Write-Error "Tool not found: $t"
        exit 1
    }
}
Write-Host "All build tools verified." -ForegroundColor Green

Write-Host "[2/8] Creating build directories..." -ForegroundColor Yellow
if (Test-Path $buildDir) {
    Remove-Item -Path $buildDir -Recurse -Force
}
$dirs = @(
    "$buildDir\res\values",
    "$buildDir\res\layout",
    "$buildDir\res\mipmap-mdpi",
    "$buildDir\res\mipmap-hdpi",
    "$buildDir\res\mipmap-xhdpi",
    "$buildDir\res\mipmap-xxhdpi",
    "$buildDir\res\mipmap-xxxhdpi",
    "$buildDir\src\com\bloodhero\vampirewarrior",
    "$buildDir\assets",
    "$buildDir\bin\classes",
    "$buildDir\obj\compiled"
)
foreach ($d in $dirs) {
    New-Item -ItemType Directory -Path $d -Force | Out-Null
}

Write-Host "[3/8] Writing Android manifest & resources..." -ForegroundColor Yellow
$manifest = @"
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.bloodhero.vampirewarrior"
    android:versionCode="1"
    android:versionName="1.0.0">

    <uses-sdk android:minSdkVersion="24" android:targetSdkVersion="35" />

    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
    <uses-permission android:name="android.permission.WAKE_LOCK" />

    <application
        android:label="@string/app_name"
        android:icon="@mipmap/ic_launcher"
        android:theme="@style/AppTheme"
        android:hardwareAccelerated="true"
        android:largeHeap="true"
        android:allowBackup="true"
        android:usesCleartextTraffic="true">
        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:screenOrientation="sensorLandscape"
            android:configChanges="orientation|keyboardHidden|screenSize|screenLayout"
            android:windowSoftInputMode="adjustResize|stateHidden">
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity>
    </application>
</manifest>
"@
[IO.File]::WriteAllText("$buildDir\AndroidManifest.xml", $manifest, [System.Text.Encoding]::UTF8)

$strings = @"
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <string name="app_name">Blood Hero</string>
</resources>
"@
[IO.File]::WriteAllText("$buildDir\res\values\strings.xml", $strings, [System.Text.Encoding]::UTF8)

$styles = @"
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <style name="AppTheme" parent="@android:style/Theme.NoTitleBar.Fullscreen">
        <item name="android:windowBackground">@android:color/black</item>
        <item name="android:windowNoTitle">true</item>
        <item name="android:windowFullscreen">true</item>
    </style>
</resources>
"@
[IO.File]::WriteAllText("$buildDir\res\values\styles.xml", $styles, [System.Text.Encoding]::UTF8)

$layout = @"
<?xml version="1.0" encoding="utf-8"?>
<FrameLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:background="#07040d">

    <WebView
        android:id="@+id/webview"
        android:layout_width="match_parent"
        android:layout_height="match_parent"
        android:background="#07040d" />
</FrameLayout>
"@
[IO.File]::WriteAllText("$buildDir\res\layout\activity_main.xml", $layout, [System.Text.Encoding]::UTF8)

Write-Host "[4/8] Generating app icon from vampire hero sprite..." -ForegroundColor Yellow
Add-Type -AssemblyName System.Drawing
$spriteFile = "$rootDir\sprite-animation-128x128-frames\frame-1.png"
if (Test-Path $spriteFile) {
    $srcBmp = [System.Drawing.Bitmap]::FromFile($spriteFile)
    
    $iconSizes = @{
        "mipmap-mdpi" = 48
        "mipmap-hdpi" = 72
        "mipmap-xhdpi" = 96
        "mipmap-xxhdpi" = 144
        "mipmap-xxxhdpi" = 192
    }
    
    foreach ($entry in $iconSizes.GetEnumerator()) {
        $size = $entry.Value
        $destPath = "$buildDir\res\$($entry.Key)\ic_launcher.png"
        $iconBmp = New-Object System.Drawing.Bitmap($size, $size)
        $g = [System.Drawing.Graphics]::FromImage($iconBmp)
        $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
        $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::NearestNeighbor
        
        # Background badge: Dark gothic crimson circle
        $brushBg = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 12, 6, 20))
        $g.FillEllipse($brushBg, 2, 2, $size - 4, $size - 4)
        $penBorder = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(255, 255, 45, 85), [Math]::Max(2, $size * 0.04))
        $g.DrawEllipse($penBorder, 2, 2, $size - 4, $size - 4)
        
        # Draw vampire hero sprite centered
        $padding = [int]($size * 0.08)
        $charSize = $size - ($padding * 2)
        $g.DrawImage($srcBmp, $padding, $padding, $charSize, $charSize)
        
        $g.Dispose()
        $iconBmp.Save($destPath, [System.Drawing.Imaging.ImageFormat]::Png)
        $iconBmp.Dispose()
    }
    $srcBmp.Dispose()
}

Write-Host "[5/8] Copying game web assets..." -ForegroundColor Yellow
Copy-Item -Path "$rootDir\vampire_warrior_blood_hero.html" -Destination "$buildDir\assets\index.html" -Force
if (Test-Path "$rootDir\hero_sprites.js") {
    Copy-Item -Path "$rootDir\hero_sprites.js" -Destination "$buildDir\assets\hero_sprites.js" -Force
}
if (Test-Path "$rootDir\sprite-animation-128x128-frames") {
    Copy-Item -Path "$rootDir\sprite-animation-128x128-frames" -Destination "$buildDir\assets\sprite-animation-128x128-frames" -Recurse -Force
}

Write-Host "[6/8] Writing MainActivity.java..." -ForegroundColor Yellow
$mainActivity = @"
package com.bloodhero.vampirewarrior;

import android.app.Activity;
import android.os.Bundle;
import android.os.Build;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;
import android.webkit.WebChromeClient;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;

public class MainActivity extends Activity {
    private WebView mWebView;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN, WindowManager.LayoutParams.FLAG_FULLSCREEN);
        getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);

        setContentView(R.layout.activity_main);
        hideSystemUI();

        mWebView = findViewById(R.id.webview);
        WebSettings settings = mWebView.getSettings();
        settings.setJavaScriptEnabled(true);
        settings.setDomStorageEnabled(true);
        settings.setDatabaseEnabled(true);
        settings.setAllowFileAccess(true);
        settings.setAllowContentAccess(true);
        settings.setMediaPlaybackRequiresUserGesture(false);
        settings.setUseWideViewPort(true);
        settings.setLoadWithOverviewMode(true);
        settings.setSupportZoom(false);
        settings.setBuiltInZoomControls(false);
        settings.setDisplayZoomControls(false);
        settings.setCacheMode(WebSettings.LOAD_DEFAULT);

        mWebView.setBackgroundColor(0xFF07040D);
        mWebView.setWebChromeClient(new WebChromeClient());
        mWebView.setWebViewClient(new WebViewClient() {
            @Override
            public void onPageFinished(WebView view, String url) {
                super.onPageFinished(view, url);
                hideSystemUI();
            }
        });

        mWebView.loadUrl("file:///android_asset/index.html");
    }

    @Override
    public void onWindowFocusChanged(boolean hasFocus) {
        super.onWindowFocusChanged(hasFocus);
        if (hasFocus) {
            hideSystemUI();
        }
    }

    private void hideSystemUI() {
        View decorView = getWindow().getDecorView();
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
            decorView.setSystemUiVisibility(
                View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY
                | View.SYSTEM_UI_FLAG_LAYOUT_STABLE
                | View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION
                | View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN
                | View.SYSTEM_UI_FLAG_HIDE_NAVIGATION
                | View.SYSTEM_UI_FLAG_FULLSCREEN
            );
        }
    }

    @Override
    public void onBackPressed() {
        if (mWebView != null && mWebView.canGoBack()) {
            mWebView.goBack();
        } else {
            super.onBackPressed();
        }
    }

    @Override
    protected void onPause() {
        super.onPause();
        if (mWebView != null) mWebView.onPause();
    }

    @Override
    protected void onResume() {
        super.onResume();
        hideSystemUI();
        if (mWebView != null) mWebView.onResume();
    }

    @Override
    protected void onDestroy() {
        if (mWebView != null) {
            mWebView.destroy();
        }
        super.onDestroy();
    }
}
"@
[IO.File]::WriteAllText("$buildDir\src\com\bloodhero\vampirewarrior\MainActivity.java", $mainActivity, $utf8NoBom)

Write-Host "[7/8] Compiling resources & Java bytecode..." -ForegroundColor Yellow
# 1. AAPT2 compile to directory
cmd.exe /c "`"$aapt2`" compile --dir `"$buildDir\res`" -o `"$buildDir\obj\compiled`""
$flatFiles = Get-ChildItem "$buildDir\obj\compiled" -Filter "*.flat" | Select-Object -ExpandProperty FullName
if (-not $flatFiles) {
    Write-Error "No .flat resource files compiled."
    exit 1
}
Write-Host "Compiled $($flatFiles.Count) resource flat files." -ForegroundColor Green

# 2. AAPT2 link
$flatArgs = ($flatFiles | ForEach-Object { "`"$_`"" }) -join " "
cmd.exe /c "`"$aapt2`" link -o `"$buildDir\bin\base.apk`" -I `"$androidJar`" --manifest `"$buildDir\AndroidManifest.xml`" $flatArgs --java `"$buildDir\src`" -A `"$buildDir\assets`" --auto-add-overlay"
if (-not (Test-Path "$buildDir\bin\base.apk")) {
    Write-Error "AAPT2 link failed to create base.apk"
    exit 1
}
Write-Host "base.apk created with R.java and assets." -ForegroundColor Green

# 3. Javac compile
$javaFiles = Get-ChildItem "$buildDir\src" -Filter "*.java" -Recurse | Select-Object -ExpandProperty FullName
$javaListFile = "$buildDir\bin\java_sources.txt"
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[IO.File]::WriteAllLines($javaListFile, $javaFiles, $utf8NoBom)
cmd.exe /c "`"$javac`" -encoding UTF-8 -cp `"$androidJar`" -d `"$buildDir\bin\classes`" @`"$javaListFile`""
$classFiles = Get-ChildItem "$buildDir\bin\classes" -Filter "*.class" -Recurse | Select-Object -ExpandProperty FullName
if (-not $classFiles) {
    Write-Error "Javac failed to create .class files"
    exit 1
}
Write-Host "Compiled $($classFiles.Count) class files." -ForegroundColor Green

# 4. D8 dex
$classArgList = ($classFiles | ForEach-Object { "`"$_`"" }) -join " "
cmd.exe /c "`"$d8`" --output `"$buildDir\bin`" --lib `"$androidJar`" $classArgList"
if (-not (Test-Path "$buildDir\bin\classes.dex")) {
    Write-Error "D8 failed to generate classes.dex"
    exit 1
}
Write-Host "classes.dex generated successfully." -ForegroundColor Green

# 5. Inject classes.dex into base.apk using .NET ZipArchive
Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem
$apkZip = [System.IO.Compression.ZipFile]::Open("$buildDir\bin\base.apk", [System.IO.Compression.ZipArchiveMode]::Update)
[System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($apkZip, "$buildDir\bin\classes.dex", "classes.dex") | Out-Null
$apkZip.Dispose()

$verifyZip = [System.IO.Compression.ZipFile]::OpenRead("$buildDir\bin\base.apk")
$dexEntry = $verifyZip.GetEntry("classes.dex")
if (-not $dexEntry) {
    $verifyZip.Dispose()
    Write-Error "classes.dex was NOT found in base.apk!"
    exit 1
}
Write-Host "classes.dex injected and verified in base.apk ($($dexEntry.Length) bytes)." -ForegroundColor Green
$verifyZip.Dispose()

Write-Host "[8/8] Aligning & Signing APK..." -ForegroundColor Yellow
# 6. Zipalign
cmd.exe /c "`"$zipalign`" -f -p 4 `"$buildDir\bin\base.apk`" `"$buildDir\bin\aligned.apk`""
if (-not (Test-Path "$buildDir\bin\aligned.apk")) {
    Write-Error "Zipalign failed"
    exit 1
}

# 7. Create keystore if not exists
$keystorePath = "$buildDir\debug.keystore"
if (-not (Test-Path $keystorePath)) {
    cmd.exe /c "`"$keytool`" -genkeypair -v -keystore `"$keystorePath`" -alias bloodherokey -keyalg RSA -keysize 2048 -validity 10000 -storepass bloodhero -keypass bloodhero -dname `"CN=BloodHero, OU=Game, O=BloodHero, C=TH`""
}

# 8. Sign APK
$finalApk = "$rootDir\BloodHero-VampireWarrior.apk"
cmd.exe /c "`"$apksigner`" sign --ks `"$keystorePath`" --ks-pass pass:bloodhero --ks-key-alias bloodherokey --key-pass pass:bloodhero --out `"$finalApk`" `"$buildDir\bin\aligned.apk`""
if (-not (Test-Path $finalApk)) {
    Write-Error "Apksigner failed to output final APK"
    exit 1
}

# 9. Verify APK
cmd.exe /c "`"$apksigner`" verify --verbose `"$finalApk`""

$apkInfo = Get-Item $finalApk
Write-Host "======================================================" -ForegroundColor Green
Write-Host "  SUCCESS! APK generated successfully!" -ForegroundColor Green
Write-Host "  Output APK: $($apkInfo.FullName)" -ForegroundColor Cyan
Write-Host "  File Size : $([math]::Round($apkInfo.Length / 1MB, 2)) MB ($($apkInfo.Length) bytes)" -ForegroundColor Cyan
Write-Host "======================================================" -ForegroundColor Green
