#!/bin/env pwsh
$ErrorActionPreference = 'Stop'

$thisFolder = Split-Path -Parent $MyInvocation.MyCommand.Definition | ForEach-Object { $_ -replace '\\', '/' }
$rootFolder = Split-Path -Parent $thisFolder | ForEach-Object { $_ -replace '\\', '/' }

. "$rootFolder/bin/Release/llama-cli.exe" --model C:/Users/jaid/Downloads/yi-coder-9b-q8_0.gguf --threads 8 --prompt 'const piString = `' --seed 0
