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
