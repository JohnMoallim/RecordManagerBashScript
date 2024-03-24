#!/bin/bash

source config.sh
source record_functions.sh
source utilities.sh

initialize

# Main menu loop
while true; do
    clear;
    echo "Please choose an option:"
    echo "1) Add a record"
    echo "2) Delete a record"
    echo "3) Update a record name"
    echo "4) Update a record quantity"
    echo "5) Search for records"
    echo "6) Print the total quantity of all records"
    echo "7) Print all records sorted"
    echo "8) Exit"
    read -p "Option: " option

    case "$option" in
        1)
            read -p "Enter name and quantity: " name quantity
            add_record "$name" "$quantity"
            ;;
        2)
            read -p "Enter name of record to delete: " name
            delete_record "$name"
            ;;
        3)
            read -p "Enter old name and new name: " old_name new_name
            update_record_name "$old_name" "$new_name"
            ;;
        4)
            read -p "Enter name and new quantity: " name quantity
            update_record_quantity "$name" "$quantity"
            ;;
        5)
            read -p "Enter search term: " search_term
            search_records "$search_term"
            ;;
        6)
            print_total_quantity
            ;;
        7)
            print_all_records
            ;;
        8)
            echo "Exiting."
            break
            ;;
        *)
            echo "Invalid option. Please try again."
            ;;
    esac
    echo "Press any key to return to the main menu..."
    read -n 1
done
