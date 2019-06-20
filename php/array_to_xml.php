<?php

$users = array(
	"total_users" => 3,
	"users" => array(
		array(
			"id" => 1,
			"name" => "Smith",
			"address" => array(
				"country" => "United Kingdom",
				"city" => "London",
				"zip" => 56789,
				"additional" => array(
					"in_additional" => array(
					)
				)
			)
		),
		array(
			"id" => 2,
			"name" => "John",
			"address" => array(
				"country" => "USA",
				"city" => "Newyork",
				"zip" => "",
				"anotha" => 34
			)
		),
		array(
			"id" => 3,
			"name" => "Viktor",
			"address" => array(
				"country" => "Australia",
				"city" => "Sydney",
				"zip" => 123456,
				"zop" => "zippedy"
			)
		),
	)
);

// Function definition to convert array to xml
function array_to_xml($array, $xml, $keep_empty = true, $root = "") {
	$xml = ($root) ? new SimpleXMLElement('<?xml version="1.0"?><' . $root . '></' . $root . '>') : $xml;

	foreach ($array as $key => $value) {
		if ($value) {
			if (is_array($value)) {
				if (!is_numeric($key)) {
					$subnode = $xml->addChild("$key");
					array_to_xml($value, $subnode, $keep_empty);
				}
				else {
					$subnode = $xml->addChild("item$key");
					array_to_xml($value, $subnode, $keep_empty);
				}
			}
			else {
				$xml->addChild("$key", htmlspecialchars("$value"));
			}
		}
		else if ($keep_empty) {
			$child = $xml->addChild("$key");
			$child[0] = '';
		}
	}

	return ($root && $xml->asXML()) ? $xml : null;
}

function save_xml($xml, $path) {
	$dom = dom_import_simplexml($xml)->ownerDocument;
	$dom->formatOutput = true;
	file_put_contents($path, $dom->saveXML());
}

if ($xml = array_to_xml($users, null, true, "user_info")) {
	save_xml($xml, dirname(__FILE__) . '/result.xml');
}
else {
	echo 'XML file generation error\n';
}