#!/bin/bash

source config.sh

parse_record_input() {
    local input="$1"
    local -n name_ref=$2
    local -n quantity_ref=$3

    name_ref=$(echo "$input" | awk '{$1=$1;print}' | cut -d',' -f1 | xargs)
    quantity_ref=$(echo "$input" | awk '{$1=$1;print}' | cut -d',' -f2 | xargs)
}

# Log events
log_event() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $@" >> "$LOG_FILE"
}

# Validate record name: letters, numbers, and spaces
validate_record_name() {
    if [[ "$1" =~ ^[a-zA-Z0-9\ ]+$ ]]; then
        return 0 # valid
    else
        echo "Invalid record name: Only letters, numbers, and spaces are allowed."
        return 1 # invalid
    fi
}

# Validate quantity: positive integers only
validate_quantity() {
    if [[ "$1" =~ ^[0-9]+$ ]] && [ "$1" -gt 0 ]; then
        return 0 # valid
    else
        echo "Invalid quantity: Only positive integers are allowed."
        return 1 # invalid
    fi
}

# Validation for numeric input
validate_numeric_input() {
    if ! [[ $1 =~ ^[0-9]+$ ]]; then
        echo "Invalid input: Numeric value expected."
        return 1
    fi
    return 0
}

# Initialize function
initialize() {

    # Check and create files if they do not exist
    [[ ! -f "$RECORD_FILE" ]] && touch "$RECORD_FILE" && echo "Initialized $RECORD_FILE"
    [[ ! -f "$LOG_FILE" ]] && touch "$LOG_FILE" && echo "Initialized $LOG_FILE"
}