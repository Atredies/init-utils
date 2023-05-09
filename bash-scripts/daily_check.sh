#!/bin/bash

#STATIC SYS VARIABLES
diskusage=$(df -Ph | awk '{ if($5 > 0) print $0;}' | grep -v 'tmpfs')
loadaverage=$(top -n 1 -b |grep "load average:" | awk '{print $12, $13, $14}')
last_reboot=$(last reboot | awk '{print $5, $6, $7, $8}' | head -n1)
uptime=$(uptime | awk '{print $3, $4}' | sed -r 's/,//')

## FUNCTIONS
function get_stage() {
  if [[ -d '/path/to/stage/ap/' ]]; then
    stage='ap'
    sc_ci="P-11"
    nfs_stage='nfs_p'
    title='app DAILY CHECK REPORT PROD'
  elif [[ -d '/path/to/stage/aq/' ]]; then
    stage='aq'
    sc_ci="Q-11"
    nfs_stage='nfs_q'
    title='app DAILY CHECK REPORT QS'
  else
    echo "Unknown stage. This shouldn't be used outside of app Q OR app P"
  fi
}

## New Line

function print_new_line() {
  printf "\n"
}

## POPULATE *_stage VARIABLES
get_stage

## ADDITIONAL PATH VARIABLES
scripts_home="/path/to/stage/${stage}/app/tomcat/scripts"
daily_report_file="${scripts_home}/daily_check/${stage}_daily_report.txt"
catalina_home="/path/to/stage/${stage}/app/tomcat"
#catalina_home="/path/to/app/tomcat/logs/app"
rvs_home="/path/to/app/rvs/rvsEVO"
java_home="/path/to/app/java/jdk-11.0.10/bin/"
java_keytool="/path/to/app/java/jdk-11.0.10/bin/keytool"
sar_home="/var/log/sa"

## Python for email
python_mail="${scripts_home}/spam_cannon.py"
python_home='/bin/python'

## CHECK DAILY REPORT FILE
function check_daily_report_file() {
    if [ -f ${daily_report_file} ]; then
      echo "The app daily report file exists. Nothing to do here."
    else
      touch ${daily_report_file}
    fi
}

## Clear Previous Content of file
function clear_previous_content() {
        echo "" > ${daily_report_file}
}

## Adhoc notification for the 1st working day of every month
function adhoc_notification(){

  get_today=$(date "+%d")

  # To test comment the active variable and uncomment the one below
  # first_working_day_of_month=$(date "+%d")
  first_working_day_of_month=$(cal | awk 'NR>2 && NF>1{print NF<7?$1:$2;exit}')

## To test change 01 to the current day
        if [ "$get_today" -eq "$first_working_day_of_month" ]; then
          adhoc_data="
          It is the beginning of the Month. Monthly app Data will have to be processed. Please ask Service Desk team to raise a Ticket.
          \n
          \n Example of Ticket: REQUESTID
          \n Type of Ticket: Service Request
          \n Title: app  (P-11) | Monthly app User Activity Report for $(date +%B)
          \n Reported for: PO
          \n Assignment Group: AMS 
          \n Reported CI: app (P-11)
          \n Description: Monthly app Report - To be sent to MAILBOX via email.
          \n Documentation: https://link.com
          \n
          "

          echo -e $adhoc_data
        fi
}

## Memory SAR Average Calculation
#memory_yesterday=$(sar -r -f ${sar_home}/sa$(date +%d -d yesterday) -s 08:00:00 -e 23:56:00 | grep -i average | awk -F " " '{ sum = ($3-$5-$6)/($2+$3) * 100 } END {print sum}')
#memory_today=$(sar -r -f ${sar_home}/sa$(date +%d -d today) -e 07:56:00 | grep -i average | awk -F " " '{ sum = ($3-$5-$6)/($2+$3) * 100 } END {print sum}')
#function average_memory_24h(){
#  amx="${memory_today}"
#  amy="${memory_yesterday}"
#  memory_average=$(echo "scale=4; ($amx+$amy)/2" | bc)
#}

function hourly_ram(){
echo "Time Day mbmemfree mbmemused %memused mbbuffers mbcached mbcommit %commit"
for i in `seq 8 9`; do
  foo=$(sar -r -f ${sar_home}/sa$(date +%d -d yesterday) -s 0${i}:00:00 -e 0${i}:59:00 | grep -v -E 'kbmemfree|Linux' | sed '/^$/d' | grep "Average:" | awk '{ memfree=$2 / 1000; memused=$3 / 1000; buffers=$5 / 1000; cached=$6 / 1000; commit=$7 / 1000; print memfree, memused, $4"%", buffers, cached, commit, $8"%" }')
  echo "0${i}:00-0${i}:59 yesterday" ${foo}
done
for j in `seq 10 23`; do
  foo=$(sar -r -f ${sar_home}/sa$(date +%d -d yesterday) -s ${j}:00:00 -e ${j}:59:00 | grep -v -E 'kbmemfree|Linux' | sed '/^$/d' | grep "Average:" | awk '{ memfree=$2 / 1000; memused=$3 / 1000; buffers=$5 / 1000; cached=$6 / 1000; commit=$7 / 1000; print memfree, memused, $4"%", buffers, cached, commit, $8"%" }')
  echo "${j}:00-${j}:59 yesterday" ${foo}
done
for k in `seq 0 7`; do
  foo=$(sar -r -f ${sar_home}/sa$(date +%d -d today) -s 0${k}:00:00 -e 0${k}:59:00 | grep -v -E 'kbmemfree|Linux' | sed '/^$/d' | grep "Average:" | awk '{ memfree=$2 / 1000; memused=$3 / 1000; buffers=$5 / 1000; cached=$6 / 1000; commit=$7 / 1000; print memfree, memused, $4"%", buffers, cached, commit, $8"%" }')
  echo "0${k}:00-0${k}:59 today" ${foo}
done
}

function average_swap_24h(){
  echo "Time Day swapfree swapused %swapused swapcache %swapcache"
  swap_yesterday=$(sar -S -f ${sar_home}/sa$(date +%d -d yesterday) -s 08:00:00 -e 23:56:00 | grep -i average | awk '{ swapfree=$2 / 1000; swapused=$3 / 1000; swapcache=$5 / 1000; print "08:00-23:59 yesterday", swapfree, swapused, $4"%", swapcache, $6"%"}')
  swap_today=$(sar -S -f ${sar_home}/sa$(date +%d -d today) -e 07:56:00 | grep -i average | awk '{ swapfree=$2 / 1000; swapused=$3 / 1000; swapcache=$5 / 1000; print "00:00-07:59 today", swapfree, swapused, $4"%", swapcache, $6"%"}')
  echo ${swap_yesterday}
  echo ${swap_today}
}

## Load Average calculation per hour using SAR
## For 5 Minutes
# Variables for Loops
y=8
z=1
i=1

function hourly_loadaverage(){

## Yesterday AM Hours
until [ $y -gt 12 ]; do
  la_yesterday_am=$(sar -q -f ${sar_home}/sa$(date +%d -d yesterday) -s 08:00:00 -e 23:56:00 | awk '{print $1, $2, $5, $6, $7}' | grep -i AM | egrep "*${y}:*:*" | awk -F " " '{ sum+=$4 } END {print sum}')
  div_yesterday_am=$(sar -q -f ${sar_home}/sa$(date +%d -d yesterday) -s 08:00:00 -e 23:56:00 | awk '{print $1, $2, $5, $6, $7}' | grep -i AM |egrep "*${y}:*:*" | awk '{print $2}' | wc -l)
  load_average_result_am=$(echo "scale=2; ${la_yesterday_am}/${div_yesterday_am}" | bc)
  echo "${y}:00AM yesterday ${load_average_result_am}"
  ((y=y+1))
done

## Yesterday PM Hours
until [ $z -gt 12 ]; do
  la_yesterday_pm=$(sar -q -f ${sar_home}/sa$(date +%d -d yesterday) -s 08:00:00 -e 23:56:00 | awk '{print $1, $2, $5, $6, $7}' | grep -i PM | egrep "*${z}:*:*" | awk -F " " '{ sum+=$4 } END {print sum}')
  div_yesterday_pm=$(sar -q -f ${sar_home}/sa$(date +%d -d yesterday) -s 08:00:00 -e 23:56:00 | awk '{print $1, $2, $5, $6, $7}' | grep -i PM |egrep "*${z}:*:*" | awk '{print $2}' | wc -l)
  load_average_result_pm=$(echo "scale=2; ${la_yesterday_pm}/${div_yesterday_pm}" | bc)
  echo "${z}:00PM yesterday ${load_average_result_pm}"
  ((z=z+1))
done

## Twelve gets missed, so this is for that to be reported as well
twelvemiss=$(sar -q -f ${sar_home}/sa$(date +%d -d today) -e 07:56:00 | awk '{print $1, $5, $6, $7}' | egrep "12:" | awk -F " " '{ sum+=$4 } END {print sum}')
twelvemiss_div=$(sar -q -f ${sar_home}/sa$(date +%d -d today) -e 07:56:00 | awk '{print $1, $5, $6, $7}' | egrep "12:" | awk '{print $2}' | wc -l)
twelve=$(echo "scale=2; ${twelvemiss}/${twelvemiss_div}" | bc)
echo "12:00AM today ${twelve}"

## Today AM Hours
until [ $i -gt 7 ]; do
  la_today_am=$(sar -q -f ${sar_home}/sa$(date +%d -d today) -e 07:56:00 | awk '{print $1, $5, $6, $7}' | egrep "*${i}:*:*" | awk -F " " '{ sum+=$4 } END {print sum}')
  div_today_am=$(sar -q -f ${sar_home}/sa$(date +%d -d today) -e 07:56:00 | awk '{print $1, $5, $6, $7}' | egrep "*${i}:*:*" | awk '{print $2}' | wc -l)
  load_average_result_today=$(echo "scale=2; ${la_today_am}/${div_today_am}" | bc)
  echo "${i}:00AM today ${load_average_result_today}"
  ((i=i+1))
done
}

# #Useful for streamlining the data: sar -q |grep -v blocked | grep -v Linux |grep -v Average

## GET CATALINA LOG
function get_tomcat_log(){
        latest_catalina_log=$(find ${catalina_home}/logs/ -type f -name "catalina*" -print | sort | tail -n1 | xargs cat | grep -E '[0-9]{2}:[0-9]{2}:[0-9]{2}\.[0-9]{3}' | fgrep -v receive123 | fgrep -v username:null | fgrep -v succeeded | fgrep  'ERROR' | tail -10 )
        latest_localhost_access_log=$(find ${catalina_home}/logs/ -type f -name "localhost_access*log" -print | sort | tail -n1 | xargs cat | fgrep -v "+0200" | grep -vE 'HTTP/1.1 10*' | grep -vE 'HTTP/1.1 20*' | tail -10 )
        number_of_catalina=$(find ${catalina_home}/logs/ -type f -name "catalina*" -print | sort | tail -n1 | xargs cat | grep -E '[0-9]{2}:[0-9]{2}:[0-9]{2}\.[0-9]{3}' | fgrep -v receive123 | fgrep -v username:null | fgrep -v succeeded | fgrep -c 'ERROR')
        number_of_localhost=$(find ${catalina_home}/logs/ -type f -name "localhost_access*log" -print | sort | tail -n1 | xargs cat | fgrep -v "+0200" | grep -vE 'HTTP/1.1 10*' | grep -vE 'HTTP/1.1 20*' | wc -l)
}

function get_app_logs(){
## App Logs Variables
        latest_report_log=$(find ${catalina_home}/logs/app -type f -name "report*log" -print | sort | tail -n1 | xargs cat | fgrep -i "The report has failed" | tail -5)
        latest_intrest_curve_report_log=$(find ${catalina_home}/logs/app -type f -name "interest_curve_import*log" -print | sort | tail -n1 | xargs cat | fgrep "An interest-curve import has been started"  -A 9 |tail -5)
        latest_export_log=$(find ${catalina_home}/logs/app -type f -name "export*log" -print | sort | tail -n1 | xargs cat | fgrep -i "The export has failed" | tail -5)
        latest_import_log=$(find ${catalina_home}/logs/app -type f -name "localized_import*log" -print | sort | tail -n1 | xargs cat | fgrep -i "fehler" | tail -5)
        number_of_report=$(find ${catalina_home}/logs/app -type f -name "report*log" -print | sort | tail -n1 | xargs cat | fgrep -c "The report has failed")
        number_of_export=$(find ${catalina_home}/logs/app -type f -name "export*log" -print | sort | tail -n1 | xargs cat | fgrep -c "The export has failed")
        number_of_import=$(find ${catalina_home}/logs/app -type f -name "localized_import*log" -print | sort | tail -n1 | xargs cat | fgrep -c "fehler")
}
## SSL Check:
function get_certificates(){
        get_tomcat_ssl_status_truststore=$(echo "" | ${java_keytool} -list -v -keystore "/home/$(whoami)/.truststore" | grep -A7 "Alias name" | sed 's/Entry type: trustedCertEntry//' | sed '/Enter keystore password:/d' | sed '/^[[:space:]]*$/d')
        get_tomcat_ssl_status_keystore=$(echo "" | ${java_keytool} -list -v -keystore "/home/$(whoami)/.keystore" | grep -A8 "Alias name" | sed 's/Entry type: trustedCertEntry//' | sed '/Enter keystore password:/d' | sed '/^[[:space:]]*$/d')
}

## RVS VARIABLES:
function get_rvs_log(){
        latest_rvs_err_log=$(find ${rvs_home}/log -type f -name "monitor.log.*" -print | sort | tail -n1 | xargs cat | grep -v INF | grep -v CONNECTION_CLOSED | sed -r 's/^([^ ]+ ){3}//' | sort | uniq -c)
        number_of_rvs_err=$(find ${rvs_home}/log -type f -name "monitor.log.*" -print | sort | tail -n1 | xargs cat | grep -v INF | grep -v CERTIFICATE_EXPIRED | grep -c -E 'ERR|WRN' )
}

function print_to_file(){

## app Stage Title
        echo "------------------------------"
        echo ${title}
        echo "------------------------------"
        print_new_line
        if [[ -d '/path/to/stage/ap/' ]]; then
        adhoc_notification
        fi
        print_new_line
        print_new_line
        echo "------------------------------"
        echo "        U P T I M E"
        echo "------------------------------"
        print_new_line
        echo "LAST REBOOT: ${last_reboot}"
        print_new_line
        echo "UPTIME: ${uptime}"
        print_new_line
        echo "------------------------------"
        echo "    D I S K   U S A G E"
        echo "------------------------------"
        print_new_line
        echo -e "${diskusage} \n"
        echo "------------------------------"
        echo "   L O A D  A V E R A G E"
        echo "------------------------------"
        print_new_line
        echo "LOAD AVERAGE: "${loadaverage}
        print_new_line
        echo "HOURLY STATISTICS: "
        print_new_line
#        hourly_loadaverage | column -t -c Time,Day,LoadAvg
        hourly_loadaverage | column -t
        print_new_line
        echo "------------------------------"
        echo "        M E M O R Y"
        echo "------------------------------"
        hourly_ram | column -t
        print_new_line
        echo "------------------------------"
        echo "          S W A P"
        echo "------------------------------"
        average_swap_24h | column -t
        print_new_line
        echo "------------------------------"
        echo "   C A T A L I N A  L O G"
        echo "------------------------------"
        print_new_line
        echo "NUMBER OF ERRORS: ${number_of_catalina}"
        print_new_line
        echo "${latest_catalina_log}"
        print_new_line
        echo "------------------------------"
        echo "  L O C A L  H O S T  L O G"
        echo "------------------------------"
        print_new_line
        echo "NUMBER OF ERRORS: ${number_of_catalina}"
        print_new_line
        echo "${latest_localhost_access_log}"
        print_new_line
        echo "------------------------------"
        echo "    R E P O R T   L O G"
        echo "------------------------------"
        print_new_line
        echo "NUMBER OF ERRORS ${number_of_report}"
        print_new_line
        echo "${latest_report_log}"
        print_new_line
        echo "------------------------------"
        echo "    E X P O R T  L O G"
        echo "------------------------------"
        print_new_line
        echo "NUMBER OF ERRORS ${number_of_export}"
        print_new_line
        echo "${latest_export_log}"
        echo "------------------------------"
        echo "   I N T R E S T  L O G"
        echo "------------------------------"
        print_new_line
        echo "${latest_intrest_curve_report_log}"
        print_new_line
        echo "------------------------------"
        echo "     RVS  LOGS"
        echo "------------------------------"
        print_new_line
        echo "Number of errors or warnings::  ${number_of_rvs_err}"
        print_new_line
        echo "${latest_rvs_err_log}"
        print_new_line
        echo "------------------------------"
        echo "     S S L  C H E C K"
        echo "------------------------------"
        print_new_line
        echo "------------------------------"
        echo "TRUST STORE"
        echo "------------------------------"
        print_new_line
        echo "${get_tomcat_ssl_status_truststore}"
        print_new_line
        echo "------------------------------"
        echo "KEY STORE"
        echo "------------------------------"
        print_new_line
        echo "${get_tomcat_ssl_status_keystore}"
        echo "------------------------------"
        print_new_line
}
## Export for Python Mail Script:
mail(){
  $python_home $python_mail daily attach $daily_report_file

}

function centralize_functions(){
         clear_previous_content
         get_tomcat_log
         get_app_logs
         get_certificates
         get_rvs_log
         print_to_file
}

centralize_functions > $daily_report_file
mail
