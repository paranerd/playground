<?php
	$query		= $_GET['q'];
	$results	= ($_GET['q']) ? Ebay::search($_GET['q']) : null;
?>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="de" lang="de">
<body>
	<form id="search" action="#">
		<input id="ebay-search" type="text" name="q" />
		<input type="submit" />
	</form>

	<ul>
		<?php if (sizeof($results['searchResult']['item']) > 0) {
			foreach ($results['searchResult']['item'] as $item) { ?>
				<li><a href="<?php echo $item['viewItemURL'] ?>"><?php echo $item['title']; ?></a></li>
		<?php }} ?>
	</ul>
</body>
</html>

<?php

class Ebay {
	private static $finding_url	= 'http://svcs.ebay.com/services/search/FindingService/v1';
	private static $appID_prod = 'your-api-key';

	public static function search($keyword = '', $item_sort = 'BestMatch', $list_type = 'FixedPrice', $item_type = 'FixedPricedItem', $min_price = '0', $max_price = '9999999', $limit = 20) {
		$xml = new XMLWriter();
		$xml->openMemory();
		$xml->setIndent(true);

		$xml->startDocument('1.0', 'utf-8');
		$xml->startElement('findItemsAdvancedRequest');
			$xml->writeAttribute('xmlns', 'http://www.ebay.com/marketplace/search/v1/services');
			$xml->writeElement('keywords', urlencode($keyword));

			$xml->startElement('itemFilter');
				$xml->writeElement('name', 'ListingType');
				$xml->writeElement('value', $list_type);
			$xml->endElement();

			$xml->startElement('itemFilter');
				$xml->writeElement('name', 'MinPrice');
				$xml->writeElement('value', $min_price);
			$xml->endElement();

			$xml->startElement('itemFilter');
				$xml->writeElement('name', 'MaxPrice');
				$xml->writeElement('value', $max_price);
			$xml->endElement();

			$xml->writeElement('sortOrder', $item_sort);

			$xml->startElement('paginationInput');
				$xml->writeElement('entriesPerPage', $limit);
				$xml->writeElement('pageNumber', $limit);
			$xml->endElement();

			$xml->writeElement('descriptionSearch', 'false');

		$xml->endElement();

		$response = self::query(self::$finding_url, self::finding_headers('findItemsAdvanced'), $xml->outputMemory());

		if ($response && $response->ack && $response->ack == 'Success') {
			$json = json_encode($response); //, JSON_PRETTY_PRINT | JSON_FORCE_OBJECT);

			return json_decode($json, true);
		}

		header('HTTP/1.1 500 Error searching');
		return null;
	}

	private static function query($url, $headers, $xml) {
		$cpt = curl_init();

		curl_setopt($cpt, CURLOPT_HTTPHEADER, $headers);
		curl_setopt($cpt, CURLOPT_URL, $url);

		curl_setopt($cpt, CURLOPT_RETURNTRANSFER, 1);
		curl_setopt($cpt, CURLOPT_SSL_VERIFYHOST, 0);
		curl_setopt($cpt, CURLOPT_SSL_VERIFYPEER, 0);

		curl_setopt($cpt, CURLOPT_POSTFIELDS,  $xml);
		$result = curl_exec($cpt);
		curl_close($cpt);

		return simplexml_load_string($result);
	}

	private static function finding_headers($call) {
		return array (
			'X-EBAY-SOA-SERVICE-NAME: FindingService',
			'X-EBAY-SOA-OPERATION-NAME: findItemsAdvanced',
			'X-EBAY-SOA-SERVICE-VERSION: 1.13.0',
			'X-EBAY-SOA-GLOBAL-ID: EBAY-DE',
			'X-EBAY-SOA-SECURITY-APPNAME:' . self::$appID_prod,
			'X-EBAY-SOA-REQUEST-DATA-FORMAT: XML',
			'X-EBAY-SOA-RESPONSE-DATA-FORMAT: XML'
		);
	}
}
