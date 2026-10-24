#!/usr/bin/env bash
set -euo pipefail

read_cpu() {
    awk '/^cpu / { total=0; for(i=2;i<=9;i++) total+=$i; print total, $5+$6; exit }' /proc/stat
}
read -r total1 idle1 < <(read_cpu)
sleep 0.2
read -r total2 idle2 < <(read_cpu)
cpu=0
if (( total2 > total1 )); then
    cpu=$((100 * ((total2-total1)-(idle2-idle1)) / (total2-total1)))
fi
memory=$(awk '/MemTotal:/ {t=$2} /MemAvailable:/ {a=$2} END {printf "%.0f", 100*(t-a)/t}' /proc/meminfo)
temperature=null
for sensor in /sys/class/hwmon/hwmon*/name; do
    [[ -r "$sensor" ]] || continue
    read -r name < "$sensor"
    case "$name" in
        coretemp|k10temp|zenpower)
            if [[ -r "${sensor%/name}/temp1_input" ]]; then
                read -r value < "${sensor%/name}/temp1_input"
                temperature=$((value / 1000))
                break
            fi
            ;;
    esac
done
batteries=()
for battery in /sys/class/power_supply/*; do
    [[ -r "$battery/type" && -r "$battery/capacity" ]] || continue
    read -r type < "$battery/type"
    [[ "$type" == Battery ]] || continue
    read -r capacity < "$battery/capacity"
    read -r status < "$battery/status"
    icon=""
    [[ "$status" != Charging ]] || icon=""
    batteries+=("$icon $capacity%")
done
jq -cn --argjson cpu "$cpu" --argjson memory "$memory" \
    --argjson temperature "$temperature" --args \
    '{cpu:$cpu,memory:$memory,batteries:$ARGS.positional} + (if $temperature == null then {} else {temperature:$temperature} end)' "${batteries[@]}"
