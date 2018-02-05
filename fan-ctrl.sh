#!/bin/sh

#PWM-Fan speeds at trip temps
PWM_VALS="70 80 100 160" # Values have to increase

PWM_CONFIG="/sys/devices/platform/pwm-fan/hwmon/hwmon0/fan_speed"
CUR_SPEED="/sys/devices/platform/pwm-fan/hwmon/hwmon0/pwm1"

sudo chmod a+rw $PWM_CONFIG $CUR_SPEED
sudo echo "$PWM_VALS" > $PWM_CONFIG
