#!/bin/bash

# Script to check if a diff between two Git branches includes changes in specified directories.

# Function to display usage information
usage() {
  echo "Usage: $0 <branch1> <branch2> <directory1> [directory2] ..."
  echo "  Checks if the diff between <branch1> and <branch2> includes changes in the specified directories."
  echo "  Directories can include wildcards (e.g., 'src/*')."
  echo "  Returns 1 if changes are found, 0 otherwise."
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
  echo "    match_directory_pattern: trying for"
  echo "    file_path = $file_path"
  echo "    directory_patterns = $directory_patterns"
  for pattern in "${directory_patterns[@]}"; do
    echo "      trying for pattern: $pattern"
    if [[ "$file_path" == "$pattern" ]]; then
      return 0 # Match found
    fi
    echo "      not an explicit match"
    
    local regexed_pattern="^$(echo "$pattern" | sed 's/\*/.*/g' | sed 's/\?/./g')$"
    echo "      regexed_pattern: $regexed_pattern"
    if [[ "$file_path" =~ $($regexed_pattern) ]]; then
      return 0;
    fi

    if [[ "$file_path" == $(echo "$pattern" | sed 's/\*/.*/g' | sed 's/\?/./g' | sed 's/\/\*\*/\/.*\/g') ]]; then #recursive wildcard match
        if [[ "$file_path" =~ $(echo "^$(echo "$pattern" | sed 's/\*/.*/g' | sed 's/\?/./g' | sed 's/\/\*\*/\/.*\/g')$") ]]; then
          return 0;
        fi
    fi
  
    
  done
  return 1 # No match found
}

# Get the list of changed files between the two branches
changed_files=$(git diff --name-only "$branch1" "$branch2")

echo "debug: changed files are"
echo "$changed_files"

# Check if any changed file matches the specified directories
found_changes=0
while IFS= read -r file; do
  if match_directory_pattern "$file"; then
    found_changes=1
    break # No need to check further if a match is found
  fi
done <<< "$changed_files"

echo "found_changes: $found_changes"

# Return 0 if changes were found, 1 otherwise
if [ "$found_changes" -eq 1 ]; then
  exit 0
else
  exit 1
fi
