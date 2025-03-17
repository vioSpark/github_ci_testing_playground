#!/bin/bash

# Script to check if a diff between two Git branches includes changes in specified directories.
# written by vispark

# Function to display usage information
usage() {
  echo "Usage: $0 <branch1> <branch2> <directory1> [directory2] ..."
  echo "  Checks if the diff between <branch1> and <branch2> includes changes in the specified directories."
  echo "  Directories can include wildcards (e.g., 'src/*')."
  echo "  Returns 0 if changes are found, 1 otherwise. - cause bash is funny"
}

# Check if enough arguments are provided
if [ $# -lt 3 ]; then
  usage
  exit 1
fi

# Assign arguments to variables
branch1="$1"
branch2="$2"
shift 2 # Remove branch1 and branch2 from the argument list


echo "debug: branches read properly"
echo "debug: branch1 = $branch1"
echo "debug: branch2 = $branch2"

# Store directory patterns in an array
declare -a directory_patterns=("${@}")

# Function to check if a file path matches any of the directory patterns
match_directory_pattern() {
  local file_path="$1"
  echo "    match_directory_pattern: trying for:"
  echo "    file_path = $file_path"
  echo "    directory_patterns = $directory_patterns"
  for pattern in "${directory_patterns[@]}"; do
    echo "      trying for pattern: $pattern"
    if [[ "$file_path" == "$pattern" ]]; then
      echo "        found an explicit match - return 0"
      return 0
    fi
    echo "      not an explicit match"
    
    if [[ $file_path == $pattern ]]; then
      echo "      deglobbing found a match - return 0"
      return 0
    fi
    
  done
  echo "    No match found - return 1"
  return 1 # No match found
}

# Get the list of changed files between the two branches
changed_files=$(git diff --name-only "$branch1" "$branch2")

echo "debug: changed files are:"
echo "$changed_files"

# Check if any changed file matches the specified directories
found_changes=1
while IFS= read -r file; do
  if match_directory_pattern "$file"; then
    echo "found changes in $file - return value is 0"
    found_changes=0
    break
  else 
    echo "no changes found in $file - return value is 1"
  fi
done <<< "$changed_files"

# Return 0 if changes were found, 1 otherwise. But then be explicit in the test ( [[ ]] ), because that appears to behave differently? -- gotta love bash
echo "found chagnes: $found_changes"
if [[ "$found_changes" = "0" ]]; then
  echo "script returned with changes found"
  exit 0
else
  echo "script returned with no changes found"
  exit 1
fi
