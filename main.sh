#!/bin/bash

# Main menu for student helper project

while true; do
  echo "=============================="
  echo "     STUDENT HELPER     "
  echo "=============================="
  echo "1. Calculate High School GPA"
  echo "2. Show UQU Majors Based on GPA"
  echo "3. Calculate University Cumulative GPA"
  echo "4. Check University Honor Eligibility"
  echo "5. Exit"
  echo "------------------------------"
  read -p "Choose an option: " choice

  case $choice in
    1)
      GPA_calculator.sh
      ;;
    2)
      available_majors 
      ;;
    3)
     cgpa.sh
      ;;
    4)
      Check_honors.sh
      ;;
    5)
      echo "Thank you for using our program"
      exit 0
      ;;
    *)
      echo "Invalid choice. Please enter a number from 1 to 5."
      ;;
  esac

  echo ""
done
