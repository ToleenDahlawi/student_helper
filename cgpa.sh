#!/bin/bash

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
