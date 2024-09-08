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
      $path | ForEach-Object { $_ -replace '\\', '/' }
    } else {
      $path -replace '\\', '/'
    }
  }
}

$thisFolder = Split-Path -Parent $MyInvocation.MyCommand.Definition | NormalizePath
$rootFolder = Split-Path -Parent $thisFolder | NormalizePath

$cFlags = '-march=znver2 -mtune=znver2 -O3'
$flags = @{
  'CMAKE_BUILD_TYPE' = 'Release'
  'CMAKE_C_COMPILER' = 'clang'
  'CMAKE_C_FLAGS' = $cFlags
  'CMAKE_CUDA_ARCHITECTURES' = 'native'
  'CMAKE_CUDA_COMPILER_TOOLKIT_ROOT' = $env:CUDA_PATH
  'CMAKE_CUDA_FLAGS' = '-t6'
  'CMAKE_CXX_COMPILER' = 'clang++'
  'CMAKE_CXX_FLAGS' = $cFlags
  'CMAKE_POSITION_INDEPENDENT_CODE' = '1'
  'GGML_CUDA_F16' = '1'
  'GGML_CUDA_FA_ALL_QUANTS' = '1'
  'GGML_CUDA_NO_PEER_COPY' = '1'
  'GGML_CUDA' = '1'
  'GGML_NATIVE' = '1'
  'GGML_SYCL_TARGET' = 'NVIDIA'
}

function Run {
  $buildFolder = "$rootFolder/build"
  $buildFolderExists = Test-Path $buildFolder
  if ($buildFolderExists) {
    Remove-Item -Recurse -Force $buildFolder
  } else {
    New-Item -ItemType Directory -Path $buildFolder
  }
  Set-Location $buildFolder
  $cmakeCommand = 'cmake'
  foreach ($key in $flags.Keys) {
    $arg = $flags[$key]
    if ($arg -match '\s') {
      # if contains single quote
      if ($arg -match "'") {
        $arg = '"' + $arg + '"'
      } else {
        $arg = "'$arg'"
      }
    }
    $cmakeCommand += " -D$key=$arg"
  }
  $cmakeCommand += ' .'
  Write-Output "Generated CMake Command: $cmakeCommand"
  Invoke-Expression $cmakeCommand
  cmake --build . --config Release -j 8
}

Run
