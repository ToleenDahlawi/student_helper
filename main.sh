#!/bin/bash

# Function to get input and validate it's a number between 0 and 100
get_score() {
    local prompt=$1
    local score
    while true; do
        read -p "$prompt (0-100): " score
        if [[ $score =~ ^[0-9]+(\.[0-9]+)?$ ]] && (( $(echo "$score >= 0 && $score <= 100" | bc -l) )); then
            echo $score
            return
        else
            echo "Invalid input. Please enter a number between 0 and 100."
        fi
    done
}

# Get the scores from the user
hs_score=$(get_score "Enter High School Cumulative Score")
gapt_score=$(get_score "Enter General Aptitude Test Score")
aat_score=$(get_score "Enter Academic Achievement Test Score")

# Calculate GPA
gpa=$(echo "scale=2; $hs_score*0.3 + $gapt_score*0.3 + $aat_score*0.4" | bc)

# Display result
echo "Calculated GPA: $gpa"
echo $gpa > gpa.txt

# If GPA is not provided, ask the user what to do
if [[ -z "$1" ]]; then
   if [[ -f gpt.txt ]]; then
    gpa=$(<gpa.txt)
    else
        echo "No GPA calculated. Choose an option "
        echo "  1) Enter your GPA   2) Cancel"

        read -p "Choose an option [1-2]: " op

        case $op in
            1) read -p "Enter your GPA: " gpa ;;
            2) exit 0 ;;
            *) echo "Invalid option."; exit 1 ;;
        esac
      fi
     else
        gpa=$1
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
      exit 1
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

# Function to calculate university cumulative GPA
calculate_cgpa() {
    while true; do
        read -p "What is your GPA scale? (4 or 5): " system
        [[ $system == 4 || $system == 5 ]] && break
        echo "Invalid scale. Please enter 4 or 5."
    done

    while true; do
        read -p "How many semesters? " terms
        [[ $terms =~ ^[1-9][0-9]*$ ]] && break
        echo "Please enter a valid number of semesters."
    done

    total_hours=0
    total_points=0

    for ((i=1; i<=terms; i++)); do
        while true; do
            read -p "Total credit hours for semester $i: " hours
            [[ $hours =~ ^[1-9][0-9]*$ ]] && break
            echo "Invalid input. Enter a positive integer."
        done
        while true; do
            read -p "Total grade points for semester $i: " points
            [[ $points =~ ^[0-9]+([.][0-9]+)?$ ]] && break
            echo "Invalid input. Enter a valid number."
        done
        total_hours=$((total_hours + hours))
        total_points=$(echo "$total_points + $points" | bc)
    done

    cgpa=$(printf "%.2f" "$(echo "$total_points / $total_hours" | bc -l)")

    if awk -v g="$cgpa" -v s="$system" 'BEGIN{exit !(g > s)}'; then
        echo "Error: GPA result exceeds maximum scale ($system). Check your input."
        return 1
    fi

    echo "Your cumulative GPA is: $cgpa out of $system"

    echo -e "GPA=$cgpa\nSYSTEM=$system\nCALCULATED=\"$(date)\"" > last_cgpa.txt
    echo "Saved to last_cgpa.txt."
}

# Function to check university honors eligibility
check_honors() {
    if [[ -f last_cgpa.txt ]]; then
        source last_cgpa.txt
        echo "Found saved GPA file."
        echo "Saved GPA: $GPA out of $SYSTEM (Calculated on $CALCULATED)"
        read -p "Do you want to use this GPA? (y/n): " use_saved
        if [[ $use_saved != "y" ]]; then
            read -p "Do you know your cumulative GPA? (y/n): " know_gpa
            if [[ $know_gpa == "y" ]]; then
                read -p "Enter your cumulative GPA: " GPA
                read -p "Enter GPA scale (4 or 5): " SYSTEM
            else
                echo "Redirecting to cumulative GPA calculator..."
                calculate_cgpa
                source last_cgpa.txt
            fi
        fi
    else
        echo "No saved GPA found."
        read -p "Do you know your cumulative GPA? (y/n): " know_gpa
        if [[ $know_gpa == "y" ]]; then
            read -p "Enter your cumulative GPA: " GPA
            read -p "Enter GPA scale (4 or 5): " SYSTEM
        else
            echo "Redirecting to cumulative GPA calculator..."
            calculate_cgpa
            source last_cgpa.txt
        fi
    fi

    echo "-------------------------------"
    echo "Your GPA is: $GPA out of $SYSTEM"

    honor_message_shown=false

    if [[ $SYSTEM == 5 ]]; then
        if awk -v g="$GPA" 'BEGIN{exit !(g >= 4.75)}'; then
            echo "Congratulations! You are eligible for First Class Honors."
            honor_message_shown=true
        elif awk -v g="$GPA" 'BEGIN{exit !(g >= 4.25)}'; then
            echo "Congratulations! You are eligible for Second Class Honors."
            honor_message_shown=true
        fi
    else
        if awk -v g="$GPA" 'BEGIN{exit !(g >= 3.75)}'; then
            echo "Congratulations! You are eligible for First Class Honors."
            honor_message_shown=true
        elif awk -v g="$GPA" 'BEGIN{exit !(g >= 3.25)}'; then
            echo "Congratulations! You are eligible for Second Class Honors."
            honor_message_shown=true
        fi
    fi

    if [[ $honor_message_shown == true ]]; then
        echo "Note: Honors eligibility may vary by university."
        echo "  1. No failing grades during the study period."
        echo "  2. Completing the program within the official study period."
        echo "  3. Completing at least 60% of coursework at the same university."
    else
        echo "Unfortunately, you are not eligible for honors."
    fi
}

# === MAIN MENU LOOP ===

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
      calculate_gpa
      ;;
    2)
      available_majors 
      ;;
    3)
      calculate_cgpa
      ;;
    4)
      check_honors
      ;;
    5)
      echo "Thank you for using our app"
      exit 0
      ;;
    *)
      echo "Invalid option."
      ;;
  esac
done
