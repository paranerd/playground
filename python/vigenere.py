class Vigenere:
	# Alphabet consisting of space, uppercase and lowercase characters
	alphabet = [" "] + list(map(chr, range(65, 91))) + list(map(chr, range(97, 123)))

	def encrypt(self, cleartext, key):
		"""
		Encrypt using vigenere algorithm

		@param string cleartext
		@param string key
		@return string
		"""
		cipher = ""

		for i in range(len(cleartext)):
			key_idx = self.char_to_index(key[i % len(key)])
			clear_idx = self.char_to_index(cleartext[i])
			cipher += self.alphabet[(clear_idx + key_idx) % len(self.alphabet)]

		return cipher

	def decrypt(self, cipher, key):
		"""
		Encrypt using vigenere algorithm

		@param string cleartext
		@param string key
		@return string
		"""
		clear = ""

		for i in range(len(cipher)):
			key_idx = self.char_to_index(key[i % len(key)])
			cipher_idx = self.char_to_index(cipher[i])
			clear += self.alphabet[(cipher_idx + len(self.alphabet) - key_idx) % len(self.alphabet)]

		return clear

	def char_to_index(self, char):
		"""
		Translate character to alphabet-index

		@param string char
		@return int
		"""
		for idx, val in enumerate(self.alphabet):
			if self.alphabet[idx] is char:
				return idx

if __name__ == "__main__":
	v = Vigenere()
	print(v.encrypt("KRYPTOWISSEN", "BLA"))
	print(v.decrypt("LCYQEOXTSTPN", "BLA"))
