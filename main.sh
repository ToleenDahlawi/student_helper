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
