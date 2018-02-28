#!/bin/bash

# Execute with watch to easily monitor your CPU Temperatures and Frequencies on all cores

echo "Temperatures"
cat /sys/devices/virtual/thermal/*/temp
echo
echo "Frequencies"
cat /sys/devices/system/cpu/cpu*/cpufreq/scaling_cur_freq
