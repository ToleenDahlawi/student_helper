#!/bin/bash

# Initialize variables to store user input and results
selected_college=""
student_gender=""
total_weight=0
eligible_majors=()

# Function to show a list of unique colleges from the majors.txt file
function show_colleges {
  echo ""
  echo "Available Colleges:"
  awk -F, 'NR>1 {print $1}' majors.txt | sort -u  # Skip header, extract college names, and sort uniquely
}

# Function to allow user to choose gender and college
function choose_college {
  # Loop until user enters a valid gender
  while true; do
    read -p "Enter your gender (Male/Female): " student_gender
    if [[ "$student_gender" =~ ^[a-zA-Z]+$ ]]; then
      student_gender="${student_gender^}"  # Capitalize the first letter (e.g., male → Male)
      if [[ "$student_gender" == "Male" || "$student_gender" == "Female" ]]; then
        break
      fi
    fi
    echo "Invalid input. Please enter 'Male' or 'Female' using letters only."
  done

  echo ""
  show_colleges  # Show list of available colleges
  echo ""

  # Loop until user enters a valid college name
  while true; do
    read -p "Enter the college name exactly as shown: " selected_college
    if [[ "$selected_college" =~ ^[a-zA-Z[:space:]]+$ ]]; then
      # Check if the college exists in the majors.txt file (excluding header)
      if awk -F, 'NR>1 {print $1}' majors.txt | grep -Fxq "$selected_college"; then
        break
      else
        echo "College not found. Please enter a valid college name from the list."
      fi
    else
      echo "Invalid input. Please enter letters and spaces only."
    fi
  done

  echo "Selected College: $selected_college"
}

# Function to calculate the weighted GPA based on 3 scores
function calculate_weighted {
  echo ""
  echo "Enter your scores to calculate weighted GPA:"

  # Prompt for High School grade and validate it
  while true; do
    read -p "High School Grade: " th
    if [[ "$th" =~ ^[0-9]+(\.[0-9]+)?$ ]] && (( $(echo "$th >= 0" | bc -l) )); then
      break
    else
      echo "Invalid input. Please enter a positive number."
    fi
  done

  # Prompt for Qudurat score and validate it
  while true; do
    read -p "Qudurat Score: " qd
    if [[ "$qd" =~ ^[0-9]+(\.[0-9]+)?$ ]] && (( $(echo "$qd >= 0" | bc -l) )); then
      break
    else
      echo "Invalid input. Please enter a positive number."
    fi
  done

  # Prompt for Tahsili score and validate it
  while true; do
    read -p "Tahsili Score: " hs
    if [[ "$hs" =~ ^[0-9]+(\.[0-9]+)?$ ]] && (( $(echo "$hs >= 0" | bc -l) )); then
      break
    else
      echo "Invalid input. Please enter a positive number."
    fi
  done

  # Weighted GPA formula: 30% high school, 30% Qudurat, 40% Tahsili
  total_weight=$(echo "scale=2; ($th * 0.3) + ($qd * 0.3) + ($hs * 0.4)" | bc)
  echo "Your Weighted GPA: $total_weight"
}

# Function to check eligibility for majors in the selected college
function check_eligibility {
  eligible_majors=()  # Reset the list of eligible majors
  echo ""
  echo "Checking eligibility within $selected_college..."

  # Read each line of majors.txt and check eligibility based on gender and GPA
  while IFS=, read -r college major male_gpa female_gpa; do
    if [[ "$college" == "$selected_college" ]]; then
      # Choose the required GPA based on gender
      if [[ "$student_gender" == "Male" ]]; then
        required="$male_gpa"
      else
        required="$female_gpa"
      fi

      # Compare user's GPA with the required GPA
      if (( $(echo "$total_weight >= $required" | bc -l) )); then
        eligible_majors+=("$major")  # Eligible
      else
        eligible_majors+=("$major not eligible (Required: $required)")  # Not eligible
      fi
    fi
  done < <(tail -n +2 majors.txt)  # Skip the header row

  # Show the results
  if [ ${#eligible_majors[@]} -eq 0 ]; then
    echo "No majors found for this college or college name may be incorrect."
  else
    echo "Eligibility Results:"
    for major in "${eligible_majors[@]}"; do
      echo "- $major"
    done
  fi
}

# Function to display a summary of user's input and results
function summary {
  echo ""
  echo " --- Summary ---"
  echo " Gender: $student_gender"
  echo " College: $selected_college"
  echo " Weighted GPA: $total_weight"
  echo " Eligibility Results:"
  for major in "${eligible_majors[@]}"; do
    echo "- $major"
  done
}

# Main menu loop
while true; do
  echo ""
  echo " Student Helper - Umm Al-Qura University"
  echo "==============================="
  echo "1. Show Colleges"
  echo "2. Choose Gender and College"
  echo "3. Calculate Weighted GPA"
  echo "4. Check Eligibility"
  echo "5. Show Summary"
  echo "6. Exit"
  echo "==============================="
  read -p "Enter a number from the menu: " choice

  # Menu options
  case $choice in
    1) show_colleges ;;       # Option to show list of colleges
    2) choose_college ;;      # Option to choose gender and college
    3) calculate_weighted ;;  # Option to enter scores and calculate weighted GPA
    4) check_eligibility ;;   # Option to check eligibility for majors
    5) summary ;;             # Option to display a summary of inputs/results
    6) echo "Thank you for using our program"; exit ;;  # Exit
    *) echo "Invalid choice, please try again." ;;  # Handle wrong input
  esac
done
