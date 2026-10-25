@echo off
rem compile.bat - chain the full HarbourRust build for one program on Windows:
rem   hbc.exe -> mingw-w64 as -> mingw-w64 ld -> native x86-64 .exe
rem Usage: compile.bat prog.hb [output-name]
rem Stops at the first failing step; a partial result is never reported as
rem success. Needs x86_64-w64-mingw32-as/-ld on PATH (MinGW-w64 binutils).
rem HBC env var overrides the compiler path.
if "%~1"=="" (
  echo usage: compile.bat prog.hb [output-name] 1>&2
  exit /b 1
)
set "SRC=%~1"
set "OUT=%~2"
if "%OUT%"=="" set "OUT=%~n1"
if "%HBC%"=="" set "HBC=%~dp02-hbc.exe"
"%HBC%" "%SRC%" "%OUT%.s" --target=windows || exit /b 1
x86_64-w64-mingw32-as -o "%OUT%.o" "%OUT%.s" || exit /b 1
x86_64-w64-mingw32-ld -o "%OUT%.exe" "%OUT%.o" -e _start --subsystem console -lkernel32 || exit /b 1
echo OK: %OUT%.exe
