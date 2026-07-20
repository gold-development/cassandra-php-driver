@echo off
rem Builds php_cassandra.dll in-tree against php-src. Must run inside the phpsdk
rem VS environment, i.e. invoked as:  phpsdk-vs17-x64.bat -t ci\windows\build-ext.bat
rem Expects env: PHP_SRC_TAG (e.g. php-8.5.1), TS (ts|nts), ARCH (x64), DEPS_ROOT.
setlocal enabledelayedexpansion

if "%PHP_SRC_TAG%"=="" ( echo PHP_SRC_TAG not set & exit /b 1 )

if not exist php-src (
  git clone --depth 1 --branch %PHP_SRC_TAG% https://github.com/php/php-src.git php-src
  if errorlevel 1 exit /b 1
)

rem Drop this extension into php-src\ext\cassandra
xcopy /E /I /Y ext "php-src\ext\cassandra" >nul

cd php-src

rem Put the staged OpenSSL/zlib/gmp on the compiler+linker search paths
set INCLUDE=%DEPS_ROOT%\thirdparty\include;%INCLUDE%
set LIB=%DEPS_ROOT%\thirdparty\lib;%LIB%

rem Thread safety: Windows PHP is TS by default; NTS needs --disable-zts
set ZTS_FLAG=
if /I "%TS%"=="nts" set ZTS_FLAG=--disable-zts

call buildconf.bat --force
if errorlevel 1 exit /b 1

call configure.bat --disable-all --enable-cli --enable-cassandra=shared ^
  --with-cassandra-cpp-driver=%DEPS_ROOT%\cpp-driver ^
  --with-libuv=%DEPS_ROOT%\libuv %ZTS_FLAG%
if errorlevel 1 exit /b 1

nmake /nologo
if errorlevel 1 exit /b 1

cd ..

rem The phpsdk starter clears ARCH in the task shell, so re-default it here
if "%ARCH%"=="" set ARCH=x64

rem Collect the DLL (TS -> x64\Release_TS, NTS -> x64\Release)
set OUTDIR=php-src\%ARCH%\Release
if /I "%TS%"=="ts" set OUTDIR=php-src\%ARCH%\Release_TS

if not exist "%OUTDIR%\php_cassandra.dll" (
  echo php_cassandra.dll not found in %OUTDIR% - actual locations:
  dir /s /b php-src\php_cassandra.dll
  exit /b 1
)

if not exist artifacts mkdir artifacts
copy /Y "%OUTDIR%\php_cassandra.dll" "artifacts\php_cassandra-%PHP_SRC_TAG%-%TS%-vs17-%ARCH%.dll"
if errorlevel 1 exit /b 1

echo Built: artifacts\php_cassandra-%PHP_SRC_TAG%-%TS%-vs17-%ARCH%.dll
