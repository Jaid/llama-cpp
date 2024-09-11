#!/bin/env pwsh
$ErrorActionPreference = 'Stop'

$thisFolder = Split-Path -Parent $MyInvocation.MyCommand.Definition | ForEach-Object { $_ -replace '\\', '/' }
$rootFolder = Split-Path -Parent $thisFolder | ForEach-Object { $_ -replace '\\', '/' }

$before = "console.dir({`n  apiKeys: Object.fromEntries(Object.entries(process.env)"
$after = "`n})"

$model = 'D:/ai/llm/codestral-v0.1_22b_q4km.gguf'

# Prompt format hints: https://github.com/TabbyML/registry-tabby/blob/3f159188ce06bc3c4e3fe89d80e877fd7b448567/models.json
# if model contains "starcoder", case-insensitive
if ($model -match 'starcoder') {
  $prompt = "<fim_prefix>$before<fim_suffix>$after<fim_middle>"
} elseif ($model -match 'codestral') {
  $prompt = "<s>[SUFFIX]$after[PREFIX]$before"
} elseif ($model -match 'gemma') {
  $prompt = "<|fim_prefix|>$before<|fim_suffix|>$after<|fim_middle|>"
} else {
  $prompt = "<｜fim▁begin｜>$before<｜fim▁hole｜>$after<｜fim▁end｜>"
}

. "$rootFolder/build/bin/Release/llama-cli" --model $model --threads 8 --prompt $prompt --seed 0 --temp 0.01 --top-k 10 --predict 100 --gpu-layers 100000
