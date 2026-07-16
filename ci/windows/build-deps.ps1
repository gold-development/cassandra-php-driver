# Builds the native deps for the cassandra PHP extension on Windows and stages
# them under the exact filenames ext/config.w32 expects (so config.w32 is left
# untouched). Triplet is *-static-md: static libs + dynamic CRT (/MD), matching
# the /NODEFAULTLIB:LIBCMT flags in ext/config.w32.
$ErrorActionPreference = 'Stop'
$deps    = $env:DEPS_ROOT
$triplet = 'x64-windows-static-md'
$vcpkg   = "$env:VCPKG_INSTALLATION_ROOT\vcpkg.exe"

# 1) OpenSSL 3 + zlib + libuv + gmp via vcpkg (preinstalled on windows-2022)
& $vcpkg install "openssl:$triplet" "zlib:$triplet" "libuv:$triplet" "gmp:$triplet"
if ($LASTEXITCODE -ne 0) { throw "vcpkg install failed" }
$vi = "$env:VCPKG_INSTALLATION_ROOT\installed\$triplet"

# 2) DataStax C/C++ driver from the vendored submodule (lib/cpp-driver), static,
#    linked against the vcpkg deps. Installs cassandra_static.lib + headers.
if (-not (Test-Path "$deps\cpp-driver\lib\cassandra_static.lib")) {
  cmake -S lib\cpp-driver -B cpp-build -A x64 `
    -DCMAKE_TOOLCHAIN_FILE="$env:VCPKG_INSTALLATION_ROOT\scripts\buildsystems\vcpkg.cmake" `
    -DVCPKG_TARGET_TRIPLET=$triplet `
    -DLIBUV_ROOT_DIR="$vi" -DOPENSSL_ROOT_DIR="$vi" `
    -DZLIB_ROOT="$vi" -DZLIB_INCLUDE_DIR="$vi\include" -DZLIB_LIBRARY="$vi\lib\zlib.lib" `
    -DCMAKE_C_FLAGS="/I $vi\include" -DCMAKE_CXX_FLAGS="/I $vi\include" `
    -DCASS_BUILD_STATIC=ON -DCASS_BUILD_SHARED=OFF -DCASS_USE_STATIC_LIBS=ON `
    -DCASS_USE_ZLIB=ON -DCASS_INSTALL_HEADER=ON `
    -DCMAKE_INSTALL_PREFIX="$deps\cpp-driver"
  if ($LASTEXITCODE -ne 0) { throw "cpp-driver configure failed" }
  cmake --build cpp-build --config Release --target install
  if ($LASTEXITCODE -ne 0) { throw "cpp-driver build failed" }
}

# 3) Stage libs/headers under the filenames ext/config.w32 checks for.
#    --- If a first CI run fails on a missing .lib, the vcpkg source name on the
#    --- left of each copy below is the thing to adjust. ---
function New-Dir($p) { New-Item -ItemType Directory -Force -Path $p | Out-Null }
New-Dir "$deps\libuv\lib";       New-Dir "$deps\libuv\include"
New-Dir "$deps\thirdparty\lib";  New-Dir "$deps\thirdparty\include"

# libuv -> config.w32 wants libuv.lib + uv.h  (vcpkg ships uv.lib)
Copy-Item "$vi\lib\uv.lib"        "$deps\libuv\lib\libuv.lib"        -Force
Copy-Item "$vi\include\uv.h"      "$deps\libuv\include\uv.h"         -Force
Copy-Item "$vi\include\uv"        "$deps\libuv\include\uv" -Recurse -Force -ErrorAction SilentlyContinue

# OpenSSL 3 under the legacy names config.w32 checks (libeay32/ssleay32)
Copy-Item "$vi\lib\libcrypto.lib" "$deps\thirdparty\lib\libeay32.lib" -Force
Copy-Item "$vi\lib\libssl.lib"    "$deps\thirdparty\lib\ssleay32.lib" -Force
Copy-Item "$vi\include\openssl"   "$deps\thirdparty\include\openssl" -Recurse -Force

# zlib -> zlib_a.lib   (vcpkg static ships zlib.lib)
Copy-Item "$vi\lib\zlib.lib"      "$deps\thirdparty\lib\zlib_a.lib"  -Force
Copy-Item "$vi\include\zlib.h","$vi\include\zconf.h" "$deps\thirdparty\include\" -Force

# gmp -> mpir_a.lib   (extension links GMP for Bigint/Decimal/Varint)
Copy-Item "$vi\lib\gmp.lib"       "$deps\thirdparty\lib\mpir_a.lib"  -Force
Copy-Item "$vi\include\gmp.h"     "$deps\thirdparty\include\gmp.h"   -Force

Write-Host "Deps staged under $deps"
