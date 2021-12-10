#!/bin/bash
# Automatic Tomcat Deployemnt for app

# get_stage is used to check if this is a PROD or QA Server
# Update ${app_rhel7} = "server_name" with servername required

# Use get stage only if paths diverge on different environments
function get_stage() {
  app_rhel7=$(hostname)
  if [ ${app_rhel7} = "server_name" ]; then
    stage="ap"
    application_link="https://app.net/"
  elif [ ${app_rhel7} = "server_name" ]; then
    stage="aq"
    application_link="https://app-q.net/"
  else
    echo "Unknown stage. This should not be used outside of app Q or app P."
  fi
}

get_stage
# Static Variables:

# Update tomcat_home with your location:
tomcat_home="PATH_TO_TOMCAT"

catalina_home="${tomcat_home}/logs"
webapps_home="${tomcat_home}/webapps"
deploy_home="${HOME}/deployments"
backup_home="${deploy_home}/backup"

function start_app() {
  echo "Stopping Application. Please wait"
  sudo systemctl stop tc_app.service
  echo "Application Stopped. Moving on..."
}

function stop_app() {
  echo "Starting Application. Please wait."
  sudo systemctl start tc_app.service
  echo "Application Started. Moving on..."
}

function continue_prompt() {
  read -p "To Continue type in 123456789: " choice
  case "${choice}" in
  123456789 ) echo "Moving on...";;
  * ) echo "Invalid answer. Please try again. Type 123456789 to continue";;
  esac
}

function create_backup_dir() {
  if [ -d "${backup_home}" ]; then
      echo "Backup folder exits. Moving on..."
  else
      echo "Creating backup folder"
      mkdir -p ${backup_home}
      echo "Backup folder created. Moving on... "
}

function backup_current_app() {
  echo "Backing up current ROOT directory and .war file"
  cp -R ${webapps_home}/ROOT ${backup_home}/ROOT.$(date +%d-%m-%Y-%H:%M:%S).backup
  cp -R ${webapps_home}/ROOT.war ${backup_home}/ROOT.war.$(date +%d-%m-%Y-%H:%M:%S).backup
  echo "Backup of ROOT directory and .war file done. Moving on..."
  echo "Backing up current scheduler directory and .war file"
  cp -R ${webapps_home}/scheduler ${backup_home}/scheduler.$(date +%d-%m-%Y-%H:%M:%S).backup
  cp -R ${webapps_home}/scheduler.war ${backup_home}/scheduler.war.$(date +%d-%m-%Y-%H:%M:%S).backup
  echo "Backup of ROOT directory and .war file done. Moving on..."
}

function backup_mssql() {
  echo "Please backup the MSSQL Server"
  continue_prompt
}

function remove_old_app() {
  echo "Removing current ROOT directory from ${webapps_home}"
  rm -rf ${webapps_home}/ROOT
  echo "Successfully removed ROOT directory from ${webapps_home}"
  echo "Removing current scheduler directory from ${webapps_home}"
  rm -rf ${webapps_home}/scheduler
  echo "Successfully removed scheduler directory from ${webapps_home}"
  echo "Removing *.war data from ${webapps_home}"
  rm -rf ${webapps_home}/*.war
  echo "Successfully removed *.war data from ${webapps_home}"
}

function copy_and_rename_new_app() {
  echo "Renaming files..."
  find ${deploy_home} -type -f -name "^app*.war" -exec mv '{}' ROOT.war \;
  find ${deploy_home} -type -f -name "^ROOT*.war" -exec mv '{}' ROOT.war \;
  echo "Rename complete. Moving files to ${webapps_home}"
  mv ${deploy_home}/ROOT.war ${webapps_home}/ROOT.war
}

function first_boot() {
  stop_app
  sleep 1m
  start_app
  tail -f {catalina_home}/catalina.out | sed '/INFO: Server startup in/ q'
  stop_app
}

# This stops the server and copies other needed files from the backup image
funcion copy_backup_data() {
  echo "Copying post-deploy data. Please wait..."
  cp ${backup_home}/ROOT*.backup/WEB-INF/classes/com/pwc/WebtoolConfig.properties ${webapps_home}/ROOT/WEB-INF/classes/com/pwc/WebtoolConfig.properties
  cp ${backup_home}/ROOT*.backup/WEB-INF/classes/repository-mssql.xml ${webapps_home}/ROOT/WEB-INF/classes/repository-mssql.xml
  cp ${backup_home}/ROOT*.backup/WEB-INF/web.xml ${webapps_home}/ROOT/WEB-INF/web.xml
  cp ${backup_home}/scheduler*.backup/WEB-INF/web.xml ${webapps_home}/scheduler/WEB-INF/web.xml
  echo "Successfully copied post-deploy data."
}

function execute_sql_script() {
  echo "Please execute MSSQL Scripts if there are any"
  continue_prompt
}

function final_start() {
  echo "This is the final boot"
  start_app
  tail -f {catalina_home}/catalina.out | sed '/INFO: Server startup in/ q'
  echo "Server has started, please verify ${application_link}"
}

centralize_functions() {
  stop_app
  create_backup_dir
  backup_current_app
  remove_old_app
  backup_mssql
  copy_and_rename_new_app
  first_boot
  copy_backup_data
  execute_sql_script
  final_start
}
