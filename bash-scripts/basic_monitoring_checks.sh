#!/bin/bash
# Quick and dirty commands to get some fast info on a linux server

printf "\n"
printf "DISK USAGE\n"

diskusage=$(df -h | grep 'Filesystem\|/dev/mapper/vg01*')
echo -e "Disk Usage :" $diskusage

printf "\n"
printf "LOAD AVERAGE\n"

loadaverage=$(top -n 1 -b | grep "load average:" | awk '{print $12}')
echo -e "Load Average :" $loadaverage

printf "\n"
printf "RAM\n"

totalmemory=$(free -h | awk '{print $1, $2, $3, $4}' | grep Mem | awk '{print $2}')
echo -e "Total Memory :" $totalmemory

usedmemory=$(free -h | awk '{print $1, $2, $3}' | grep Mem | awk '{print $3}')
echo -e "Used Memory  :" $usedmemory

freememory=$(free -h | awk '{print $1, $2, $4}' | grep Mem | awk '{print $3}')
echo -e "Free Memory  :" $freememory

printf "\n"
printf "SWAP\n"

totalswap=$(free -h | awk '{print $1, $2, $3, $4}' | grep Swap | awk '{print $2}')
echo -e "Total SWAP :" $totalswap

usedswap=$(free -h | awk '{print $1, $2, $3}' | grep Swap | awk '{print $3}')
echo -e "Used SWAP  :" $usedswap

freeswap=$(free -h | awk '{print $1, $2, $4}' | grep Swap | awk '{print $3}')
echo -e "Free SWAP  :" $freeswap

printf "\n"
printf "UPTIME\n"

uptime=$(uptime | awk '{print $3, $4}')
echo -e "Uptime :" $uptime
