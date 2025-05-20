#!/bin/bash

selected_college=""
student_gender=""
total_weight=0
eligible_majors=()

# Show available colleges
function show_colleges {
  echo ""
  echo "Available Colleges:"
  awk -F, 'NR>1 {print $1}' majors.txt | sort -u
}

# Choose gender and college
function choose_college {
  # Validate gender input
  while true; do
    read -p "Enter your gender (Male/Female): " student_gender
    if [[ "$student_gender" =~ ^[a-zA-Z]+$ ]]; then
      student_gender="${student_gender^}"  # Capitalize first letter
      if [[ "$student_gender" == "Male" || "$student_gender" == "Female" ]]; then
        break
      fi
    fi
    echo "Invalid input. Please enter 'Male' or 'Female' using letters only."
  done

  echo ""
  show_colleges
  echo ""

  # Loop until valid college name is entered
  while true; do
    read -p "Enter the college name exactly as shown: " selected_college
    if [[ "$selected_college" =~ ^[a-zA-Z[:space:]]+$ ]]; then
      # Check if entered college exists in majors.txt (ignoring header)
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
    read -p "Qudurat Score: " qd
    if [[ "$qd" =~ ^[0-9]+(\.[0-9]+)?$ ]] && (( $(echo "$qd >= 0" | bc -l) )); then
      break
    else
      echo "Invalid input. Please enter a positive number."
    fi
  done

  while true; do
    read -p "Tahsili Score: " hs
    if [[ "$hs" =~ ^[0-9]+(\.[0-9]+)?$ ]] && (( $(echo "$hs >= 0" | bc -l) )); then
      break
    else
      echo "Invalid input. Please enter a positive number."
    fi
  done

  total_weight=$(echo "scale=2; ($th * 0.3) + ($qd * 0.3) + ($hs * 0.4)" | bc)
  echo "Your Weighted GPA: $total_weight"
}

# Check eligibility for majors within selected college
function check_eligibility {
  eligible_majors=()  # Reset the list
  echo ""
  echo "Checking eligibility within $selected_college..."

  while IFS=, read -r college major male_gpa female_gpa; do
    if [[ "$college" == "$selected_college" ]]; then
      if [[ "$student_gender" == "Male" ]]; then
        required="$male_gpa"
      else
        required="$female_gpa"
      fi

      if (( $(echo "$total_weight >= $required" | bc -l) )); then
        eligible_majors+=("$major")
      else
        eligible_majors+=("$major not eligible (Required: $required)")
      fi
    fi
  done < <(tail -n +2 majors.txt)

  if [ ${#eligible_majors[@]} -eq 0 ]; then
    echo "No majors found for this college or college name may be incorrect."
  else
    echo "Eligibility Results:"
    for major in "${eligible_majors[@]}"; do
      echo "- $major"
    done
  fi
}

# Summary function
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
