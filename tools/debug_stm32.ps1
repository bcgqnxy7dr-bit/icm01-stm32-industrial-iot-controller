param([string]$CubeIDEPath = 'D:\download\stm32cubeide\STM32CubeIDE_2.2.0\STM32CubeIDE')
$ErrorActionPreference = 'Stop'
$taskRepo = Split-Path $PSScriptRoot -Parent
$taskFiles = Get-ChildItem -LiteralPath (Join-Path $CubeIDEPath 'plugins') -Recurse -File
$taskServer = ($taskFiles | Where-Object Name -eq 'ST-LINK_gdbserver.exe' | Select-Object -First 1).FullName
$taskCli = ($taskFiles | Where-Object Name -eq 'STM32_Programmer_CLI.exe' | Select-Object -First 1).FullName
$taskGdb = ($taskFiles | Where-Object Name -eq 'arm-none-eabi-gdb.exe' | Select-Object -First 1).FullName
if (-not $taskServer -or -not $taskCli -or -not $taskGdb) { throw 'CubeIDE debug tools not found.' }
if (Get-NetTCPConnection -LocalPort 61234 -State Listen -ErrorAction SilentlyContinue) { throw 'Port 61234 is already in use.' }
$taskLogDir = Join-Path $taskRepo '.cache\dev02'
New-Item -ItemType Directory -Path $taskLogDir -Force | Out-Null
# An ASCII drive alias avoids GDB/BFD reopening failures on the Chinese repo path.
# It points to this same checkout and is removed in finally; no project is copied.
$taskDrive = @('T','U','V','W','X','Y','Z') | Where-Object { -not (Test-Path ($_ + ':\')) -and -not (Get-PSDrive -Name $_ -ErrorAction SilentlyContinue) } | Select-Object -First 1
if (-not $taskDrive) { throw 'No unused temporary drive letter available.' }
& subst ($taskDrive + ':') $taskRepo
if ($LASTEXITCODE -ne 0) { throw 'Could not create temporary repo alias.' }
$taskProcess = $null
$taskLocationPushed = $false
try {
    $taskArgs = '-p 61234 -d --frequency 1000 -e --halt -cp "' + (Split-Path $taskCli -Parent) + '"'
    $taskProcess = Start-Process -FilePath $taskServer -ArgumentList $taskArgs -WindowStyle Hidden -RedirectStandardOutput (Join-Path $taskLogDir 'server.stdout.log') -RedirectStandardError (Join-Path $taskLogDir 'server.stderr.log') -PassThru
    $taskReady = $false
    for ($taskAttempt = 0; $taskAttempt -lt 30; $taskAttempt++) {
        if (Get-NetTCPConnection -LocalPort 61234 -State Listen -ErrorAction SilentlyContinue) { $taskReady = $true; break }
        if ($taskProcess.HasExited) { break }
        Start-Sleep -Milliseconds 200
    }
    if (-not $taskReady) { throw 'ST-LINK GDB server did not become ready.' }
    Push-Location ($taskDrive + ':\')
    $taskLocationPushed = $true
    # The flashed ELF must correspond to this Debug build. This script does not flash.
    & $taskGdb --batch -nx -q -x 'tools/verify_dev02.gdb' 2>&1 | Tee-Object -FilePath (Join-Path $taskLogDir 'gdb.log')
    $taskGdbExit = $LASTEXITCODE
    $taskLog = Get-Content -LiteralPath (Join-Path $taskLogDir 'gdb.log') -Raw
    if ($taskGdbExit -ne 0 -or $taskLog -notmatch 'DEV02_DEBUG_CHECKS_PASSED' -or $taskLog -notmatch 'Breakpoint \d+, main' -or $taskLog -notmatch '#0\s+HAL_Init' -or $taskLog -notmatch '#0\s+SystemClock_Config' -or $taskLog -notmatch 'HAL_OK') { throw 'DEV-02 debug verification failed; inspect local log.' }
    Write-Output 'DEV-02 source-level debug verification passed.'
} finally {
    if ($taskLocationPushed) { Pop-Location }
    if ($taskProcess -and -not $taskProcess.HasExited) { Stop-Process -Id $taskProcess.Id }
    & subst ($taskDrive + ':') /D
}
