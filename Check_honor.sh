#!/bin/bash

# Honors eligibility checker script

# Check if a previously saved GPA file exists
if [[ -f last_cgpa.txt ]]; then
  # Load the saved GPA data
  source last_cgpa.txt
  echo "Found saved GPA file."
  echo "Saved GPA: $GPA out of $SYSTEM (Calculated on $CALCULATED)"
 
  # Ask if the user wants to reuse the saved GPA
  read -p "Do you want to use this GPA? (y/n): " use_saved
  if [[ $use_saved != "y" ]]; then
    # Ask if the user knows their GPA
    read -p "Do you know your cumulative GPA? (y/n): " know_gpa
    if [[ $know_gpa == "y" ]]; then
      # User enters GPA and the GPA system (out of 4 or 5)
      read -p "Enter your cumulative GPA: " GPA
      read -p "Enter GPA scale (4 or 5): " SYSTEM
    else
      # Redirect to GPA calculator script
      echo "Redirecting to cumulative GPA calculator..."
      bash cgpa.sh
      source last_cgpa.txt  # Reload the generated GPA data
    fi
  fi
else
  # No GPA file found, ask user to enter or calculate
  echo "No saved GPA found."
  read -p "Do you know your cumulative GPA? (y/n): " know_gpa
  if [[ $know_gpa == "y" ]]; then
    # Manual input of GPA and system
    read -p "Enter your cumulative GPA: " GPA
    read -p "Enter GPA scale (4 or 5): " SYSTEM
  else
    # Call external GPA calculator
    echo "Redirecting to cumulative GPA calculator..."
    bash cgpa.sh
    source last_cgpa.txt
  fi
fi

# Display the GPA being used
echo "-------------------------------"
echo "Your GPA is: $GPA out of $SYSTEM"

# Initialize honors eligibility flag
honor_message_shown=false

# Determine eligibility based on GPA system (5-point or 4-point)
if [[ $SYSTEM == 5 ]]; then
  # First Class Honors (GPA >= 4.75)
  if awk -v g="$GPA" 'BEGIN{exit !(g >= 4.75)}'; then
    echo "Congratulations! You are eligible for First Class Honors."
    honor_message_shown=true
  # Second Class Honors (GPA >= 4.25)
  elif awk -v g="$GPA" 'BEGIN{exit !(g >= 4.25)}'; then
    echo "Congratulations! You are eligible for Second Class Honors."
    honor_message_shown=true
  fi
else
  # For 4-point system:
  # First Class Honors (GPA >= 3.75)
  if awk -v g="$GPA" 'BEGIN{exit !(g >= 3.75)}'; then
    echo "Congratulations! You are eligible for First Class Honors."
    honor_message_shown=true
  # Second Class Honors (GPA >= 3.25)
  elif awk -v g="$GPA" 'BEGIN{exit !(g >= 3.25)}'; then
    echo "Congratulations! You are eligible for Second Class Honors."
    honor_message_shown=true
  fi
fi

# If eligible, show additional requirements
if [[ $honor_message_shown == true ]]; then
  echo "Note: Honors eligibility may vary by university."
  echo "  1. No failing grades during the study period."
  echo "  2. Completing the program within the official study period."
  echo "  3. Completing at least 60% of coursework at the same university."
else
  echo "Unfortunately, you are not eligible for honors."
fi
