#!/bin/bash
# Define port mappings to check
declare -A ports=(
  [4723]="appium"
  [9002]="smartphoneremotecontrol"
  [5037]="adb"
  [9000]="cleanup"
  [9006]="screenrecorder"
)
udid=$(adb devices | awk 'NF==2 {print $1}')
hostname=$(hostname)


# Loop over each port mapping and check if it's listening
for port in "${!ports[@]}"; do
  if ! lsof -iTCP:"$port" -sTCP:LISTEN -n >/dev/null; then
    # If port is not listening, mark health check as failed and send Discord notification
    curl --location 'Enter WebHok URL' \
      --header 'Content-Type: application/json' \
      --header 'Cookie:"enter cookie information"' \
      --data "{
        \"content\": \"Container port health control failed.\",
        \"embeds\": [
          {
            \"title\": \"Health Check Failure\",
            \"description\": \"The health check failed because ${ports[$port]} service is not running on port $port.\",
            \"color\": 5814783
          },{
            \"title\": \"Info\",
            \"description\": \"Device UDID: $udid \nContainer Id: $hostname \nPort: $port\",
            \"color\": 5814783
          }
        ],
        \"attachments\": []
      }"
    exit 1
  fi
done
# If all ports are listening, mark health check as successful
exit 0

