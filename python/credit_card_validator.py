def validate_credit_card_number(number):
	"""
	Validate credit card number using Luhn Algorithm
	"""
	sum = 0
	step = 0

	for i in range(len(str(number)) - 1, -1, -1):
		step += 1
		add = int(str(number)[i])

		if step % 2 == 0:
			add *= 2

			if (add > 9):
				add -= 9

		sum += add

	return sum % 10 == 0

print(validate_credit_card_number(18937))
