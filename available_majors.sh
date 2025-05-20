#!/bin/bash

selected_college=""
student_gender=""
total_weight=0
eligible_majors=()

#display available colleges from majors.txt
function show_colleges {
    echo ""
    echo "Available Colleges:"
    awk -F, 'NR>1 {print $1}' majors.txt | sort -u
}
function choose_college {
    #Gender input with validation
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
   
    #Prompt user to enter the college name
    read -p "Enter the college: " $selected_college
    if [[ $(echo "$selected_college" | sed 's/^[ \t]*//;s/[ \t]*$//') ]]; then # Remove spaces
    selected_college=${selected_college,,}  # Convert to lowercase for comparison
    echo ""
    show_colleges
    echo ""
    # Check if the college exists in the majors.txt file
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
