#!/bin/bash

# [ GPA Calculation ] 

# Function to prompt the user for a score between 0 and 100 and validate it
get_score() {
    local prompt=$1
    local score
    while true; do
        read -p "$prompt (0-100): " score
        # Check if the input is a number within the valid range
        if [[ $score =~ ^[0-9]+(\.[0-9]+)?$ ]] && (( $(echo "$score >= 0 && $score <= 100" | bc -l) )); then
            echo $score
            return
        else
            echo "Invalid input. Please enter a number between 0 and 100."
        fi
    done
}

# Function to calculate GPA based on three weighted scores
calculate_gpa() {
    hs_score=$(get_score "Enter High School Cumulative Score")
    gapt_score=$(get_score "Enter General Aptitude Test Score")
    aat_score=$(get_score "Enter Academic Achievement Test Score")

    # Calculate GPA using the formula: 30% HS + 30% GAPT + 40% AAT
    gpa=$(echo "scale=2; $hs_score*0.3 + $gapt_score*0.3 + $aat_score*0.4" | bc)
    echo -e "\n Calculated GPA: $gpa"
    echo $gpa
}

# [ Available Majors ]
# Function to show available university majors based on GPA and gender
available_majors() {
gpa=$1

# If GPA is not provided, ask the user what to do
if [[ -z "$1" ]]; then
        echo "No GPA calculated. Choose an option:"
        echo "1) Calculate GPA   2) Enter your GPA   3) Cancel"
        read -p "Choose an option [1-3]: " opt

        case $opt in
            1) gpa=$(calculate_gpa) ;; # Call GPA calculation function
            2) read -p "Enter your GPA: " gpa ;;
            3) return ;;
            *) echo "Invalid option."; return ;;
        esac
    fi

    # Prompt user to enter gender and normalize the input
    while true; do
        read -p "Enter your gender (male/female): " gender
        gender=$(echo "$gender" | sed 's/^[ \t]*//;s/[ \t]*$//') # Remove spaces
        gender=${gender,,}  #convert to lowercase
        
        if [[ "$gender" == "male" || "$gender" == "female" ]]; then
            break
        else
            echo " Invalid input. Please enter 'male' or 'female'."
        fi
    done
   
    # Prompt user to enter the college name
    read -p "Enter the college: " college
    college=$(echo "$college" | sed 's/^[ \t]*//;s/[ \t]*$//')  # Remove spaces
    college_lc=${college,,}  # Convert to lowercase for comparison

    # Check if the college exists in the majors.csv file
   if ! cut -d',' -f1 majors.csv | grep -iq "^$college$"; then
       echo "Sorry, the college you entered is not available"
      return
   fi

    # Display the majors available for the selected college and gender
    echo -e "\nThe majors in the ${college^} College:"
    echo "--------------------------------------------"

    # Read majors.csv and print majors where the GPA meets the requirement for the user's gender
    # Use sed to remove the header (first line) from majors.csv, then process the remaining lines
     sed 1d majors.csv | while IFS=',' read -r col major min_gpa_male min_gpa_female; do
    # Convert the college name in the file to lowercase for case-insensitive comparison
    col_lc=$(echo "$col" | tr '[:upper:]' '[:lower:]')

    # Compare user-entered college name with current line's college name
    if [[ "$col_lc" == "$college" ]]; then
        if [[ "$gender" == "male" ]]; then
            # Compare user's GPA with the minimum required GPA for males
            comp=$(echo "$gpa >= $min_gpa_male" | bc)
            if [[ "$comp" -eq 1 ]]; then
                # If user's GPA is sufficient, display the major
                echo "- $major (Minimum GPA: $min_gpa_male)"
            fi
        else
            # Compare user's GPA with the minimum required GPA for females
            comp=$(echo "$gpa >= $min_gpa_female" | bc)
            if [[ "$comp" -eq 1 ]]; then
                # If user's GPA is sufficient, display the major
                echo "- $major (Minimum GPA: $min_gpa_female)"
            fi
        fi
    fi
done
}

# [ University GPA ]
University_GPA(){
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
}

# [ Check_honor ]
# Honors eligibility checker script
Check_honor(){
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
}

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


#  [ Main Menu ] 

# Loop to display the main menu and handle user choices
while true; do
    echo -e "\n Welcome to the Student Helper \n Please choose the number of the service you want :"
    echo "1) Calculate GPA"
    echo "2) Show Available Majors Based on My GPA"
    echo "3) Exit"
    read -p "Choose an option [1-3]: " choice

    case $choice in
        1)
            gpa=$(calculate_gpa)  # Call GPA calculator
            ;;
        2)
            available_majors"$gpa"  # Show suitable majors
            ;;
        3)
            echo " Thank you for using Student Helper!"
            break
            ;;
        *)
            echo " Invalid option. Please select 1, 2, or 3."
            ;;
    esac
done
