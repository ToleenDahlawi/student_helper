# Function to show available university majors based on GPA and gender and the college

gpa=$1

# If GPA is not provided, ask the user what to do
if [[ -z "$1" ]]; then
        echo "No GPA calculated. Choose an option "
        echo "  1) Enter your GPA   2) Cancel"

        read -p "Choose an option [1-2]: " op

        case $op in
            1) read -p "Enter your GPA: " gpa ;;
            2) exit 0 ;;
            *) echo "Invalid option."; exit 1 ;;
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

