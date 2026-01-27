
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

gpu_dir=$(find_hwmon_by_name "amdgpu" || echo "")
cpu_dir=$(find_hwmon_by_name "k10temp" || echo "")

gpu_text="GPU ?°C"
cpu_text="CPU ?°C"
tooltip_lines=()

if [ -n "$gpu_dir" ]; then
  if [ -r "$gpu_dir/temp1_input" ]; then
    gpu_temp_raw=$(cat "$gpu_dir/temp1_input")
    gpu_temp=$((gpu_temp_raw / 1000))
  else
    gpu_temp="?"
  fi

  if [ -r "$gpu_dir/fan1_input" ]; then
    gpu_rpm=$(cat "$gpu_dir/fan1_input")
  else
    gpu_rpm="?"
  fi

  if [ -r "$gpu_dir/pwm1" ]; then
    pwm_raw=$(cat "$gpu_dir/pwm1")
    gpu_pwm_pct=$((pwm_raw * 100 / 255))
  else
    gpu_pwm_pct="?"
  fi

  gpu_text="GPU ${gpu_temp}°C ${gpu_pwm_pct}%"
  tooltip_lines+=("GPU: ${gpu_temp}°C, fan: ${gpu_rpm} RPM, PWM: ${gpu_pwm_pct}%")
else
  tooltip_lines+=("GPU: not found")
fi

if [ -n "$cpu_dir" ]; then
  if [ -r "$cpu_dir/temp1_input" ]; then
    cpu_temp_raw=$(cat "$cpu_dir/temp1_input")
    cpu_temp=$((cpu_temp_raw / 1000))
    cpu_text="CPU ${cpu_temp}°C"
    tooltip_lines+=("CPU: ${cpu_temp}°C")
  else
    tooltip_lines+=("CPU: temp sensor missing")
  fi
else
  tooltip_lines+=("CPU: hwmon k10temp not found")
fi

text="${gpu_text} | ${cpu_text}"

# Join tooltip lines with literal "\n" so JSON stays valid
tooltip=$(printf '%s\n' "${tooltip_lines[@]}" | sed ':a;N;$!ba;s/\n/\\n/g')

# Escape double quotes for JSON safety
text_esc=${text//\"/\\\"}
tooltip_esc=${tooltip//\"/\\\"}

printf '{"text":"%s","tooltip":"%s","class":"%s"}\n' \
  "$text_esc" "$tooltip_esc" "normal"
