#!/bin/bash

# Set the paths to the scripts
file1_path="/home/user/ubuntu/port-scan.sh"
file2_path="/home/user/ubuntu/suspicious_ip.sh"

# Makes the scripts executable
chmod +x "$file1_path"
chmod +x "$file2_path"

# Define the cron job commands
cron_command1="$file1_path"
cron_command2="$file2_path"

# Define the cron schedules
cron_schedule1="5 * * * *"
cron_schedule2="15 * * * *"

# Write the cron job commands and schedules to the crontab file
(crontab -l 2>/dev/null; echo "$cron_schedule1 $cron_command1") | crontab -
(crontab -l 2>/dev/null; echo "$cron_schedule2 $cron_command2") | crontab -