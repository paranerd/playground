<?php

class TOTP {
	/**
	 * @brief Generate TOTP token
	 *
	 * @param  string  $secret Base32 string
	 * @param  int     $length (optional)
	 * @param  int     $counter (optional)
	 *
	 * @return string
	 */
	public static function generate($secret, $length = 6, $counter = null) {
		// Decode base32 encoded secret
		$key = self::base32_decode($secret);

		// Set or calculate time slice
		$counter = ($counter) ? $counter : floor(time() / 30);

		// Pack counter into binary string
		$counter = chr(0).chr(0).chr(0).chr(0).pack('N*', $counter);

		// Generate HMAC using
		$hmac = hash_hmac('sha1', $counter, $key, true);

		// Use last nipple of result as index/offset
		$offset = ord(substr($hmac, -1)) & 0x0F;

		// Grab 4 bytes of the result
		$hashpart = substr($hmac, $offset, 4);

		// Unpack binary value
		$value = unpack('N', $hashpart)[1];

		// Only 32 bits
		$value = $value & 0x7FFFFFFF;

		$modulo = pow(10, $length);

		return str_pad($value % $modulo, $length, '0', STR_PAD_LEFT);
	}

	/**
	 * @brief Verify TOTP token
	 *
	 * @param  int     $code
	 * @param  string  $secret
	 * @param  int     $discrepancy (optional)
	 *
	 * @return boolean
	 */
	public static function verify($code, $secret, $discrepancy = 1) {
		// Calculate current time slice
		$counter = floor(time() / 30);

		for ($i = -$discrepancy; $i <= $discrepancy; ++$i) {
			$calculated = self::generate($secret, strlen((string)$code), $counter + $i);
			if (hash_equals($calculated, $code)) {
				return true;
			}
		}

		return false;
	}

	/**
	 * @brief Create Base32 encoded string
	 *
	 * @param  int  $length
	 *
	 * @return string
	 */
	public function create_secret($length = 16) {
		$alphabet = self::get_base32_alphabet();
		$secret = '';
		$rnd = false;

		// Valid secret lengths are 80 to 640 bits
		if ($length < 16 || $length > 128) {
			throw new Exception('Bad secret length');
		}

		if (function_exists('random_bytes')) {
			$rnd = random_bytes($length);
		}
		else if (function_exists('mcrypt_create_iv')) {
			$rnd = mcrypt_create_iv($length, MCRYPT_DEV_URANDOM);
		}
		else if (function_exists('openssl_random_pseudo_bytes')) {
			$rnd = openssl_random_pseudo_bytes($length, $crypto_strong);
			if (!$crypto_strong) {
				$rnd = false;
			}
		}

		if ($rnd !== false) {
			for ($i = 0; $i < $length; ++$i) {
				$secret .= $alphabet[ord($rnd[$i]) & 31];
			}
		}
		else {
			throw new Exception('No source of secure random');
		}

		return $secret;
	}

	/**
	 * @brief Generate URL to display QR-Code
	 *
	 * @param  string  $name
	 * @param  string  $secret
	 * @param  string  $issuer
	 * @param  array   $param
	 *
	 * @return string
	 */
	public static function generate_qr_url($name, $secret, $issuer = null, $params = array()) {
		$width = !empty($params['width']) && (int) $params['width'] > 0 ? (int) $params['width'] : 200;
		$height = !empty($params['height']) && (int) $params['height'] > 0 ? (int) $params['height'] : 200;
		$level = !empty($params['level']) && array_search($params['level'], array('L', 'M', 'Q', 'H')) !== false ? $params['level'] : 'M';

		$url = 'otpauth://totp/' . $name . '?secret=' . $secret . '';

		if (isset($issuer)) {
			$url .= '&issuer=' . $issuer;
		}

		return "https://api.qrserver.com/v1/create-qr-code/?data=" . $url . "&size=" . $width . "x" . $height . "&ecc=" . $level;
	}

	/**
	 * @brief Generate array of all valid Base32 characters
	 *
	 * @return array
	 */
	private static function get_base32_alphabet() {
		return array_merge(range('A', 'Z'), range('2', '7'), ['=']);
	}

	/**
	 * @brief Decode Base32 string
	 *
	 * @param  string  $b32encoded
	 *
	 * @return string
	 */
	public static function base32_decode($b32encoded) {
		// Clean input
		$b32encoded = rtrim($b32encoded, "=\x20\t\n\r\0\x0B");

		// Create character map
		$alphabet = array_flip(self::get_base32_alphabet());

		$size = strlen($b32encoded);
		$buf = 0;
		$bufSize = 0;
		$res = '';

		for ($i = 0; $i < $size; $i++) {
			$c = $b32encoded[$i];

			// Check for invalid characters
			if (!isset($alphabet[$c]) && !in_array($c, [" ", "\r", "\n", "\t"])) {
				throw new Exception('Encoded string contains unexpected char #' . ord($c) . " at offset $i (using improper alphabet?)");
			}

			$b = $alphabet[$c];
			$buf = ($buf << 5) | $b;
			$bufSize += 5;

			if ($bufSize > 7) {
				$bufSize -= 8;
				$b = ($buf & (0xff << $bufSize)) >> $bufSize;
				$res .= chr($b);
			}
		}

		return $res;
	}
}
