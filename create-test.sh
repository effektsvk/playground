#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Configuration
COUNTER_FILE="counter"
DEFAULT_BASE_BRANCH="main"  # Change if your default branch is different

# Function to initialize the counter file if it doesn't exist
initialize_counter() {
    if [ ! -f "$COUNTER_FILE" ]; then
        echo "1" > "$COUNTER_FILE"
        echo "Counter initialized to 1."
    fi
}

# Function to read the current counter value
get_current_counter() {
    cat "$COUNTER_FILE"
}

# Function to increment and save the counter
increment_counter() {
    local current=$1
    local next=$((current + 1))
    echo "$next" > "$COUNTER_FILE"
    echo "$next"
}

# Initialize counter if necessary
initialize_counter

# Read the current counter
COUNTER=$(get_current_counter)

# Define branch and file names
BRANCH_NAME="test${COUNTER}"
FILE_NAME="test${COUNTER}.txt"  # Added .txt extension for clarity

echo "=== Starting Process ==="
echo "Current Counter: $COUNTER"
echo "Branch Name: $BRANCH_NAME"
echo "File Name: $FILE_NAME"

# Create and switch to the new branch
git checkout -b "$BRANCH_NAME"
echo "Switched to new branch '$BRANCH_NAME'."

# Create the new file with some content
echo "This is test file number ${COUNTER}." > "$FILE_NAME"
echo "Created file '$FILE_NAME'."

# Stage the new file
git add "$FILE_NAME"
echo "Staged '$FILE_NAME' for commit."

# Commit the new file
git commit -m "Add ${FILE_NAME}"
echo "Committed '$FILE_NAME' to branch '$BRANCH_NAME'."

# Push the new branch to the remote repository
git push -u origin "$BRANCH_NAME"
echo "Pushed branch '$BRANCH_NAME' to remote."

# Create a Pull Request using GitHub CLI
PR_TITLE="Add ${FILE_NAME}"
PR_BODY="This PR adds ${FILE_NAME} for testing purposes."
echo "Creating Pull Request..."
PR_URL=$(gh pr create --title "$PR_TITLE" --body "$PR_BODY" --head "$BRANCH_NAME" --base "$DEFAULT_BASE_BRANCH" --json url --jq .url)

echo "Pull Request created: $PR_URL"

# Optional: Wait for a moment to ensure the PR is ready to be merged
sleep 2

# Merge the Pull Request using GitHub CLI
echo "Merging Pull Request..."
gh pr merge --auto --delete-branch
echo "Pull Request merged and branch '$BRANCH_NAME' deleted."

# Switch back to the default branch
git checkout "$DEFAULT_BASE_BRANCH"
echo "Switched back to branch '$DEFAULT_BASE_BRANCH'."

# Increment and save the counter
NEXT_COUNTER=$(increment_counter "$COUNTER")
echo "Counter updated to $NEXT_COUNTER."

echo "=== Process Completed Successfully ==="
