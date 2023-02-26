#!/bin/bash
#Made by Mick Beer to create a automated network detection system.
# Set the time interval between scans (in seconds)
interval=10

# Loop infinitely, scanning the network at the specified interval
while true; do
  # Set the location and name for the output file
  output_file="/tmp/network_scan_$(date +%Y%m%d_%H%M%S).txt"
  
  echo "Waiting for $interval seconds..."
  # Wait for the specified interval
  sleep "$interval"
  
  # Perform a new network scan and store the output in the output file
  echo "Performing new network scan..."
  nmap -vvv -sC -sV -Pn -A -sn 192.168.0.0/24 | pv -petr -s "$(nmap -sP 192.168.0.0/24 | wc -c)" > "$output_file"
  echo "New network scan completed."
  
  # Compare the new output to the previous output
  echo "Comparing network scan results..."
  diff_output=$(diff "$output_file" "$prev_file" 2>/dev/null)
  
  # If the output has changed, show the difference and notify the user
  if [ "$diff_output" != "" ]; then
    echo "Network scan results have changed:"
    echo "$diff_output"
    notify-send -u critical "ALERT: Network scan results have changed" "Check the output file for more details" && paplay /usr/share/sounds/freedesktop/stereo/alarm-clock-elapsed.oga
  else
    echo "Network scan results have not changed."
  fi
  
  # Set the previous output file to the current output file
  prev_file="$output_file"
done

