#!/bin/bash

## Variables

find_location='<location_of_file>'
home_location=$HOME
original_location="$HOME/scripts/originals/"

## Functions

function create_folder(){
        if [ -f ${original_location} ]; then
        echo "Folder Exists"
        else mkdir ${original_location}
        fi
}

function find_file(){
        find ${find_location} -type f -name "*.*" -print

}

function compare_files(){
        original_file=$(find $find_location -type f  -not -name "[A-Z]*[0-9]*.*[0-9]" -print |grep "[A-Z]*[0-9]")
        second_file=$(find $find_location -type f -name "[A-Z]*[0-9]*.*[0-9]" -print)

        cmp --silent $original_file $second_file && echo "Files are the Same" || echo "Files are Different"
}


function create_duplicate(){
        cd $find_location

        for file in *.*
        do
                cp -v "$file" $original_location"$file".original
                ls -latr $original_location
        done
}

function check_duplicate_lines(){
        find_file | xargs sort | uniq -cd
}


function redirect_uniq_lines(){
        find_file | xargs awk '!seen[$1]++' > $original_location"$file".uniqlines
}

function overwrite_main_file(){

        for replace in $original_location"$file".uniqlines
        do
                cat  $original_location"$file".uniqlines > $find_location"$file";
        done

}

function clean_up(){
        rm -rf $original_location
}

## Function calls for Menu

function copy_original(){
        create_folder
        find_file
        create_duplicate
}

function check_for_duplicates(){
        create_folder
        find_file
        check_duplicate_lines
}

function redirection_to_original(){
        create_folder
        find_file
        redirect_uniq_lines
        overwrite_main_file
}


function clean_env(){
        clean_up
}



function menu (){

        echo ""
        echo ""
        echo "For Step 4. You need to have two files or it will wait for user input - To exit CTRL + C"
        echo ""
        echo ""
        echo "-------------------"
        echo " M A I N - M E N U "
        echo "-------------------"
        echo "1. Copy Original   - ALWAYS USE THIS FIRST. This Makes a Copy of the original file"
        echo "2. Duplicate Lines - This Displays duplicate lines within the file"
        echo "3. Cleanup         - This Removes the Environment once you are done"
        echo "4. Compare Files   - This Checks if the Two files that are causing the issues are identical"
        echo "5. Exit            - Exits Script"
        echo "10. Redirect        - CAUTION: This Redirects Unique Lines on the Original file"
        echo ""
        echo ""
}

function options_menu(){
        read -p "Enter choice [ 1 - 5 ] OR 10 for REDIRECT: " choice
        echo ""
        echo ""
        case $choice in
                1) copy_original ;;
                2) check_for_duplicates ;;
                3) clean_env ;;
                4) compare_files ;;
                5) exit 0 ;;
                10) redirection_to_original ;;
                *) echo -e "ERROR" && sleep 2
        esac
        echo ""
}

function trap_ctrl(){
        echo ""
        echo ""
        echo " Ctrl + C caught... Exiting "
        echo ""
        exit 2
}

trap "trap_ctrl" 2


while true
        do
                menu
                options_menu
done
