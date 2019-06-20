def main(width):
	if width % 2 is 0:
		print("Need an odd number")
		return

	spaces = int(width / 2)

	for i in range (1, int(width / 2) + 1 + 1):
		print("{}{}".format(" " * spaces, "#" * (i * 2 - 1)))
		spaces -= 1

if __name__ == "__main__":
	main(7)
