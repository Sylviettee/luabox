#!/usr/bin/env bash

example=$1
lua=$2

[[ $lua = "" ]] && lua="lua"

cd examples/$1

for file in *.tl; do
    tl gen $file
done

$lua main.lua