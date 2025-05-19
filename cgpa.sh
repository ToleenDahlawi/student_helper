#!/bin/bash

# Ask for the GPA scale (4.0 or 5.0)
while true; do
  read -p "What is your GPA scale? (4 or 5): " system
  [[ $system == 4 || $system == 5 ]] && break
  echo "Invalid scale. Please enter 4 or 5."
done

    # Input semester number
while true; do
    read -p "How many semesters? " terms
    [[ $terms =~ ^[1-9][0-9]*$ ]] && break
    echo "Please enter a valid number of semesters."
  done
  total_hours=0
  total_points=0
  for ((i = 1; i <= terms; i++)); do
    # Input credit hours for semester
    while true; do
      read -p "Total credit hours for semester $i: " hours
      [[ $hours =~ ^[1-9][0-9]*$ ]] && break
      echo "Invalid input. Enter a positive integer."
    done
    # Input grade points earned in the semester
    while true; do
      read -p "Total grade points for semester $i: " points
      [[ $points =~ ^[0-9]+([.][0-9]+)?$ ]] && break
      echo "Invalid input. Enter a valid number."
    done
    total_hours=$(( total_hours + hours ))    # Accumulate hours
    total_points=$(echo "$total_points + $points" | bc)  # Accumulate points
  done
  # Calculate cumulative GPA formula 
  cgpa=$(printf "%.2f" "$(echo "$total_points / $total_hours" | bc -l)")
  # Validation: GPA should not exceed the system max ( neither 4 nor 5)
  if awk -v g="$cgpa" -v s="$system" 'BEGIN{exit !(g > s)}'; then
    echo "Error: GPA result exceeds maximum scale ($system). Check your input."
    exit 1
  fi
  echo "Your cumulative GPA is: $cgpa out of $system"
 # output the result
 
# Save to file with date/time in English
timestamp=$(date "+%Y-%m-%d %H:%M:%S")
# Save to file with result and time
echo "GPA=$cgpa" > last_cgpa.txt
echo "SYSTEM=$system" >> last_cgpa.txt
echo -e "GPA=$cgpa\nSYSTEM=$system\nCALCULATED=\"$(date)\"" > last_cgpa.txt
echo "Saved to last_cgpa.txt."


