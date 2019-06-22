<?php
/**
 * Get a website's favicon
 */
class FaviCrawler {
	private $url;
	private $hostname;
	private $storage = __DIR__ . "/favicons";

	/**
	 * Constructor. Create storage folder if not exists
	 */
	public function __construct() {
		@mkdir($this->storage, 0777, true);
	}

	/**
	 * Start crawling the favicon
	 *
	 * @param string $url
	 */
	 public function crawl($url) {
		$this->url = $this->format_url($url);
		$this->hostname = $this->extract_host($this->url);

		// Get page
		$page = file_get_contents($this->url, false);

		// Get favicon path
		$path = $this->extract_favicon_link($page);

		if ($path) {
			$this->download($path);
		}
		else {
			echo "Could not find favicon\n";
		}
	}

	/**
	 * Format URL. Add 'https://' if no protocol present
	 *
	 * @param string $url
	 * @return string
	 */
	private function format_url($url) {
		return (strpos($url, 'http') !== 0) ? 'https://' . $url : $url;
	}

	/**
	 * Extract favicon link from page markup
	 *
	 * @param string $page HTML-markup
	 * @return string
	 */
	 private function extract_favicon_link($page) {
		$path = "";

		if (preg_match('/<link.*icon.*href="([^"]+)/', $page, $match)) {
			$path = $match[1];
		}

		if ($path && strpos($path, 'http') !== 0) {
			$path = $this->url . "/" . ltrim($path, '/');
		}

		return $path;
	}

	/**
	 * Download favicon
	 *
	 * @param string $path Link to favicon
	 */
	 private function download($path) {
		echo "Downloading " . $path . "\n";
		$favicon = file_get_contents($path);
		$file = fopen($this->storage . "/" . $this->hostname, "w+");
		fputs($file, $favicon);
		fclose($file);
	}

	/**
	 * Extract hostname from url
	 *
	 * @param string $url
	 * @return string
	 */
	 private function extract_host($url) {
		preg_match('/https?:\/\/(?:\w+\.)*(\w+)(?:\.\w{2,3})/', $url, $match);

		return $match[1];
	}
}

if (sizeof($argv) > 1) {
	$crawler = new FaviCrawler();
	$crawler->crawl($argv[1]);
}
