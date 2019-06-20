import urllib3
import re

class Crawler:
	urls_todo = []
	urls_done = []

	def crawl(self, start):
		"""
		Main worker

		@param string start
		"""
		# Add Start-URL to to-do-list
		self.urls_todo.append(start)

		# Loop as long as there's something to do
		while len(self.urls_todo):
			# Get current URL
			url = self.urls_todo.pop(0)

			# Fetch page
			content = self.download(start)

			# Extract URLs
			urls = self.extract_links(content)

			# Add URLs to to-do-List
			self.add_urls(urls)

			# Mark this URL as done
			self.urls_done.append(url)

			# Print URL
			print(url)

	def add_urls(self, urls):
		"""
		Add URLs to to-do-List if they're not already in there or have been crawled

		@param list urls
		"""
		for url in urls:
			if url not in self.urls_todo and url not in self.urls_done:
				self.urls_todo.append(u)

	def extract_links(self, markup):
		"""
		Extract all links from HTML markup

		@param string markup
		@return list
		"""
		return re.findall('<a.*href\=[\"\'](http.*?)[\"\']', markup, re.MULTILINE)

	def download(self, url):
		"""
		Fetch page content

		@param string url
		@return string
		"""
		urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)
		http = urllib3.PoolManager()
		r = http.request('GET', url)

		return r.data.decode('utf-8')

if __name__ == "__main__":
	c = Crawler()
	c.crawl("https://thegermancoder.com")
