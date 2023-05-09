#!/bin/bash

get_stage

# Useful environment variables
java_home="/path/to/tomcat/java/jdk1.8.0_251/bin"
scripts_home="path/to/stage/APP/tomcat/scripts"
catalina_home="path/to/stage/APP/tomcat"

# Variables for Sending email via PYTHON:
python_mail="${scripts_home}/spam_cannon.py"
python_home='/bin/python'

rvs_check="${scripts_home}/check_infra/check_rvs_spam_email.txt"
nfs_check="${scripts_home}/check_infra/check_nfs_spam_email.txt"
tomcat_check="${scripts_home}/check_infra/check_tomcat_spam_email.txt"
mssql_check="${scripts_home}/check_infra/check_mssql_spam_email.txt"

loadaverage_check="${scripts_home}/check_infra/check_loadaverage_spam_email.txt"
export loadaverage_check

# NON-REDUNDANT EMAIL ALERTING:

#This func is needed so that we have some persistent memory store for previous sent emails.
#There's no need for more than 1 alert if a component is down. We'll keep this tracking with 0 or 1 values in these files.

function email_spam_check_monitor_file() {
  component=$1
  if [ ! -f "$scripts_home"/check_infra/check_"${component}"_spam_email.txt ]; then
    echo "The monitor file for APP ${i} Infrastucture monitoring does not exist. Creating it."
    echo "0" > ${scripts_home}/check_infra/check_"${component}"_spam_email.txt
  else
    echo "The monitor file for APP ${component} Infrastructure monitoring exists."
  fi
}

#Finally, we're ready to do non-redundant email alerting.
function email_alert() {
  type_of_alert=$1
  case ${type_of_alert} in
    nfs)
      previous_alert_check_nfs=$(cat ${scripts_home}/check_infra/check_"${type_of_alert}"_spam_email.txt)
      if [[ ${previous_alert_check}_nfs -eq 0 ]]; then
        $python_home $python_mail nfs noattach
        echo "1" > ${scripts_home}/check_infra/check_nfs_spam_email.txt
      else
        echo "The APP ${sc_ci} NFS mount point /nfs/${nfs_stage} is not available. Already sent alert for it. Exiting."
      fi
      ;;
    tomcat)
      previous_alert_check_tomcat=$(cat ${scripts_home}/check_infra/check_"${type_of_alert}"_spam_email.txt)
      if [[ ${previous_alert_check_tomcat} -eq 0 ]]; then
        $python_home $python_mail tomcat noattach
        echo "1" > ${scripts_home}/check_infra/check_tomcat_spam_email.txt
      else
        echo "The APP ${sc_ci} Tomcat instance is not running. Already sent alert for it. Exiting."
      fi
      ;;
    rvs)
      previous_alert_check_rvs=$(cat ${scripts_home}/check_infra/check_"${type_of_alert}"_spam_email.txt)
      if [[ ${previous_alert_check_rvs} -eq 0 ]]; then
        $python_home $python_mail rvs noattach
        echo "1" > ${scripts_home}/check_infra/check_rvs_spam_email.txt
      else
        echo "The APP ${sc_ci} RVS station is not available. Already sent alert for it. Exiting."
      fi
      ;;
    mssql)
      previous_alert_check_mssql=$(cat ${scripts_home}/check_infra/check_"${type_of_alert}"_spam_email.txt)
      if [[ "$previous_alert_check_mssql" -eq 0 ]]; then
        $python_home $python_mail mssql noattach
        echo "1" > ${scripts_home}/check_infra/check_mssql_spam_email.txt
      else
        echo "The APP ${sc_ci} MS SQL Database - ${mssql_stage} is not available. Already sent alert for it. Exiting."
      fi
      ;;
    loadaverage)
      previous_alert_check_loadaverage=$(cat ${scripts_home}/check_infra/check_"${type_of_alert}"_spam_email.txt)
      if [[ "$previous_alert_check_loadaverage" -eq 0 ]]; then
        $python_home $python_mail loadaverage noattach
        echo "1" > ${scripts_home}/check_infra/check_loadaverage_spam_email.txt
      else
        echo "The APP ${sc_ci} Load Average - Not Healthy. Already sent alert for it. Exiting."
      fi
      ;;
    *)
      echo "Improper use of email_alert. Exiting."
      ;;
  esac
}


# AVAILABLITY CHECKS:

# Checks RVS Station

function check_rvs() {
  email_spam_check_monitor_file rvs
  rvs_pid=$(ps -ef | grep rvs | grep system | awk '/[rvs]/{print $2}')
  #to test, change != to =
  if [ "$rvs_pid" != "" ]; then
    echo "RVS UP: $rvs_pid"
    echo "0" > ${scripts_home}/check_infra/check_rvs_spam_email.txt
  else
    email_alert rvs
  fi
}

# Checks the APP NFS mount point availability.

function check_nfs() {
  email_spam_check_monitor_file nfs
  #to test, change nfs_check to anything else
  if [ -f /nfs/${nfs_stage}/rvs/nfs_check ]; then
    echo "The APP NFS is available. Moving on."
    echo "0" > ${scripts_home}/check_infra/check_nfs_spam_email.txt
  else
    email_alert nfs
  fi
}

# Checks the Tomcat instance availability on the APP server itself

function check_tomcat() {
  email_spam_check_monitor_file tomcat
  ps -ef | grep -v 'grep' | grep -o $(cat ${catalina_home}/catalinarunning.pid)
  #to test, change from -ne to -eq
  if [ ${PIPESTATUS[1]} -ne 0 ]; then
    email_alert tomcat
  else
    echo "The APP Tomcat instance is up. Moving on"
    echo "0" > ${scripts_home}/check_infra/check_tomcat_spam_email.txt
  fi
}

# MS SQL Server Availability Check

function check_mssql() {
  email_spam_check_monitor_file mssql
  check_port_connection=$(timeout 5 /bin/bash -c "cat < /dev/null > /dev/tcp/${mssql_stage}/1433")
  # to test, change from -eq to -ne
  if [[ "$check_port_connection" -eq '' ]]; then
    echo 'MsSQL backend is up'
    echo "0" > ${scripts_home}/check_infra/check_mssql_spam_email.txt
  else
    email_alert mssql
  fi
}

# Check APP Loadaverage

function check_loadaverage() {
  email_spam_check_monitor_file loadaverage
  check_load_average=$(uptime | awk '{print $11}' | sed 's/,//g')
  # to test, change value to 0
  if [[ "$check_load_average" < 8 ]]; then
    echo "LoadAverage is fine"
    echo "0" > ${scripts_home}/check_infra/check_loadaverage_spam_email.txt
  else
    email_alert loadaverage
  fi
}

check_rvs
check_nfs
check_tomcat
check_mssql
check_loadaverage
