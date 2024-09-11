#!/bin/env pwsh
$ErrorActionPreference = 'Stop'

$thisFolder = Split-Path -Parent $MyInvocation.MyCommand.Definition | ForEach-Object { $_ -replace '\\', '/' }
$rootFolder = Split-Path -Parent $thisFolder | ForEach-Object { $_ -replace '\\', '/' }

. "$rootFolder/bin/Release/llama-minicpmv-cli.exe" --model C:/Users/jaid/Downloads/ggml-model-Q8_0.gguf --mmproj C:/Users/jaid/Downloads/mmproj-model-f16.gguf -p 'What texts are on this image?' --temp 0.1 --image 'C:/Users/jaid/Pictures/in/shareX/2024-09/full/2024-09-06_05-00-09.png'
