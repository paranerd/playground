import os
import sys
import urllib3
import json

api_url = "https://api.cloudflare.com/client/v4"
api_key = "<your_api_key>"
email = "<your_email>"

headers = {
	'X-Auth-Email': email,
	'X-Auth-Key': api_key,
	'Content-Type': 'application/json'
}

def http_request(url, method="GET", headers={}, body={}):
	urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)
	http = urllib3.PoolManager()
	r = http.request(method, url, headers=headers, body=body)

	return r.data.decode('utf-8')

def get_current_ip():
	res = http_request("https://ipv4.icanhazip.com")

	return res.replace('\n', '')

def get_previous_ip():
	if os.path.isfile('ip.txt'):
		with open('ip.txt', 'r') as file:
			return file.read().replace('\n', '')

def save_ip(ip):
	with open('ip.txt', 'w+') as file:
		file.write(ip)

def get_zone_id(domain):
	res = http_request(api_url + "/zones", 'GET', headers)
	res = json.loads(res)

	for zone in res['result']:
		if domain.endswith(zone['name']):
			return zone['id']

def get_dns_record_id(zone_id, domain):
	res = http_request(api_url + "/zones/" + zone_id + "/dns_records", 'GET', headers)
	res = json.loads(res)

	for dns_record in res['result']:
		if domain == dns_record['name']:
			return dns_record['id']

	print("No DNS record found")

def create_dns_record(zone_id, domain, ip):
	data = json.dumps({
		'type': 'A',
		'name': domain,
		'content': ip,
	})

	res = http_request(api_url + "/zones/" + zone_id + "/dns_records", 'POST', headers, data)
	res = json.loads(res)

	return res['result']['id']

def update_dns_record(zone_id, domain, ip):
	data = json.dumps({
		'type': 'A',
		'name': domain,
		'content': ip,
	})

	res = http_request(api_url + "/zones/" + zone_id + "/dns_records/" + dns_record_id, 'PUT', headers, data)
	res = json.loads(res)

def show_help():
	print("Usage:")
	print("python3 cloudflare_dyndns.py domain1 [domain2] [domain3]...")

if __name__ == "__main__":
	# Quit if no domain has been provided
	if sys.argv.length < 2:
		show_help()
		sys.exit()

	# Get public IP
	ip_curr = get_current_ip()
	ip_prev = get_previous_ip()

	# Quit if IP hasn't changed
	if ip_curr == ip_prev:
		print("No action.")
		sys.exit()

	# Loop over domains in arguments list
	for domain in sys.argv[1:]:
		# Get zone ID
		zone_id = get_zone_id(domain)

		# Get dns record ID (create if not exists)
		dns_record_id = get_dns_record_id(zone_id, domain)

		# Update dns record if exists or create new entry
		if dns_record_id:
			update_dns_record(zone_id, domain, ip_curr)
		else:
			create_dns_record(zone_id, domain, ip_curr)

	# Save current IP for next time
	save_ip(ip_curr)
