#!/usr/bin/env bash

case "$1" in
"NVIDIA")
    nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits
    ;;
"AMD")
    cat /sys/class/drm/card0/device/gpu_busy_percent
    ;;
esac
