$ErrorActionPreference = 'Stop'
Set-Location $PSScriptRoot
& flutter create --project-name mobile_assignment_3 --platforms android,web .
if ($LASTEXITCODE -ne 0) { throw 'Flutter project generation failed.' }
$manifestPath = Join-Path $PSScriptRoot 'android/app/src/main/AndroidManifest.xml'
$manifestText = Get-Content -LiteralPath $manifestPath -Raw
if ($manifestText -notmatch 'android.permission.INTERNET') {
    $manifestText = $manifestText.Replace('<application', '<uses-permission android:name="android.permission.INTERNET" />' + [Environment]::NewLine + '    <application')
    Set-Content -LiteralPath $manifestPath -Value $manifestText -Encoding utf8
}
& flutter pub get
if ($LASTEXITCODE -ne 0) { throw 'Dependency installation failed.' }
& flutter analyze
if ($LASTEXITCODE -ne 0) { throw 'Analysis failed.' }
& flutter test
if ($LASTEXITCODE -ne 0) { throw 'Tests failed.' }
Write-Host 'Setup and tests completed. Run: flutter run'
