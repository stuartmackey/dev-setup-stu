#!/usr/bin/env bash
set -euo pipefail

find_hwmon_by_name() {
  local target="$1"
  for d in /sys/class/hwmon/hwmon* /sys/devices/pci0000:00/*/*/hwmon/hwmon*; do
    [ -e "$d/name" ] || continue
    local name
    name=$(cat "$d/name" 2>/dev/null || echo "")
    if [ "$name" = "$target" ]; then
      echo "$d"
      return 0
    fi
  done
  return 1
}

gpu_dir=$(find_hwmon_by_name "amdgpu" || true)
[ -n "$gpu_dir" ] || { echo "amdgpu hwmon not found"; exit 1; }

pwm_file="$gpu_dir/pwm1"
temp_file="$gpu_dir/temp1_input"
enable_file="$gpu_dir/pwm1_enable"

# Tunables
MIN_TEMP=35   # °C: below this, keep minimum fan
MAX_TEMP=75   # °C: above this, full fan
MIN_PWM=40    # 0–255: ~24% (very quiet)
MAX_PWM=255   # 0–255: full speed
SLEEP=3       # seconds between updates

echo "Using hwmon at $gpu_dir"

while true; do
  if [ ! -r "$temp_file" ] || [ ! -w "$pwm_file" ]; then
    sleep "$SLEEP"
    continue
  fi

  # Put fan control into manual mode (usually: 1 = manual, 2 = auto)
  if [ -w "$enable_file" ]; then
    echo 1 > "$enable_file" 2>/dev/null || true
  fi

  raw_temp=$(cat "$temp_file")
  temp=$((raw_temp / 1000))

  if [ "$temp" -le "$MIN_TEMP" ]; then
    pwm="$MIN_PWM"
  elif [ "$temp" -ge "$MAX_TEMP" ]; then
    pwm="$MAX_PWM"
  else
    # linear interpolation
    pwm=$(( MIN_PWM + (temp - MIN_TEMP) * (MAX_PWM - MIN_PWM) / (MAX_TEMP - MIN_TEMP) ))
  fi

  # clamp just in case
  if [ "$pwm" -lt 0 ]; then pwm=0; fi
  if [ "$pwm" -gt 255 ]; then pwm=255; fi

  echo "$pwm" > "$pwm_file" 2>/dev/null || true

  sleep "$SLEEP"
done
