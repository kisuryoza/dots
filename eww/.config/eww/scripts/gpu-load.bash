#!/usr/bin/env bash

GRAPHICS=$(lspci -v | grep -A1 -e VGA -e 3D)
case ${GRAPHICS^^} in
    *NVIDIA* )
        nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits
        ;;
    *AMD* | *ATI* )
        cat /sys/class/drm/card0/device/gpu_busy_percent
        ;;
    *INTEL* )
        ;;
esac
