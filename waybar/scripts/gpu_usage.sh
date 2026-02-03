#!/bin/bash

vendor=$(supergfxctl --vendor 2>/dev/null)
mode=$(supergfxctl --get 2>/dev/null)

# usage="N/A"
# temp="N/A"

usage=$(nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits)
temp=$(nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits)


echo "{\"text\":\"󰢮 ${usage}% | ${temp}°C \", \"tooltip\":\"Vendor: ${vendor}\nMode: ${mode}\nUsage: ${usage}%\nTemp: ${temp}°C\"}"
