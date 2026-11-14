@echo off
rem Retired historical compiler helper. Deliberately performs no build.
echo This is the retired build script for the historical HarbourRust compiler. 1>&2
echo That compiler wrote assembly and needed external MinGW-w64 as/ld tools. 1>&2
echo This script is no longer needed and will not run any compiler or assembler. 1>&2
echo. 1>&2
echo For supported native-only programs on Windows, use the current repository 1>&2
echo compiler at bin\hbc.exe. No MinGW, assembler or linker is needed. 1>&2
echo From the repository root: 1>&2
echo   bin\hbc.exe tests\samples\hello.prg hello.exe 1>&2
echo   hello.exe 1>&2
echo. 1>&2
echo The binaries in dist are historical, not the current compiler. 1>&2
echo See README.md and BUILDING.md in the repository root for scope and limits. 1>&2
exit /b 1
