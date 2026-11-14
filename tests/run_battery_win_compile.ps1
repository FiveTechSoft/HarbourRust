# Windows compile-only regression battery (PowerShell, no bash needed).
#
# Runs every tests/manifest.txt entry through hbc.exe with --target=windows:
#   pos: hbc must exit 0 (compile admitted). Expected stdout is NOT checked;
#        this script only exercises the front end and Windows codegen emit.
#   neg: hbc must exit nonzero AND stderr must contain the expected substring.
#
# This is a front-end/codegen gate only. It never assembles, links or runs
# anything, so it works on a plain Windows install without MinGW binutils,
# Rust, bash or Wine. Runtime behavior is NOT verified here; use the Linux
# + Wine battery for that.
#
# Usage (from the repository root, with hbc.exe present):
#   powershell -ExecutionPolicy Bypass -File tests\run_battery_win_compile.ps1
#
# Output: work/battery_windows_report.txt with per-entry failures.
# Known expected failures on the current increments: the CurDir tests
# (Linux-only in this increment) and t110 (inherited, unexpected admission).

$ErrorActionPreference = 'Continue'
$root = (Get-Item $PSScriptRoot).Parent.FullName
$hbc = Join-Path $root "hbc.exe"
$manifest = Join-Path $root "tests\manifest.txt"
$outAsm = Join-Path $root "work\battery_out.s"
$errFile = Join-Path $root "work\battery_err.txt"
New-Item -ItemType Directory -Path (Join-Path $root "work") -Force | Out-Null

function Norm([string]$s) {
    if ($null -eq $s) { return "" }
    $s = $s -replace "`r", ""
    $s = ($s -replace "[^\x20-\x7E]", "").Trim()
    return $s
}

$entries = New-Object System.Collections.Generic.List[object]
foreach ($line in [IO.File]::ReadAllLines($manifest)) {
    if ($line -match '^(pos|neg)\s+(\S+)\s+(.*)$') {
        $entries.Add([pscustomobject]@{ Kind = $Matches[1]; Path = $Matches[2]; Expect = $Matches[3] })
    }
}
Write-Output "manifest entries: $($entries.Count)"

$posPass = 0; $posFail = 0; $negPass = 0; $negFail = 0
$failures = New-Object System.Collections.Generic.List[string]
$i = 0
foreach ($e in $entries) {
    $i++
    $file = Join-Path $root ($e.Path -replace '/', '\')
    if (-not (Test-Path -LiteralPath $file)) {
        $failures.Add("MISSING $($e.Kind) $($e.Path)")
        if ($e.Kind -eq 'pos') { $posFail++ } else { $negFail++ }
        continue
    }
    if (Test-Path $errFile) { Remove-Item $errFile -Force }
    # stderr is captured to a file via cmd /c: PowerShell 5.1 reformats native
    # stderr through 2>&1 and wraps it at the console width, which corrupts
    # message matching.
    $null = cmd /c "`"$hbc`" `"$file`" `"$outAsm`" --target=windows -I tests > NUL 2>`"$errFile`""
    $code = $LASTEXITCODE
    $errTxt = ""
    if (Test-Path $errFile) { $errTxt = [IO.File]::ReadAllText($errFile) }
    $nErr = Norm $errTxt
    $nExp = Norm $e.Expect
    if ($e.Kind -eq 'pos') {
        if ($code -eq 0) { $posPass++ } else { $posFail++; $failures.Add("POS-FAIL $($e.Path) :: $nErr") }
    } else {
        if ($code -ne 0) {
            # .Contains, not -like: in PowerShell wildcards the backtick is the
            # escape character, and many expected messages contain backticks.
            if ($nErr.Contains($nExp)) { $negPass++ } else { $negFail++; $failures.Add("NEG-MISMATCH $($e.Path) expected=[$nExp] got=[$nErr]") }
        } else { $negFail++; $failures.Add("NEG-COMPILED $($e.Path)") }
    }
    if ($i % 200 -eq 0) { Write-Output "progress $i/$($entries.Count)" }
    if (Test-Path $outAsm) { Remove-Item $outAsm -Force }
}

$report = @()
$report += "Windows compile-only battery - $(Get-Date -Format s)"
$report += "compiler: $hbc (-I tests)"
$report += "manifest entries: $($entries.Count)"
$report += "pos: pass=$posPass fail=$posFail"
$report += "neg: pass=$negPass fail=$negFail"
$report += ""
$report += $failures
$report | Out-File -Encoding utf8 (Join-Path $root "work\battery_windows_report.txt")
Write-Output "DONE pos(pass=$posPass fail=$posFail) neg(pass=$negPass fail=$negFail)"
