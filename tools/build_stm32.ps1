param([string]$CubeIDEPath)
$ErrorActionPreference = 'Stop'
$taskRepoRoot = Split-Path $PSScriptRoot -Parent
if (-not $CubeIDEPath) {
    $taskInstall = Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*', 'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*', 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*' -ErrorAction SilentlyContinue |
        Where-Object { $_.DisplayName -eq 'STMicroelectronics STM32CubeIDE 2.2.0' } | Select-Object -First 1
    if (-not $taskInstall) { throw 'CubeIDE 2.2.0 was not found. Supply -CubeIDEPath pointing to its STM32CubeIDE directory.' }
    $CubeIDEPath = Join-Path ($taskInstall.InstallLocation.Trim('"')) 'STM32CubeIDE'
}
$taskConsole = Join-Path $CubeIDEPath 'stm32cubeidec.exe'
if (-not (Test-Path -LiteralPath $taskConsole)) { throw "CubeIDE console not found: $taskConsole" }
$taskProject = Join-Path $taskRepoRoot 'firmware\icm01_stm32'
$taskWorkspace = Join-Path $taskRepoRoot '.cache\cubeide_dev01_workspace'
$taskLogDir = Join-Path $taskRepoRoot 'docs\test_reports\dev01_logs'
New-Item -ItemType Directory -Path $taskLogDir -Force | Out-Null
# An isolated workspace keeps the user's IDE workspace and preferences untouched.
& $taskConsole --launcher.suppressErrors -nosplash -application org.eclipse.cdt.managedbuilder.core.headlessbuild -data $taskWorkspace -import $taskProject -build 'icm01_stm32/Debug' 2>&1 |
    Tee-Object -FilePath (Join-Path $taskLogDir 'cubeide_debug_build.log')
$taskBuildExit = $LASTEXITCODE
if ($taskBuildExit -ne 0) { throw "CubeIDE build failed with exit code $taskBuildExit" }
$taskElf = Join-Path $taskProject 'Debug\icm01_stm32.elf'
if (-not (Test-Path -LiteralPath $taskElf)) { throw 'Build exited without producing the expected ELF.' }
Write-Output "ELF: $taskElf"

