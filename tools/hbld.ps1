# hbld - multi-module HarbourRust build helper.
#
# hbc currently accepts a single .prg per invocation, and functions must
# all live in that one translation unit (calls across separate files are
# rejected). Within one file, definition order does not matter, so this
# helper concatenates the module files and the main program into one
# temporary unit and compiles it with hbc. This is an interim build path
# until hbc gains real multi-input symbol resolution; it is not an
# independent linker and it cannot share symbols across separate
# compilations.
#
# Usage (from the repository root):
#   powershell -ExecutionPolicy Bypass -File tools\hbld.ps1 ^
#     -Main tests\samples\multi\inv_main.prg ^
#     -Modules tests\samples\multi\inv_data.prg,tests\samples\multi\inv_report.prg ^
#     -Out inv_app.exe
#
# The output name must not end in .s for the direct native image
# (PE32+ on Windows, ELF on Linux); use --target to select the platform.
# Pass -Hbc to override the compiler path (default: hbc.exe at the repo
# root).

param(
    [Parameter(Mandatory = $true)][string]$Main,
    [string[]]$Modules = @(),
    [Parameter(Mandatory = $true)][string]$Out,
    [string]$Target = "windows",
    [string]$Hbc = ""
)

$root = (Get-Item $PSScriptRoot).Parent.FullName
if ($Hbc -eq "") { $Hbc = Join-Path $root "hbc.exe" }
# -File binding passes a,b as one string; accept both forms.
$Modules = @($Modules | ForEach-Object { $_ -split ',' } | Where-Object { $_ -ne "" })
if (-not (Test-Path $Hbc)) { Write-Error "hbc not found at $Hbc (use -Hbc)"; exit 2 }
foreach ($f in (@($Main) + $Modules)) {
    if (-not (Test-Path $f)) { Write-Error "input not found: $f"; exit 2 }
}

$parts = @()
foreach ($m in $Modules) { $parts += ([IO.File]::ReadAllText((Join-Path $PWD $m)) + "`n") }
$parts += [IO.File]::ReadAllText((Join-Path $PWD $Main))
$combined = $parts -join "`n"

$workDir = Join-Path $root "work"
New-Item -ItemType Directory -Path $workDir -Force | Out-Null
$tmp = Join-Path $workDir ("_hbld_" + [IO.Path]::GetFileNameWithoutExtension($Out) + ".prg")
[IO.File]::WriteAllText($tmp, $combined)

& $Hbc $tmp $Out --target=$Target
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
Write-Output "hbld: $Out built from $($Modules.Count + 1) sources (combined unit)"
