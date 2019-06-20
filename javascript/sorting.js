// Partition and swap might be better off in a separate function
function quicksort(arr, begin, end) {
	// Set default values
	if (begin === undefined) {
		begin = 0;
	}
	if (end === undefined) {
		end = arr.length - 1;
	}

	// Check boundaries
	if (begin >= end) {
		return;
	}

	// Set pivot to first element in bounds (could also be randomly selected)
	let pivot = arr[begin];
	let left = begin;
	let right = end;

	// Partition
	// As long as the left pointer is smaller than / equal to the right pointer
	while (left <= right) {
		// Move the left pointer as long as it points to an entry smaller than pivot
		while (arr[left] < pivot) {
			left++;
		}
		// Move the right pointer as long as it points to an entry bigger than pivot
		while (arr[right] > pivot) {
			right--;
		}

		// Swap
		// If left is still smaller than / equal to right -> swap entries, then move pointers
		if (left <= right) {
			let tmp = arr[left];
			arr[left] = arr[right];
			arr[right] = tmp;
			left++;
			right--;
		}
	}

	// Sort left half
	quicksort(arr, 0, left - 1);

	// Sort right half
	quicksort(arr, left, end);

	return arr;
}

// Merge halves belongs in a separate function mergeHalves(left, right) that returns tmp
function mergesort(arr) {
	if (arr.length == 1) {
		return arr;
	}

	let middle = Math.floor(arr.length / 2);
	let left = mergesort(arr.slice(0, middle));
	let right = mergesort(arr.slice(middle, arr.length));

	let tmp = [];

	// Merge halves
	while (left.length && right.length) {
		if (left[0] < right[0]) {
			tmp.push(left.shift());
		}
		else {
			tmp.push(right.shift());
		}
	}

	// Add remaining entries from each half (only one will have entries left after the while)
	return tmp.concat(left).concat(right);
}

function bubblesort(arr) {
	let end = arr.length - 1;

	for (let i = 0; i < arr.length - 1; i++) {
		for (let j = 0; j < end; j++) {
			if (arr[j] > arr[j+1]) {
				let tmp = arr[j];
				arr[j] = arr[j+1];
				arr[j+1] = tmp;
			}
		}

		end--;
	}

	return arr;
}
