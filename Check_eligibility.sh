# Check eligibility for majors within selected college
function check_eligibility {
  eligible_majors=()  # Reset the list
  echo ""
  echo "Checking eligibility within $selected_college..."

  #Read the majors.txt file line by line, skipping the header
  while IFS=, read -r college major male_gpa female_gpa; do
  #Check if the current line matches the selected collage
    if [[ "$college" == "$selected_college" ]]; then
    # Use the corrent GPA requirement based on the student's gender
      if [[ "$student_gender" == "Male" ]]; then
        required="$male_gpa"
      else
        required="$female_gpa"
      fi
      # Compare student's weghited GPA with the requirwd GPA using bc (floating point)
      if (( $(echo "$total_weight >= $required" | bc -l) )); then
        eligible_majors+=("$major")
         # Student is not eligble, add expanation with required GPA
      else
        eligible_majors+=("$major not eligible (Required: $required)")
      fi
    fi
  done < <(tail -n +2 majors.txt) # Skip the header line from the file
  # Display results
  if [ ${#eligible_majors[@]} -eq 0 ]; then
    echo "No majors found for this college or college name may be incorrect."
  else
    echo "Eligibility Results:"
    for major in "${eligible_majors[@]}"; do
      echo "- $major"
    done
  fi
}
