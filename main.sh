#!/bin/bash

calculate_gpa() {
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

    hs_score=$(get_score "Enter High School Cumulative Score")
    gapt_score=$(get_score "Enter General Aptitude Test Score")
    aat_score=$(get_score "Enter Academic Achievement Test Score")

    gpa=$(echo "scale=2; $hs_score*0.3 + $gapt_score*0.3 + $aat_score*0.4" | bc)
    echo "Calculated GPA: $gpa"
    echo $gpa
}

available_majors() {
    local gpa=$1

    if [[ -z "$gpa" ]]; then
        echo "No GPA calculated or provided. Choose an option:"
        echo "1) Calculate GPA"
        echo "2) Enter your GPA manually"
        echo "3) Cancel"
        read -p "Choose an option [1-3]: " op

        case $op in
            1) gpa=$(calculate_gpa) ;;
            2) read -p "Enter your GPA: " gpa ;;
            3) return ;;
            *) echo "Invalid option."; return ;;
        esac
    fi

    while true; do
        read -p "Enter your gender (male/female): " gender
        gender=${gender,,}
        if [[ "$gender" == "male" || "$gender" == "female" ]]; then
            break
        else
            echo "Invalid input. Please enter 'male' or 'female'."
        fi
    done

    read -p "Enter the college: " college
    college_lc=${college,,}

    if [[ ! -f majors.csv ]]; then
        echo "Error: majors.csv file not found!"
        return
    fi

    echo -e "\nAvailable majors in ${college^} College for $gender with GPA $gpa:"
    echo "--------------------------------------------------"

    found=false

    tail -n +2 majors.csv | while IFS=',' read -r col major min_male min_female; do
        col=${col,,}
        if [[ "$col" == "$college_lc" ]]; then
            found=true
            if [[ "$gender" == "male" ]]; then
                comp=$(echo "$gpa >= $min_male" | bc)
                if [[ $comp -eq 1 ]]; then
                    echo "- $major (Minimum GPA: $min_male)"
                fi
            else
                comp=$(echo "$gpa >= $min_female" | bc)
                if [[ $comp -eq 1 ]]; then
                    echo "- $major (Minimum GPA: $min_female)"
                fi
            fi
        fi
    done

    if ! grep -qi "^$college_lc," majors.csv; then
        echo "Sorry, the college you entered is not available."
    fi
}

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
