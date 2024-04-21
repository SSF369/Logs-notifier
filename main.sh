#date

#name = $serviceName
#while IFS= read -r line;do
#echo "For Service : $line"
#tail -n 1
#logFile = $(ls-lrth | awk{'print$9'} | tail -n 1)
#cat /home/logs/$line/$logFile | grep ERROR | grep -v description
#done <Services.txt

#!/bin/bash

# Read each service name from the file and process
#while IFS= read -r service; do
#    echo "For Service : $service"

    # Get the latest log file in the directory
#    logFile=$(ls -ltrh /home/logs/"$service"/*.log | awk '{print $9}' | tail -n 1) #You need to replace here your logs directory

    # Check if any log files exist in the directory
#    if [ -z "$logFile" ]; then
#        echo "No log files found for $service"
#    else
        # Print the name of the latest log file
#        echo "Latest log file : $logFile"
#        echo "=================================================================="
#
#        # Print the lines containing 'ERROR' from the latest log file
#        #grep ERROR "$logFile" | grep -v description
#	awk -v date="$(date -d '10 minutes ago' +'%YY-%m-%d %H:%M:%S')" '$1" "$2 >=date' "$logFile" | grep ERROR | grep -v description
#    fi
#done < Services.txt


#!/bin/bash

# Function to send notification to Microsoft Teams webhook
send_notification() {
    local webhook_url="$1"
    local message="$2"
    
    curl -X POST -H 'Content-Type: application/json' -d "{'text': '$message' }" "$webhook_url"
}

# Main script logic to read each service name from the file and process
while IFS= read -r service; do
    echo "For Service : $service"

    # Get the latest log file in the directory
    logFile=$(ls -ltrh "/home/logs/$service"/*.log | awk '{print $9}' | tail -n 1) #You need to replace here your logs directory

    # Check if any log files exist in the directory
    if [ -z "$logFile" ]; then
        echo "No log files found for $service"
    else
        # Print the name of the latest log file
        echo "Latest log file : $logFile"
        echo "=================================================================="
	error=$(awk -v date="$(date -d '10 minutes ago' +'%X-%m-%d %H:%M:%S')" '$1" "$2 >=date' "$logFile" | grep ERROR | grep -v description)

        # Count the number of lines containing 'ERROR' from the latest log file
        error_count=$(awk -v date="$(date -d '10 minutes ago' +'%Y-%m-%d %H:%M:%S')" '$1" "$2 >=date' "$logFile" | grep ERROR | grep -v description | wc -l)

        # If error count is greater than 10, send notification
        if [ "$error_count" -gt 10 ]; then
            webhook_url="YOUR_WEBHOOK_URL" #You'll find this in the Teams channel that you have created.
            message="For $service we have the following errors detected from latest log file. Please investigate $error"
            send_notification "$webhook_url" "$message"
        fi
    fi
done < Services.txt
