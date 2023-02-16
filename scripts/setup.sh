#!/bin/bash

# Set the paths to the scripts
file1_path="/home/user/ubuntu/prepare.sh"
file2_path="/home/user/ubuntu/port-scan.sh"
file3_path="/home/user/ubuntu/suspicious_ip.sh"
file4_path="/home/user/ubuntu/log4j.sh"

# Makes the scripts executable
chmod +x "$file1_path"
chmod +x "$file2_path"
chmod +x "$file3_path"
chmod +x "$file4_path"

#Installs the required libraries and dependencies
"$file1_path"

# Define the cron job commands
cron_command1="$file2_path"
cron_command2="$file3_path"

# Define the cron schedules
cron_schedule1="5 * * * *"
cron_schedule2="15 * * * *"

# Write the cron job commands and schedules to the crontab file
(crontab -l 2>/dev/null; echo "$cron_schedule1 $cron_command1") | crontab -
(crontab -l 2>/dev/null; echo "$cron_schedule2 $cron_command2") | crontab -

# Starts the Log4j app
"$file4_path"