#!/bin/bash

# Calculate weighted GPA
function calculate_weighted {
  echo ""
  echo "Enter your scores to calculate weighted GPA:"

  # Validate each score
  while true; do
    read -p "High School Grade: " th
    if [[ "$th" =~ ^[0-9]+(\.[0-9]+)?$ ]] && (( $(echo "$th >= 0" | bc -l) )); then
      break
    else
      echo "Invalid input. Please enter a positive number."
    fi
  done
while true; do
    read -p "General Aptitude Test Score: " qd
    if [[ "$qd" =~ ^[0-9]+(\.[0-9]+)?$ ]] && (( $(echo "$qd >= 0" | bc -l) )); then
      break
    else
      echo "Invalid input. Please enter a positive number."
    fi
  done
while true; do
    read -p "Academic Achievement Test Score: " hs
    if [[ "$hs" =~ ^[0-9]+(\.[0-9]+)?$ ]] && (( $(echo "$hs >= 0" | bc -l) )); then
      break
    else
      echo "Invalid input. Please enter a positive number."
    fi
  done
