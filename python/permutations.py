def permutations(str, allowDuplicates=True):
	mask = [0] * len(str)
	solutions = []
	max = len(str) - 1

	while len(mask) == len(str):
		solution = translate(str, mask)

		if allowDuplicates or noDuplicates(solution):
			solutions.append(solution)

		mask = addOne(mask, max)

	print(solutions)

def noDuplicates(arr):
	for i in arr:
		if arr.count(i) > 1:
			return False

	return True

def translate(str, mask):
	translation = []

	for i in mask:
		translation.append(str[i])

	return ''.join(translation)

def addOne(arr, max=9):
	for i in range(len(arr) - 1, -1, -1):
		if arr[i] < max:
			arr[i] += 1

			return arr
		else:
			arr[i] = 0

	arr.insert(0, 1)

	return arr

str = "abcd"
permutations(str, False)
