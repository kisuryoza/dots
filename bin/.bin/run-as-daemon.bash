#!/usr/bin/env bash

SCRIPT="$(realpath -s "${BASH_SOURCE[0]}")"
SCRIPT_DIR=$(dirname "$SCRIPT")
source "$SCRIPT_DIR"/daemons/init

"$@"
