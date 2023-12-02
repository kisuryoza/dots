#!/usr/bin/env sh

sar -u 1 1 | awk 'ENDFILE {usage=100-$NF; printf("%3u%%", usage)}'
