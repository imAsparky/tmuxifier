#!/bin/bash
# Set a custom session root path. Default is `$HOME`.
# Must be called before `initialize_session`.
default_session_root="~/Projects/{{SESSION_NAME}}"
echo {{SESSION_NAME}}
echo "Session root-default: $default_session_root"  # Print the session_root
# Function to validate and create a directory if it doesn't exist
validate_and_create_dir() {
  local dir="$1"
  while true; do
    if [[ -d "$dir" ]]; then
      echo "$dir"  # Echo the valid directory
      break
    else
      read -p "Directory '$dir' does not exist. Create? [y/n] " choice
      case $choice in
        [Yy]*) mkdir -p "$dir"; echo "$dir"; break;; # Echo after creation
        [Nn]*) read -p "Enter a valid path: " dir;;
        *) echo "Invalid choice.";;
      esac
    fi
  done
}

# 1. Prompt for session root
PS3="Choose session root: "

# Define the options array with the current value of TMUX_SESSION_ROOT
options=(
  "Environment variable (TMUX_SESSION_ROOT)$(if [[ -z "$TMUX_SESSION_ROOT" ]]; then echo " (Not currently set)"; else echo " (Currently set to: $TMUX_SESSION_ROOT)"; fi)"
  "Default ($default_session_root)"
  "Custom path"
  "Quit"
)

# Use the options array in the select statement
select choice in "${options[@]}"; do 
  case $REPLY in 
    1) # Environment variable
      if [[ -z "$TMUX_SESSION_ROOT" ]]; then
        echo "Environment variable TMUX_SESSION_ROOT not set."
        echo "Please make another selection!"
        continue # Continue to next iteration of loop to ask for input again
      else
        session_root=$(validate_and_create_dir "$TMUX_SESSION_ROOT")
      fi
      ;;
    2) # Default
      session_root=$(validate_and_create_dir "$default_session_root") 
      ;;
    3) # Custom path
      read -p "Enter path: " session_root
      session_root=$(validate_and_create_dir "$session_root")  
      ;;
    4) # Quit
      exit 0  
      ;;
    *) echo "Invalid choice.";;
  esac

  # Break out of the loop once a valid path is obtained
  if [[ -d "$session_root" ]]; then
    break 
  fi
done  

echo "Session root-before initialise: $session_root"  # Print the session_root
# session_root='/home/mark/projects/worktrees/django-ckeditors'

# Create session with specified name if it does not already exist. If no
# argument is given, session name will be based on layout file name.
if initialize_session "{{SESSION_NAME}}"; then

  # Create a new window inline within session layout definition.
  #new_window "misc"
  #split_v 50

  # Load a defined window layout.
  #load_window "example"

  # Select the default active window on session creation.
  #select_window 1

fi

# Finalize session creation and switch/attach to it.
finalize_and_go_to_session
