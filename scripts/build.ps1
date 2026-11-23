param([ValidateSet('run', 'test', 'build')][string]$Mode = 'build')

$ErrorActionPreference = 'Stop'
Set-Location (Join-Path $PSScriptRoot '..')
if (-not (Get-Command javac -ErrorAction SilentlyContinue)) {
    throw 'JDK 17 or newer is required. Install a JDK and add it to PATH.'
}
$mainDir = Join-Path (Get-Location) 'build/classes'
New-Item -ItemType Directory -Force -Path $mainDir | Out-Null
$sources = @(Get-ChildItem 'XiangQi/src/main/java' -Filter '*.java' -Recurse | ForEach-Object { $_.FullName })
& javac -encoding UTF-8 --release 17 -d $mainDir $sources
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

if ($Mode -eq 'test') {
    $testDir = Join-Path (Get-Location) 'build/test-classes'
    New-Item -ItemType Directory -Force -Path $testDir | Out-Null
    $tests = @(Get-ChildItem 'XiangQi/src/test/java' -Filter '*.java' -Recurse | ForEach-Object { $_.FullName })
    & javac -encoding UTF-8 --release 17 -cp $mainDir -d $testDir $tests
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
    & java -cp "$mainDir;$testDir" edu.sustech.xiangqi.model.ProjectTests
    exit $LASTEXITCODE
}
if ($Mode -eq 'run') {
    & java -cp $mainDir edu.sustech.xiangqi.Main
    exit $LASTEXITCODE
}
Write-Host 'Build succeeded.'
