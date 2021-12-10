#!/bin/bash
# Static variables
xml_home='<path_to_tomcat_xml>'
# Flyway variables
export JAVA_HOME=/path/to/tomcat/java/jdk-11.0.9 # Update this with jdk path
path_to_flyway=/home/load/flyway-5.1.4
flyway_option=$1
db_schema=$2
#############################################################################
if [ $# != 2 ]; then
   echo "You must pass exactly 2 parameters to flyway. Example: run_flyway.sh migrate gui"
   exit 0
fi
#############################################################################
# FUNCTIONS:
function get_data_from_xml() {
    # Defining required variables
    FLYWAY_PASSWORD=$(cat ${xml_home} | grep -oP '(?<=password=").*?(?=")' | sed 's/\&quot\;/\"/' | head -${number_required} | tail -1)
}
function export_variables() {
    echo "Exporting required variables"
    export FLYWAY_PASSWORD
}
function execute_flyway() {
    echo  "Executing ${path_to_flyway}/flyway -configFiles=${path_to_flyway}/conf/${conf_home} ${flyway_option}"
    ${path_to_flyway}/flyway -configFiles=${path_to_flyway}/conf/${conf_home} ${flyway_option}
}
function flyway_centralized() {
    get_data_from_xml
    export_variables
    execute_flyway
}
function adm_func() {
    conf_home="adm.conf"
    number_required="1"
    flyway_centralized
}
function input_func() {
    conf_home="input.conf"
    number_required="2"
    flyway_centralized
}
function storage_func() {
    conf_home="storage.conf"
    number_required="3"
    flyway_centralized
}
function history_func() {
    conf_home="history.conf"
    number_required="4"
    flyway_centralized
}
function  gui_func() {
    conf_home="gui.conf"
    number_required="5"
    flyway_centralized
}
function output_func() {
    conf_home="output.conf"
    number_required="6"
    flyway_centralized
}
case $db_schema in
    # CASE ALL:
    all)
    adm_func
    input_func
    storage_func
    history_func
    gui_func
    ;;
    # CASE ADM:
    adm)
    adm_func
    ;;
    # CASE INPUT
    input)
    input_func
    ;;
    # CASE STORAGE
    storage)
    storage_func
    ;;
    # CASE HISTORY
    history)
    history_func
    ;;
    # CASE GUI
    gui)
    gui_func
    ;;
    # CASE OUTPUT
    output)
    output_func
    ;;
    # ERROR HANDLING
    *)
    echo "Incorrect keyword. Should be: all, adm, input, storage, history, gui or output."
    ;;
  esac
##done
echo "database migration done"