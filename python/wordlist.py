import os
import sys
import string
import getopt
import datetime

class Wordlist:
	"""
	Wordlist creator
	"""
	path = ""
	alphabet = []

	def __init__(self, path):
		"""
		Set destination path
		"""
		self.path = path if path else 'wordlist_{}.txt'.format(datetime.datetime.now().strftime('%Y%m%d_%H%M%S'))

	def create(self, clean=False, size=3, dyn=False, upper=False, lower=False, numbers=False):
		"""
		Main worker to create the wordlist

		@param boolean clean
		@param int     size
		@param boolean dyn
		@param boolean upper
		@param boolean lower
		@param boolean numbers
		"""
		if clean:
			self.clean()

		# Set alphabet
		self.alphabet = self.set_alphabet(upper, lower, numbers)

		# Set start size depending on dyn
		current_size = 1 if dyn else size

		while current_size <= size:
			current_word = self.init_word(current_size)

			while current_word:
				self.write(current_word)
				current_word = self.get_next_word(current_word)

			current_size += 1

	def get_next_word(self, current):
		"""
		Increment numbers in number-array

		@param list current
		@return list
		"""
		for i in range(len(current) - 1, -1, -1):
			if current[i] < len(self.alphabet) - 1:
				# We're still in alphabet-range: just increment
				current[i] += 1
				return current
			else:
				# Set to 0 and move to the next position
				current[i] = 0

		# Reached the end for the current length
		return None

	def init_word(self, size):
		"""
		Initialize list of given size with all zeros

		@param int size
		@return list
		"""
		return [0 for col in range(size)]

	def set_alphabet(self, upper, lower, numbers):
		"""
		Populate alphabet

		@param boolean upper
		@param boolean lower
		@param boolean numbers
		@return list
		"""
		alphabet = []

		if upper:
			alphabet += list(map(chr, range(65, 91)))
		if lower:
			alphabet += list(map(chr, range(97, 123)))
		if numbers:
			alphabet += list(map(chr, range(48, 58)))

		return alphabet

	def translate(self, tmp):
		"""
		Translate list of numbers to string of characters of the specified alphabet

		@param list tmp
		@return string
		"""
		return ''.join(map(lambda x: self.alphabet[x], tmp))

	def write(self, tmp):
		"""
		Write generated word to file

		@param list tmp
		"""
		word = self.translate(tmp)

		with open(self.path, 'a+') as out:
			out.write(word + "\n")

	def clean(self):
		"""
		Remove existing wordlist if exists
		"""
		if os.path.isfile(self.path):
			os.remove(self.path)

	@staticmethod
	def help():
		"""
		Print usage help
		"""
		print("Wordlist Creator Usage:")
		print("-c [--clean]\t\tRemove existing wordlist before creating")
		print("-s [--size]\t\tNumber of characters")
		print("-d [--dynamic]\t\tCreate words with 1 to [size] characters")
		print("-u [--upper]\t\tUse uppercase letters")
		print("-l [--lower]\t\tUse lowercase letters")
		print("-n [--numbers]\t\tUse numbers")
		print("-o [--outpath]\t\tSpecify a destination path")

if __name__ == "__main__":
	try:
		opts, args = getopt.getopt(sys.argv[1:], "cs:dulno:h", ["clean", "size=", "dynamic", "upper", "lower", "numbers", "outpath=", "help"])
	except getopt.GetoptError as e:
		Wordlist.help()
		sys.exit(2)

	clean = False
	size = 2
	dynamic = False
	upper = False
	lower = False
	numbers = False
	path = None

	for o, a in opts:
		if o in ("-c", "--clean"):
			clean = True
		elif o in ("-s", "--size"):
			size = int(a)
		elif o in ("-d", "--dynamic"):
			dynamic = True
		elif o in ("-u", "--upper"):
			upper = True
		elif o in ("-l", "--lower"):
			lower = True
		elif o in ("-n", "--numbers"):
			numbers = True
		elif o in ("-o", "--outpath"):
			path = a
		elif o in ("-h", "--help"):
			Wordlist.help()

	wl = Wordlist(path=path)
	wl.create(clean=clean, size=size, dyn=True, upper=upper, lower=lower, numbers=numbers)
