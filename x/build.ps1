#!/bin/env pwsh
$ErrorActionPreference = 'Stop'

function NormalizePath {
  param (
    [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
    [Alias('PSPath')]
    [object]$path
  )
  process {
    if ($path -is [Array]) {
      $path | ForEach-Object { NormalizePath($_) }
    }
    else {
      $path -replace '\\', '/'
    }
  }
}

$thisFolder = Split-Path -Parent $MyInvocation.MyCommand.Definition | NormalizePath
$rootFolder = Split-Path -Parent $thisFolder | NormalizePath

$fresh = $false
$cuda = $true

# Optimized for AMD Ryzen 9 3900X (Zen 2, 12 cores, 24 threads)
if ($IsWindows) {
  $cFlags = '/arch:AVX2 /favor:AMD64 /fp:fast /MP /O2 /Oi /Ot'
} else {
  $cFlags = '-march=znver2 -mtune=znver2 -O3'
}
$flags = @{
  'CMAKE_BUILD_TYPE' = 'Release'
  'CMAKE_C_COMPILER' = 'clang'
  'CMAKE_C_FLAGS' = $cFlags
  'CMAKE_CXX_COMPILER' = 'clang++'
  'CMAKE_CXX_FLAGS' = $cFlags
  'CMAKE_POSITION_INDEPENDENT_CODE' = '1'
  'GGML_NATIVE' = '1'
}
if ($cuda) {
  $flags += @{
    'CMAKE_CUDA_ARCHITECTURES' = '89'
    'CMAKE_CUDA_COMPILER_TOOLKIT_ROOT' = $env:CUDA_PATH
    'CMAKE_CUDA_FLAGS' = '-t6'
    'GGML_CUDA_F16' = '1'
    'GGML_CUDA_FA_ALL_QUANTS' = '1'
    'GGML_CUDA_NO_PEER_COPY' = '1'
    'GGML_CUDA' = '1'
    'GGML_SYCL_TARGET' = 'NVIDIA'
  }
} else {
  $flags += @{
    'GGML_CUDA' = '0'
  }
}
$env:__OPTIMIZE__ = '1'

$buildFolder = "$rootFolder/build" | NormalizePath
$buildFolderExists = Test-Path $buildFolder
if ($buildFolderExists) {
  if ($fresh) {
    Remove-Item -Recurse -Force $buildFolder
    New-Item -ItemType Directory -Path $buildFolder | Out-Null
  }
} else {
  New-Item -ItemType Directory -Path $buildFolder | Out-Null
}
function Configure {
  Set-Location $buildFolder
  $cmakeCommand = 'cmake'
  foreach ($key in $flags.Keys) {
    $arg = $flags[$key]
    if ($arg -match '\s') {
      if ($arg -match "'") {
        $arg = '"' + $arg + '"'
      }
      else {
        $arg = "'$arg'"
      }
    }
    $cmakeCommand += " -D$key=$arg"
  }
  $cmakeCommand += " $rootFolder"
  Write-Output "Generated CMake Command: $cmakeCommand"
  Invoke-Expression $cmakeCommand
}
function Compile {
  Set-Location $buildFolder
  $env:CMAKE_BUILD_PARALLEL_LEVEL = 12
  cmake --build . --config Release --target llama-cli llama-imatrix llama-perplexity llama-quantize llama-server
}

Configure
Compile
