#!/bin/env pwsh
$ErrorActionPreference = 'Stop'

$thisFolder = Split-Path -Parent $MyInvocation.MyCommand.Definition | ForEach-Object { $_ -replace '\\', '/' }
$rootFolder = Split-Path -Parent $thisFolder | ForEach-Object { $_ -replace '\\', '/' }

. "$rootFolder/build/bin/Release/llama-server" --host 10.0.0.10 --port 3000 --model D:/ai/llm/starcoder2_7b-q6k.gguf --threads 8 -n 128 --temp 0.1 --top-k 10

# Example configuration: https://github.com/FredericoPerimLopes/llm-vscode/blob/8ce12669cedd4ba572dcc5ca2ae08634955a26e8/src/configTemplates.ts#L135-L160
