#!/bin/bash

###############################################
###                                         ###
### Tool Options:                           ###
###                                         ###
### 1. Checks if PORT is Listening          ###
###                                         ###
### 2. Rechecks PORT using different logic  ###
###                                         ###
### 3. Checks for Calalina PID              ###
###                                         ###
### 4. Starts Tomcat Server                 ###
###                                         ###
### 5. Stops Tomcat Server                  ###
###                                         ###
### 6. Check Calatina Log for Tomcat Start  ###
###                                         ###
### 7. Imports Keystore Certificate         ###
###                                         ###
### 8. Imports Truststore Certificate       ###
###                                         ###
### 9. Exit                                 ###
###                                         ###
###############################################

# Clears Screen
clear

# Variables

# Variable for Menu

editor=vim

# Environment Variables

function get_stage() {
  if [ -d '/<path/to/directory>' ]; then
    app_stage="directory_name"
    app_sc_ci="CI"
    app_nfs_stage="nfsname"
    app_mssql_stage="dbname"
  elif [ -d '/<path/to/directory>' ]; then
    app_stage="directory_name"
    app_sc_ci="CI"
    app_nfs_stage="nfsname"
    app_mssql_stage="dbname"
  else
    echo "Unknown stage. This should not be used outside of app Q or app P."
  fi
}

get_stage

# Variables for Paths

tomcat_bin="</path/to/tomcat/bin"
catalina_home="<path/to/catalina/catalina.out>"
keytool="<path/to/catalina>"

# Check Tomcat Port

state=$(netstat -na | grep 0.0.0.0:8443 | awk '{print $6}')
recheck=$(netstat -na | grep 0.0.0.0:8443 | awk '{print $6}' | wc -l)

# Get Tomcat PID

tomcat_pid=$(ps -ef | awk '/[t]omcat/{print $2}')

# Function for menu

function pause(){
  read -p "Press [Enter] key to continue" fackEnterKey
}

# Function for checking PORT

check_port_function(){

if [ "$state" = "LISTEN" ];
  then echo "Tomcat is UP"

elif [ "$state" = "" ];
  then echo "Tomcat is DOWN";
fi
}

# Check if there is output for PORT

recheck_port_function(){

if [ "$recheck" = 0 ];
  then echo "RECHECK: Tomcat not Listening (DOWN)"

elif [ "$recheck" != 0 ];
  then echo "RECHECK: Tomcat Listening (UP)"
fi
}

# Get Tomcat PID

check_pid_function(){

if [ "$tomcat_pid" != "" ];
        then echo "Tomcat PID: $tomcat_pid"

else echo "No PID, Tomcat DOWN"

fi
}

# Start Tomcat

function tomcat_start(){
        echo "Starting Tomcat..."
        bash ${tomcat_bin}/startup.sh
}


# Stop Tomcat

function tomcat_stop(){
        echo "Stopping Tomcat..."
        bash ${tomcat_bin}/shutdown.sh
}

# Function for checking Catalina Log for Server Startup

function catalina_log(){
        echo "Checking Catalina Log..."
        tail -150 $catalina_home | fgrep -i 'server startup'
}

## Function for Importing Truststore Certificate

function import_truststore(){
        read -p "Please enter Absolute Path & KEYSTORE Certificate Name: " truststore_cert
        echo ""
        read -p "Please enter Certificate Alias: " truststore_alias
        echo "Importing Truststore Certificate..."
        exec ${keytool} -import -trustcacerts -keystore "${HOME}/.truststore" -storepass changeit -noprompt -alias ${truststore_alias} -file ${truststore_cert}
        echo ""
        echo "Certificate Imported"
}

# Function for Importing Keystore Certificate

function import_keystore(){
        read -p "Please enter Absolute Path & Certificate Name: " truststore_cert
        echo ""
        read -p "Please enter Certificate Alias: " truststore_alias
        echo "Importing Keystore Certificate..."
        exec ${keytool} -import -trustcacerts -keystore "${HOME}/.keystore" -storepass changeit -noprompt -alias ${truststore_alias} -file ${truststore_cert}
        echo ""
        echo "Certificate Imported"
}


# Function to Display Menu

function menu(){
        echo ""
        echo "-------------------"
        echo " M A I N - M E N U "
        echo "-------------------"
        echo "1. Check Tomcat PORT"
        echo "2. Recheck Tomcat PORT"
        echo "3. Check Tomcat PID"
        echo "4. Start Tomcat"
        echo "5. Stop Tomcat"
        echo "6. Check Catalina Log"
        echo "7. Mutual SSL - Import Keystore"
        echo "8. Mutual SSL - Import Truststore"
        echo "9. Exit"
        echo ""
}


## Function for Selection Options

function options_read(){
        read -p "Enter choice [ 1 - 9 ]:" choice
        echo ""
        case $choice in
                1) check_port_function ;;
                2) recheck_port_function ;;
                3) check_pid_function ;;
                4) tomcat_start ;;
                5) tomcat_stop ;;
                6) catalina_log ;;
                7) import_keystore ;;
                8) import_truststore ;;
                9) exit 0 ;;
                *) echo -e "ERROR" && sleep 2
        esac
}

## Trigger for Quit Signals such as (CTRL + C)

function trap_ctrl(){
        echo ""
        echo ""
        echo " Ctrl + C caught... Exiting "
        echo ""
        exit 2
}

trap "trap_ctrl" 2


## Logic & Loop for Menu

while true
        do
        menu
                options_read
done