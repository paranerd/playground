#!/bin/bash

# Get the API key from the Cloudflare dashboard
# Get the ZONE_ID using a GET request to <API_URL>/zones
# Get the DNS_RECORD_ID using a GET request to <API_URL>/zones/<ZONE_ID>/dns_records
# Set up a cronjob calling this script every 10 minutes or so

API_URL="https://api.cloudflare.com/client/v4"
API_KEY="<your_api_key>"
EMAIL="<your_cloudflare_login_email>"
ZONE_ID="<your_zone_id>"
DNS_RECORD_ID="<your_dns_record_id>"
DNS_RECORD_NAME="<your_dns_record_name>" # e.g. foo.example.com

# Set path to IP-storage
SCRIPT=`readlink -f $0`
IP_PATH=$(dirname ${SCRIPT})"/ip.txt"

get_public_ip() {
	# Fetch public IP
	IP_URL="https://ipv4.icanhazip.com"

	# Store the whole response with the status at the and
	IP_RESPONSE=$(curl --silent --write-out "HTTPSTATUS:%{http_code}" $IP_URL)

	# Extract the body
	IP_BODY=$(echo $IP_RESPONSE | sed -e 's/HTTPSTATUS\:.*//g')

	# Extract the status
	IP_STATUS=$(echo $IP_RESPONSE | tr -d '\n' | sed -e 's/.*HTTPSTATUS://')

	# Check if successful
	if [ ! $IP_STATUS -eq 200 ]; then
		echo "Error obtaining public IP [HTTP status: $IP_STATUS]" >> log.txt
		exit 1
	fi

	# Trim whitespace
	IP="$(echo -e "${IP_BODY}" | tr -d '[:space:]')"

	echo $IP
}

update_dns_record() {
	# Update DNS
	DNS_RESPONSE=$(curl -X PUT --write-out "HTTPSTATUS:%{http_code}" "${API_URL}/zones/${ZONE_ID}/dns_records/${DNS_RECORD_ID}" \
	-H "X-Auth-Email: ${EMAIL}" \
	-H "X-Auth-Key: ${API_KEY}" \
	-H "Content-Type: application/json" \
	--data '{"type":"A","name":"'${DNS_RECORD_NAME}'","content":"'${1}'"}')

	# Extract the body
	DNS_BODY=$(echo $DNS_RESPONSE | sed -e 's/HTTPSTATUS\:.*//g')

	# Extract the status
	DNS_STATUS=$(echo $DNS_RESPONSE | tr -d '\n' | sed -e 's/.*HTTPSTATUS://')

	# Check if successful
	if [ ! $DNS_STATUS -eq 200 ]; then
		echo "Error [HTTP status: $DNS_STATUS]" >> log.txt
		exit 1
	fi
}

get_records() {
	DNS_RESPONSE=$(curl -X GET --write-out "HTTPSTATUS:%{http_code}" "${API_URL}/zones/${ZONE_ID}/dns_records" \
	-H "X-Auth-Email: ${EMAIL}" \
	-H "X-Auth-Key: ${API_KEY}" \
	-H "Content-Type: application/json")

	echo $DNS_RESPONSE
}

NEW_IP=$(get_public_ip)
PREV_IP=$(cat ${IP_PATH})

if [ "$NEW_IP" = "$PREV_IP" ]; then
	exit 0
fi

update_dns_record ${NEW_IP}

# Save IP to file
echo ${NEW_IP} > ${IP_PATH}
