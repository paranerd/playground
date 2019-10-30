<?php

class JWT {
	/**
	* @brief Encode claims to JSON Web Token
	*
	* @param  mixed   $claims
	* @param  string  $key
	* @param  int     $expires (optional)
	*
	* @return string
	*/
	public static function encode($claims, $key, $expires = null) {
		$header = array(
			'typ' => 'JWT',
			'alg' => 'HS256'
		);

		if ($expires) {
			$header['exp'] = $expires;
		}

		$parts = array();

		// Add header
		$parts[] = self::urlsafe_b64encode(json_encode($header));

		// Add claims
		$parts[] = self::urlsafe_b64encode(json_encode($claims));

		// Add signature
		$parts[] = self::urlsafe_b64encode(self::sign(implode('.', $parts), $key));

		return implode('.', $parts);
	}

	/**
	* @brief Decode JSON Web Token
	*
	* @param  string  $jwt
	* @param  string  $key
	*
	* @throws Exception
	* @return mixed
	*/
	public static function decode($jwt, $key) {
		// Extract base64 encoded parts
		$parts = explode('.', $jwt);
		list($header64, $claims64, $signature64) = $parts;

		// Decode original values
		$header = json_decode(self::urlsafe_b64decode($header64));
		$claims = json_decode(self::urlsafe_b64decode($claims64));
		$signature = self::urlsafe_b64decode($signature64);

		// Check signature
		if (!self::verify($header64, $claims64, $signature, $key)) {
			throw new Exception('Invalid signature');
		}

		// Check if expired
		if (self::is_expired($header)) {
			throw new Exception('Expired');
		}

		return array(
			'header' => $header,
			'claims' => $claims
		);
	}

	/**
	* @brief Check if token is expired
	*
	* @param  array  $header
	*
	* @return string
	*/
	private static function is_expired($header) {
		return property_exists($header, 'exp') && $header->exp < time();
	}

	/**
	* @brief Verify JWT signature
	*
	* @param  string  $header64
	* @param  string  $claims64
	* @param  string  $signature
	* @param  string  $key
	*
	* @return boolean
	*/
	private static function verify($header64, $claims64, $signature, $key) {
		$hash = hash_hmac('sha256', $header64 . "." . $claims64, $key, true);

		return hash_equals($signature, $hash);
	}

	/**
	* @brief Sign JWT
	*
	* @param  string  $msg
	* @param  string  $key
	*
	* @return string
	*/
	private static function sign($msg, $key) {
		return hash_hmac('sha256', $msg, $key, true);
	}

	/**
	* @brief Apply URL-safe Base64-encoding
	*
	* @param  string  $str
	*
	* @return string
	*/
	private static function urlsafe_b64encode($str) {
		$data = base64_encode($str);

		return str_replace(array('+', '/', '='), array('-', '_', ''), $data);
	}

	/**
	* @brief Decode URL-safe Base64-encoding
	*
	* @param  string  $str
	*
	* @return string
	*/
	private static function urlsafe_b64decode($str) {
		$data = str_replace(array('-', '_'), array('+', '/'), $str);

		$mod4 = strlen($data) % 4;

		if ($mod4) {
			$data .= substr('====', $mod4);
		}

		return base64_decode($data);
	}
}
