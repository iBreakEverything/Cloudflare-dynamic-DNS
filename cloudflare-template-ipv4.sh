#SHELL

IP_SERVICES=(
  "https://api.ipify.org"
  "https://ipv4.icanhazip.com"
  "https://ipinfo.io/ip"
)

CHANGE="🔄"
DELETE="🗑️ "
DEBUG="🛠️"
INFO="ℹ️ "
WARN="⚠️ "
ERR="❌"
OK="✔️ "

###########################################
## Load config file
###########################################
CONFIG_FILE_PATH=$(dirname "$(realpath $0)")
CONFIG_FILE="./cloudflare-ddns.conf"

if [[ ! -f "$CONFIG_FILE" ]]; then
  logger "[DDNS Updater]$ERR Missing config file: $CONFIG_FILE"
  exit 1
fi

source "$CONFIG_FILE"

###########################################
## Check if we have a public IP
###########################################
REGEX_IPV4="([0-9]{1,3}\.){3}[0-9]{1,3}"

# Try all the ip services for a valid IPv4 address
for service in "${IP_SERVICES[@]}"; do
  RAW_IP=$(curl -s $service)
  if [[ "$RAW_IP" =~ $REGEX_IPV4 ]]; then
    CURRENT_IP="${BASH_REMATCH[0]}"
    logger "[DDNS Updater]$INFO Fetched IP: $CURRENT_IP"
    break
  else
    logger "[DDNS Updater]$WARN IP service $service failed."
  fi
done

# Exit if IP fetching failed
if [[ -z "$CURRENT_IP" ]]; then
  logger "[DDNS Updater]$ERR Failed to find a valid IP."
  exit 1
fi

# Store last public IP address
IP_FILE="/var/tmp/last_public_ipv4"

# Compare with stored IP
if [[ -f "$IP_FILE" ]]; then
  LAST_IP=$(cat "$IP_FILE")
  if [[ "$CURRENT_IP" == "$LAST_IP" ]]; then
    logger "[DDNS Updater]$INFO IP unchanged: $CURRENT_IP"
    exit 0
  fi
fi

# Store new IP.
echo "$CURRENT_IP" > "$IP_FILE"
logger "[DDNS Updater]$CHANGE IP changed to: $CURRENT_IP"

###########################################
## Check and set the proper auth header
###########################################
if [[ "${AUTH_METHOD}" == "global" ]]; then
  AUTH_HEADER="X-Auth-Key:"
  echo "[DDNS Updater]$DEBUG X-Auth header" #DEBUG
else
  AUTH_HEADER="Authorization: Bearer"
  echo "[DDNS Updater]$DEBUG Bearer header" #DEBUG
fi

###########################################
## Test token
###########################################
if $TEST_TOKEN; then
  token_valid=$(curl -s "https://api.cloudflare.com/client/v4/user/tokens/verify" \
    -H "$AUTH_HEADER $CLOUDFLARE_API_KEY" \
    -H "Content-Type:application/json")
  if [[ "true" == $(echo $token_valid | jq -r ".success") ]]; then
    logger "[DDNS Updater]$INFO $(echo $token_valid | jq -r '.messages[0].message')"
  else
    logger "[DDNS Updater]$ERR $(echo $token_valid | jq -r '.errors[0].message')"
    exit 1
  fi
fi

###########################################
## Seek for the A records
###########################################
records=$(curl -s "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records?type=A&name=$RECORD_NAME" \
  -H "X-Auth-Email: $CLOUDFLARE_EMAIL" \
  -H "$AUTH_HEADER $CLOUDFLARE_API_KEY" \
  -H "Content-Type: application/json")
# Number of A records for RECORD_NAME
record_count=$(echo $records | jq -r ".result_info.count")

###########################################
## Check if the domain has A records
###########################################
if [[ $record_count -eq 0 ]]; then
  logger "[DDNS Updater]$INFO No records found."
  record_ip=null
  update_record_id=null
fi

if [[ $record_count -eq 1 ]]; then
  logger "[DDNS Updater]$INFO One record found."
  record_ip=$(echo $records | jq -r ".result[0].content")
  update_record_id=$(echo $records | jq -r ".result[0].id")
fi

if [[ $record_count -gt 1 ]]; then
  logger "[DDNS Updater]$WARN Multiple ($record_count) records found."
  if $PURGE_ADDITIONAL_RECORDS; then
    # Remove additional records
    for ((i = 1 ; i < record_count ; i++ )); do
      dns_record_id=$(echo $records | jq -r ".result[$i].id")
      logger "[DDNS Updater]$DELETE Deleting record with ID: $dns_record_id"
      delete_status=$(curl -s https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records/$dns_record_id \
        -X DELETE \
        -H "X-Auth-Email: $CLOUDFLARE_EMAIL" \
        -H "$AUTH_HEADER $CLOUDFLARE_API_KEY" \
        -H "Content-Type: application/json")
    done
  else
    logger "[DDNS Updater]$WARN PURGE_ADDITIONAL_RECORDS set to $PURGE_ADDITIONAL_RECORDS. Updating first record only."
  fi
  record_ip=$(echo $records | jq -r ".result[0].content")
  update_record_id=$(echo $records | jq -r ".result[0].id")
fi

###########################################
## Verify records
###########################################
if [[ $record_ip == $CURRENT_IP ]]; then
  logger "[DDNS Updater]$INFO IP ($CURRENT_IP) for ${RECORD_NAME} has not changed."
  exit 0
fi

###########################################
## Update A record
###########################################
if [[ $update_record_id != null ]]; then
  cloudflare_response=$(curl -s https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records/$update_record_id \
    -X PATCH \
    -H 'Content-Type: application/json' \
    -H "X-Auth-Email: $CLOUDFLARE_EMAIL" \
    -H "$AUTH_HEADER $CLOUDFLARE_API_KEY" \
    -d '{
      "comment": "DDNS Updater",
      "content": "'$CURRENT_IP'",
      "name": "'$RECORD_NAME'",
      "proxied": '$PROXIED',
      "ttl": '$TTL',
      "type": "A"
    }')
else
  cloudflare_response=$(curl -s https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records \
    -H 'Content-Type: application/json' \
    -H "X-Auth-Email: $CLOUDFLARE_EMAIL" \
    -H "$AUTH_HEADER $CLOUDFLARE_API_KEY" \
    -d '{
      "comment": "DDNS Updater",
      "content": "'$CURRENT_IP'",
      "name": "'$RECORD_NAME'",
      "proxied": '$PROXIED',
      "ttl": '$TTL',
      "type": "A"
    }')
fi

###########################################
## Status report
###########################################
if [[ "true" == $(echo $cloudflare_response | jq -r ".success") ]]; then
  update_status="[DDNS Updater]$OK IP $CURRENT_IP set for $RECORD_NAME."
  exit_val=0
else
  error_message=$(echo $cloudflare_response | jq -r '.errors[0].message')
  update_status="[DDNS Updater]$ERR Failed to update: $error_message"
  exit_val=1
fi

# Log status
logger $update_status

# Log status in slack
if [[ $SLACK_URI != "" ]]; then
  json_payload=$(jq -n \
  --arg channel "$SLACK_CHANNEL" \
  --arg text "$update_status" \
  '{content: $content}')
  _=$(curl -s -L -X POST $SLACK_URI -d "$json_payload")
fi

# Log status in discord
if [[ $DISCORD_URI != "" ]]; then
  json_payload=$(jq -n \
  --arg content "$update_status" \
  '{content: $content}')
  _=$(curl -s -i -X POST $DISCORD_URI \
    -H "Accept: application/json" \
    -H "Content-Type:application/json" \
    -d "$json_payload")
fi

exit $exit_val
