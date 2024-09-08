#!/bin/env pwsh
$ErrorActionPreference = 'Stop'

$thisFolder = Split-Path -Parent $MyInvocation.MyCommand.Definition | ForEach-Object { $_ -replace '\\', '/' }
$rootFolder = Split-Path -Parent $thisFolder | ForEach-Object { $_ -replace '\\', '/' }

. "$rootFolder/bin/Release/llama-server.exe" --host 127.0.0.1 --port 3500 --model C:/Users/jaid/Downloads/ggml-model-Q8_0.gguf --mmproj C:/Users/jaid/Downloads/mmproj-model-f16.gguf --image 'C:/Users/jaid/Pictures/in/shareX/2024-09/full/2024-09-06_05-00-09.png'
