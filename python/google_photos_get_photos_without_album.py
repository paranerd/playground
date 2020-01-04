import os
import re
import json
import requests
import webbrowser
import urllib3
from urllib.parse import urlencode, quote_plus

# Prevent SSL certificate errors
from urllib3.contrib import pyopenssl
pyopenssl.extract_from_urllib3()

class Google_Photos():
	API_URL = "https://photoslibrary.googleapis.com/v1"
	credentials = ''
	token = ''
	cache = {}

	def __init__(self):
		"""
		Constructor
		"""
		self.credentials = self.get_credentials()
		self.token = self.get_token()

	def get_credentials(self):
		"""
		Load credentials from file or request it from Google
		"""
		if os.path.isfile('credentials.json'):
			with open('credentials.json', 'r') as f:
				return json.load(f)
		else:
			self.show_instructions()

			credentials_str = input('Paste content of credentials file: ')
			credentials = json.loads(credentials_str)['installed']

			with open('credentials.json', 'w+') as f:
				f.write(json.dumps(credentials, indent=4))

			return credentials

	def get_token(self):
		"""
		Load token from file or request it from Google
		"""
		if os.path.isfile('token.json'):
			with open('token.json', 'r') as f:
				return json.load(f)
		else:
			code = self.request_code()
			token = self.request_token(code)

			with open('token.json', 'w+') as f:
				f.write(json.dumps(token, indent=4))

			return token

	def show_instructions(self):
		print()
		print('How to get credentials:')
		print('Go to https://console.developers.google.com/')
		print('Create a project')
		print('On the left select "Dashboard"')
		print('Select "Activate APIs and services"')
		print('Activate Photos Library API')
		print('On the left select "Credentials"')
		print('Create an OAuth-Client-ID for "Others"')
		print('Download the generated credentials json')
		print()

	def build_auth_uri(self):
		auth_uri = self.credentials['auth_uri']
		auth_uri += "?response_type=code"
		auth_uri += "&redirect_uri=" + quote_plus(self.credentials['redirect_uris'][0])
		auth_uri += "&client_id=" + quote_plus(self.credentials['client_id'])
		auth_uri += "&scope=https://www.googleapis.com/auth/photoslibrary"
		auth_uri += "&access_type=offline"
		auth_uri += "&approval_prompt=auto"

		return auth_uri

	def request_code(self):
		# Build auth uri
		auth_uri = self.build_auth_uri()

		# Try opening in browser
		webbrowser.open(auth_uri, new=2)

		print()
		print("If your browser does not open, go to this website:")
		print(auth_uri)
		print()

		# Return code
		return input('Enter code: ')

	def get_missing(self):
		# Get all photos
		print("Fetching all photos", end='', flush=True)
		self.cache = self.get_all_photos()
		print()

		# Get all albums
		print("Fetching albums", end='', flush=True)
		albums = self.get_albums()
		print()

		# Remove photos in albums
		print("Filtering photos in albums", end='', flush=True)
		for album in albums:
			self.remove_photos_in_albums(album['id'])
		print()

		# Save URLs of photos without an album
		file = open('missing.json', 'w+')

		for id, url in self.cache.items():
			file.write(url)
			file.write("\n")

		file.close()

	def get_albums(self, pageToken=""):
		# Progress indicator
		print(".", end='', flush=True)

		params = {
			"pageSize": "50",
		}

		if pageToken:
			params['pageToken'] = pageToken

		res = self.execute_request(self.API_URL + "/albums", {}, params)

		if 'albums' in res['body']:
			albums = res['body']['albums']

			if 'nextPageToken' in res['body']:
				albums.extend(self.get_albums(res['body']['nextPageToken']))

			return albums
		else:
			print("An error ocurred")
			print(res)

	def get_all_photos(self, pageToken=""):
		# Progress indicator
		print(".", end='', flush=True)

		params = {
			"pageSize": "100",
		}

		if pageToken:
			params['pageToken'] = pageToken

		res = self.execute_request(self.API_URL + "/mediaItems", {}, params)

		items = {}

		if 'mediaItems' in res['body']:
			for item in res['body']['mediaItems']:
				items[item['id']] = item['productUrl']

			if 'nextPageToken' in res['body']:
				items.update(self.get_all_photos(res['body']['nextPageToken']))

		return items

	def remove_photos_in_albums(self, id, pageToken=""):
		# Progress indicator
		print(".", end='', flush=True)

		params = {
			"pageSize": "50",
			"albumId": id
		}

		if pageToken:
			params['pageToken'] = pageToken

		res = self.execute_request(self.API_URL + "/mediaItems:search", {}, params, "POST")

		if 'mediaItems' in res['body']:
			items = res['body']['mediaItems']

			for item in items:
				if item['id'] in self.cache:
					del self.cache[item['id']]

		if 'nextPageToken' in res['body']:
			self.remove_photos_in_albums(id, res['body']['nextPageToken'])

	def request_token(self, code=""):
		if not self.credentials:
			raise Exception('Could not read credentials')

		if not code and not self.token:
			raise Exception('Could not read token')

		headers = {
			'Content-Type': 'application/x-www-form-urlencoded'
		}

		params = {
			'client_id' 	: self.credentials['client_id'],
			'client_secret'	: self.credentials['client_secret'],
			'redirect_uri'	: self.credentials['redirect_uris'][0],
		}

		if code:
			params['grant_type'] = 'authorization_code'
			params['code'] = code
		else:
			params['grant_type'] = 'refresh_token'
			params['refresh_token'] = self.token['refresh_token']

		res = self.execute_request(self.credentials['token_uri'], headers, params, "POST")

		if res['status'] == 200:
			if self.token:
				res['body']['refresh_token'] = self.token['refresh_token']

			self.token = res['body']
			return res['body']
		else:
			raise Exception("Error getting token: " + str(res['body']))

	def execute_request(self, url, headers={}, params={}, method="GET", retry=False):
		if "access_token" in self.token:
			# Set Authorization-Header
			auth_header = {
				'Authorization': 'Bearer {}'.format(self.token['access_token'])
			}
			headers.update(auth_header)

		# Execute request
		if method == 'GET':
			res = requests.get(url, headers=headers, params=params)
		elif method == 'POST':
			res = requests.post(url, headers=headers, data=params)
		elif method == 'HEAD':
			res = requests.head(url, headers=headers)

		if res.status_code == 401:
			# Token expired
			if not retry:
				self.token = self.request_token()
				return self.execute_request(url, headers, params, method, True)
			else:
				raise Exception("Failed to refresh token")

		body = res.json() if method != 'HEAD' else None

		return {'status': res.status_code, 'headers': res.headers, 'body': body}

if __name__ == "__main__":
	gp = Google_Photos()
	gp.get_missing()

