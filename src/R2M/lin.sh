#!/bin/bash

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
PYTHON_SCRIPT="$SCRIPT_DIR/create_links.py"

# --- Python Script Check ---
if [ ! -f "$PYTHON_SCRIPT" ]; then
    echo "ERROR: Could not find 'create_links.py' at: $PYTHON_SCRIPT"
    echo "Please make sure both scripts are in the same folder."
    exit 1
fi

# --- Root Check ---
# Creating symlinks, especially in system-wide locations,
# often requires root/sudo privileges.
if [ "$EUID" -ne 0 ]; then 
    echo "Warning: You are not running this script as root (sudo)."
    echo "Creating symbolic links may fail due to permissions."
    echo "If it fails, please try running again with: sudo ./run_links.sh"
    echo "-------------------------------------------------------------"
    echo ""
fi

# ####################################################################
# --- Hardcoded Paths ---
# ####################################################################

# --- Dynamically get MOD_NAME from thunderstore.toml ---
TOML_FILE="$SCRIPT_DIR/../thunderstore.toml"

if [ ! -f "$TOML_FILE" ]; then
    echo "ERROR: Could not find 'thunderstore.toml' at: $TOML_FILE"
    echo "This file is required to automatically determine the mod name."
    exit 1
fi

# Parse the toml file.
# - grep: Finds the exact line (e.g., 'namespace = "purpIe"')
# - awk -F '"': Sets the field separator to a quote (") and prints the 2nd field.
TS_NAMESPACE=$(grep '^namespace =' "$TOML_FILE" | awk -F '"' '{print $2}')
TS_NAME=$(grep '^name =' "$TOML_FILE" | awk -F '"' '{print $2}')

if [ -z "$TS_NAMESPACE" ] || [ -z "$TS_NAME" ]; then
    echo "ERROR: Could not parse namespace or name from '$TOML_FILE'."
    exit 1
fi

# Construct the final MOD_NAME variable
MOD_NAME="$TS_NAMESPACE-$TS_NAME"
echo "--- Found Mod: $MOD_NAME ---"

# --- Set other paths ---
PROFILE_NAME="h2-dev"

# MOD_NAME="purpIe-Artificer_Indicator"
# PROFILE_NAME="h2-dev"

# NOTE: We use "$HOME/.config" as the Linux/macOS equivalent of "%APPDATA%\Roaming"
PROFILE_PATH="$HOME/.config/r2modmanPlus-local/HadesII/profiles/$PROFILE_NAME/ReturnOfModding"

# Get the true, absolute path to the project root (one level up from the script)
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." &> /dev/null && pwd)"

# We use $PROJECT_ROOT to build clean, absolute paths
FOLDER1="$PROJECT_ROOT/src"
FOLDER2="$PROJECT_ROOT/data"

# Set link paths using the variables
LINK1="$PROFILE_PATH/plugins/$MOD_NAME"
LINK2="$PROFILE_PATH/plugins_data/$MOD_NAME"


# ####################################################################

echo ""
echo "--- Calling Python Script with hardcoded paths ---"
echo "  Target 1: $FOLDER1"
echo "  Link 1:   $LINK1"
echo "  Target 2: $FOLDER2"
echo "  Link 2:   $LINK2"
echo ""

# --- Execute Script ---
# We try 'python3' first, then fall back to 'python'
# The quotes "$VARIABLE" are crucial to handle paths with spaces.
if command -v python3 &> /dev/null; then
    python3 "$PYTHON_SCRIPT" "$FOLDER1" "$FOLDER2" "$LINK1" "$LINK2"
else
    python "$PYTHON_SCRIPT" "$FOLDER1" "$FOLDER2" "$LINK1" "$LINK2"
fi

echo ""
echo "--- Script finished. ---"