#!/usr/bin/env sh

free | awk '$1 ~ /Mem/ {printf("%3u%%", 100*$3/$2)}'
