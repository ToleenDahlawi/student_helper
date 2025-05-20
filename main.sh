#!/bin/bash

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
