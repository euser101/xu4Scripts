#!/bin/bash

echo "Temperatures"
cat /sys/devices/virtual/thermal/*/temp
echo
echo "Frequencies"
cat /sys/devices/system/cpu/cpu*/cpufreq/scaling_cur_freq
