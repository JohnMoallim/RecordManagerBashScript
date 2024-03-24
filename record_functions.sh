#!/bin/bash

source utilities.sh

# Add or update a record
add_record() {
    local input="$1"
    local name quantity
    parse_record_input "$input" name quantity

    # Validate name and quantity
    if ! validate_record_name "$name" || ! validate_quantity "$quantity"; then
        return 1
    fi

    # Check if the record already exists
    local record_found=$(grep -E "^$name," "$RECORD_FILE")
    if [ "$record_found" != "" ]; then
        # Record exists, update quantity
        local new_quantity=$(($(echo $record_found | cut -d',' -f2) + quantity))
        # Use awk to update the record in place without a temp file
        awk -v name="$name" -v qty="$new_quantity" 'BEGIN{FS=OFS=","} $1 == name {$2 = qty} 1' "$RECORD_FILE" > temp && mv temp "$RECORD_FILE"
    else
        # Add new record
        echo "$name,$quantity" >> "$RECORD_FILE"
    fi
    echo "Record added/updated successfully."
    log_event "Add/Update Record - Name: $name, Quantity: $quantity"
}

# Search record
search_records() {
    local search_term="$1"
    grep "$search_term" "$RECORD_FILE" || {
        echo "No records found."
        log_event "Search" "Failure"
    }
}

delete_record() {
    local input="$1"
    local name quantity

    # Parse the input into name and quantity
    parse_record_input "$input" name quantity

    # Validate inputs
    if ! validate_record_name "$name" || ! validate_quantity "$quantity"; then
        echo "Validation failed for the input."
        return 1
    fi

    local matching_lines=$(grep -n "^$name," "$RECORD_FILE")
    local matching_count=$(echo "$matching_lines" | wc -l)

    if [[ $matching_count -eq 0 ]]; then
        echo "Record not found."
        return 1
    fi

    # Direct action for a single record or interactive selection for multiple
    if [[ $matching_count -eq 1 ]]; then
        local line_number=$(echo "$matching_lines" | cut -d':' -f1)
        adjust_or_delete_record "$line_number" "$quantity"
    else
        echo "Multiple records found. Please choose one by entering the line number:"
        echo "$matching_lines" | cut -d':' -f1-2
        read -p "Line number: " line_number
        adjust_or_delete_record "$line_number" "$quantity"
    fi
}

adjust_or_delete_record() {
    local line_number="$1"
    local delete_quantity="$2"
    local record=$(sed -n "${line_number}p" "$RECORD_FILE")
    local current_quantity=$(echo "$record" | cut -d',' -f2)
    local new_quantity=$((current_quantity - delete_quantity))

    if [[ $new_quantity -le 0 ]]; then
        # Delete the record
        sed -i "${line_number}d" "$RECORD_FILE"
        echo "Record deleted successfully."
    else
        # Update the record with the new quantity
        sed -i "${line_number}s/.*/$(echo "$record" | cut -d',' -f1),$new_quantity/" "$RECORD_FILE"
        echo "Record quantity updated successfully."
    fi
    log_event "Adjust/Delete Record - Name: $(echo "$record" | cut -d',' -f1), New Quantity: $new_quantity"
}

update_record_name() {
    local old_name="$1"
    local new_name="$2"
    if ! validate_record_name "$old_name" || ! validate_record_name "$new_name"; then
        return 1
    fi
    if grep -qE "^$old_name," "$RECORD_FILE"; then
        sed -i "s/^$old_name,/$new_name,/" "$RECORD_FILE"
        echo "Record name updated successfully."
        log_event "Update Record Name - Old: $old_name, New: $new_name"
    else
        echo "Original record not found."
    fi
}

update_record_quantity() {
    local name="$1"
    local quantity="$2"
    if ! validate_record_name "$name" || ! validate_quantity "$quantity"; then
        return 1
    fi
    add_record "$name" "$quantity"  # Re-use add_record for updating quantity.
}

print_all_records() {
    sort "$RECORD_FILE"
    log_event "Print All Records"
}

print_total_quantity() {
    local total=0
    while IFS=, read -r _ quantity; do
        total=$((total + quantity))
    done < "$RECORD_FILE"
    echo "Total quantity of all records: $total"
    log_event "Print Total Quantity"
}
